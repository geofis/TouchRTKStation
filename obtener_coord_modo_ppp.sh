#!/bin/bash
read -p "Fuente de datos [1:base rtk2go;2:antena local]: " fuentedatos
fuentedatos=${fuentedatos:-1}
read -p "Tiempo (en segundos) de colecta de coordenadas [por defecto, 300]: " tiempo
tiempo=${tiempo:-300}
tmp_dir=$(mktemp -d -t $(date +%Y-%m-%d-%H-%M-%S)-XXXX --tmpdir=/home/pi/bases)
chmod g+rx,o+rx $tmp_dir
echo "Las observaciones en bruto tomadas durante $tiempo segundos en modo single, se utilizarán para calcular solución PPP y se guardarán aquí:" $tmp_dir

ubx=raw.ubx
pos=out.pos
pos_no=out_no.pos
pro=promedio.csv
rutascript=/home/pi/TouchRTKStation/TouchRTKStation.py
rutacredenciales=/home/pi/credenciales
rtk2gopw=`grep -oP 'output_pw=\K\w+' $rutacredenciales`

# Temporizador de tiempo transcurrido
file=$(mktemp)
progress() {
  pc=0;
  while [ -e $file ]
    do
      echo -ne "$pc sec\033[0K\r"
      sleep 1
      ((pc++))
    done
}
progress &

if [ $fuentedatos -eq 1 ]
then
  # Abrir stream desde base en rtk2go.com, enviarlo a UBX
  echo "Tomando datos de base rtk2go"
  timeout --foreground ${tiempo}s /home/pi/RTKLIB/app/str2str/gcc/str2str -in ntrip://user:$rtk2gopw@rtk2go.com:2101/geofis_ovni -out file://$tmp_dir/$ubx 
else
  # Abrir stream desde receptor, enviarlo a UBX
  echo "Tomando datos de antena local"
  timeout --foreground ${tiempo}s /home/pi/RTKLIB/app/str2str/gcc/str2str -c /home/pi/TouchRTKStation/conf/m8t_5hz_usb.cmd -in serial://ttyACM0:115200:8:n:1:off#ubx -out file://$tmp_dir/$ubx
fi

# Convertir binario en RINEX
convbin $tmp_dir/$ubx

# Calcular solución en modo single
rnx2rtkp -k /home/pi/TouchRTKStation/conf/ppp_static.conf $tmp_dir/${ubx/ubx/}* -o $tmp_dir/$pos
#rnx2rtkp -k /home/pi/TouchRTKStation/conf/single.conf $tmp_dir/${ubx/ubx/}* -o $tmp_dir/$pos

# Borrar archivo temporizador
rm -f $file

# Calcular puntuaciones z y promedios finales
foo=`grep -n '%  GPST' $tmp_dir/$pos | cut -f1 -d:`
linea=`echo $foo | awk '{print $1+1}'`
foo_mean_sd=`tail -n +$linea $tmp_dir/$pos | awk '{sum += int($3); sumsq += int(($3)^2)}\
  END {printf "%.20f %.20f \n", sum/NR, sqrt((sumsq-sum^2/NR)/(NR-1))}'`
foo_mean=`echo $foo_mean_sd | awk '{print $1}'`
foo_sd=`echo $foo_mean_sd | awk '{print $2}'`
tail -n +$linea $tmp_dir/$pos |\
    awk -v m="$foo_mean" -v s="$foo_sd" 'function abs(v) {return v < 0 ? -v : v} { if ( abs(($3-m)/s)<1 ) print $3,$4,$5 }' > $tmp_dir/$pos_no

lat=`awk '{ total += $1 } END { printf "%.9f", total/NR }' $tmp_dir/$pos_no`
lon=`awk '{ total += $2 } END { printf "%.9f", total/NR }' $tmp_dir/$pos_no`
h=`awk '{ total += $3 } END { printf "%.9f", total/NR }' $tmp_dir/$pos_no`

#exit 0

#lat=`tail -n +$linea $tmp_dir/out.pos | awk '{ total += $3 } END { printf "%.9f", total/NR }'`
#lon=`tail -n +$linea $tmp_dir/out.pos | awk '{ total += $4 } END { printf "%.9f", total/NR }'`
#h=`tail -n +$linea $tmp_dir/out.pos | awk '{ total += $5 } END { printf "%.9f", total/NR }'`

# Actualizar coordenadas de la base en el script python
sed -i "s/basepos_lat = .*$/basepos_lat = '$lat'/g" $rutascript
sed -i "s/basepos_lon = .*$/basepos_lon = '$lon'/g" $rutascript
sed -i "s/basepos_hgt = .*$/basepos_hgt = '$h'/g" $rutascript
sed -i "s/basepos_itype = .*$/basepos_itype = 0/g" $rutascript

# Crear archivo de promedio
echo "lat,lon,h" | tee $tmp_dir/$pro
echo "$lat,$lon,$h" | tee -a $tmp_dir/$pro

# Crear KML con las soluciones (todas)
/home/pi/RTKLIB/app/pos2kml/gcc/pos2kml $tmp_dir/$pos

read -p "Presiona ENTER para salir" x
