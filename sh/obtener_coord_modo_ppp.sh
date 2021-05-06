#!/bin/bash
opc=(
    "Elige una fuente de datos:"
    "1:desde base-rtk2go"
    "2:desde base-telemetría"
    "3:antena local"
    "4:UNAVCO"
    "5:Otra fuente de correcciones"
)
printf '%s\n' "${opc[@]}"
read -p "Tu elección: " fuentedatos
#read -p "Fuente de datos [ 1:desde base-rtk2go 2:desde base-telemetría; 3:antena local; 4:UNAVCO ]: " fuentedatos
fuentedatos=${fuentedatos:-1}
tmp_dir=$(mktemp -d -t $(date +%Y-%m-%d-%H-%M-%S)-XXXX --tmpdir=/home/pi/TouchRTKStation/bases)
chmod g+rx,o+rx $tmp_dir

# Variables
raw=raw
pos=out.pos
tmppos=tmp_out.pos
pos_no=out_no.pos
pro=promedio.csv
rutascript=/home/pi/TouchRTKStation/TouchRTKStation.py
rutacredenciales=/home/pi/TouchRTKStation/.credenciales/credenciales
rutaconf=/home/pi/TouchRTKStation/conf/static.conf
rutaconfinst=/home/pi/TouchRTKStation/conf/.static.conf.instance
rutainstancia=/home/pi/TouchRTKStation/.instance
if [ -f "$rutainstancia" ]; then rm $rutainstancia; fi
cmd1hz=m8t_1hz_demo5_github.cmd
cmd5hz=m8t_5hz_demo5_github.cmd

# Variables UNAVCO
basepos_itype_unavco=1
corr_flag_unavco=True
corr_iformat_unavco=1
corr_user_unavco=`if [ -f "$rutacredenciales" ]; then grep -oP 'corr_user_unavco=\K\w+' $rutacredenciales; fi`
corr_addr_unavco=rtgpsout.unavco.org
corr_port_unavco=2101
corr_pw_unavco=`if [ -f "$rutacredenciales" ]; then grep -oP 'corr_pw_unavco=\K\w+' $rutacredenciales; fi`
corr_mp_unavco=`if [ -f "$rutacredenciales" ]; then grep -oP 'mp_unavco=\K\w+' $rutacredenciales; fi`

# Variables Otro
basepos_itype_otro=1
corr_flag_otro=True
corr_iformat_otro=1
corr_user_otro=`if [ -f "$rutacredenciales" ]; then grep -oP 'corr_user_otro=\K\w+' $rutacredenciales; fi`
corr_addr_otro=`if [ -f "$rutacredenciales" ]; then grep -oP 'corr_addr_otro=\K\w+.*' $rutacredenciales; fi`
corr_port_otro=`if [ -f "$rutacredenciales" ]; then grep -oP 'corr_port_otro=\K\w+' $rutacredenciales; fi`
corr_pw_otro=`if [ -f "$rutacredenciales" ]; then grep -oP 'corr_pw_otro=\K\w+' $rutacredenciales; fi`
corr_mp_otro=`if [ -f "$rutacredenciales" ]; then grep -oP 'mp_otro=\K\w+' $rutacredenciales; fi`

# Variables rtk2go
rtk2gopw=`if [ -f "$rutacredenciales" ]; then grep -oP 'output_pw=\K\w+' $rutacredenciales; fi`
rtk2gomp=`if [ -f "$rutacredenciales" ]; then grep -oP 'mp_rtk2go=\K\w+' $rutacredenciales; fi`
corr_user_unavco=`if [ -f "$rutacredenciales" ]; then grep -oP 'corr_user_unavco=\K\w+' $rutacredenciales; fi`
corr_pw_unavco=`if [ -f "$rutacredenciales" ]; then grep -oP 'corr_pw_unavco=\K\w+' $rutacredenciales; fi`
mp_unavco=`if [ -f "$rutacredenciales" ]; then grep -oP 'mp_unavco=\K\w+' $rutacredenciales; fi`

# Temporizador de tiempo transcurrido
if [ $fuentedatos -lt 4 ]
then
read -p "Tiempo (en segundos) de colecta de coordenadas [por defecto, 300]: " tiempo
tiempo=${tiempo:-300}
echo "Las observaciones en bruto tomadas durante $tiempo segundos en modo single, se utilizarán para calcular solución PPP y se guardarán aquí:" $tmp_dir
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
fi

if [ $fuentedatos -eq 1 ]
then
  # Abrir stream desde base en rtk2go.com, guardarlo en UBX
  echo "Tomando datos de base rtk2go"
  timeout --foreground ${tiempo}s /home/pi/RTKLIB/app/str2str/gcc/str2str -in ntrip://user:$rtk2gopw@rtk2go.com:2101/$rtk2gomp -out file://$tmp_dir/$raw.rtcm3
elif [ $fuentedatos -eq 2 ]
then
  # Abrir stream desde base con telemetría, guardarlo en RTCM3
  echo "Tomando datos de base telemetría"
  timeout --foreground ${tiempo}s /home/pi/RTKLIB/app/str2str/gcc/str2str -in serial://serial0:115200:8:n:1:off#rtcm3 -out file://$tmp_dir/$raw.rtcm3
elif [ $fuentedatos -eq 3 ]
then
  # Abrir stream desde receptor local (normalmente, el rover), guardarlo en UBX
  echo "Tomando datos de antena local"
  timeout --foreground ${tiempo}s /home/pi/RTKLIB/app/str2str/gcc/str2str -c /home/pi/TouchRTKStation/conf/m8t_1hz_demo5_github.cmd -in serial://ttyACM0:115200:8:n:1:off#ubx -out file://$tmp_dir/$raw.ubx
elif [ $fuentedatos -eq 4 ]
then
  # Obtener coordenadas de base con stream de UNAVCO
  cp $rutascript $rutainstancia
  sed -i "s/basepos_itype = .*$/basepos_itype = $basepos_itype_unavco/g" $rutainstancia
  sed -i "s/ubx_m8t_bds_raw_1hz.cmd/$cmd5hz/g" $rutainstancia
  sed -i "s~sol_filename = .*$~sol_filename = '$tmp_dir/$tmppos'~g" $rutainstancia
  sed -i "s~log_filename = .*$~log_filename = '$tmp_dir/$raw.ubx'~g" $rutainstancia
  sed -i "s/corr_flag = .*$/corr_flag = $corr_flag_unavco/g" $rutainstancia
  sed -i "s/corr_iformat = .*$/corr_iformat = $corr_iformat_unavco/g" $rutainstancia
  sed -i "s/corr_user = .*$/corr_user = '$corr_user_unavco'/g" $rutainstancia
  sed -i "s/corr_addr = .*$/corr_addr = '$corr_addr_unavco'/g" $rutainstancia
  sed -i "s/corr_port = .*$/corr_port = '$corr_port_unavco'/g" $rutainstancia
  sed -i "s/corr_pw = .*$/corr_pw = '$corr_pw_unavco'/g" $rutainstancia
  sed -i "s/corr_mp = .*$/corr_mp = '$corr_mp_unavco'/g" $rutainstancia
  python3 $rutainstancia
  footmp=`grep -n '%  GPST' $tmp_dir/$tmppos | cut -f1 -d:`
  lineatmp=`echo $footmp | awk '{print $1+0}'`
  nfixes=`tail -n +$lineatmp $tmp_dir/$tmppos | awk '$6==1 { print }' | wc -l`
  if [ $nfixes -ge 30 ]
  then
   { head -n +$lineatmp $tmp_dir/$tmppos & tail -n +$lineatmp $tmp_dir/$tmppos | awk '$6==1 { print }'; } > $tmp_dir/$pos
  else
   mv $tmp_dir/$tmppos $tmp_dir/$pos
  fi
else
  # Obtener coordenadas de base con stream Otro
  cp $rutascript $rutainstancia
  sed -i "s/basepos_itype = .*$/basepos_itype = $basepos_itype_otro/g" $rutainstancia
  sed -i "s/ubx_m8t_bds_raw_1hz.cmd/$cmd5hz/g" $rutainstancia
  sed -i "s~sol_filename = .*$~sol_filename = '$tmp_dir/$tmppos'~g" $rutainstancia
  sed -i "s~log_filename = .*$~log_filename = '$tmp_dir/$raw.ubx'~g" $rutainstancia
  sed -i "s/corr_flag = .*$/corr_flag = $corr_flag_otro/g" $rutainstancia
  sed -i "s/corr_iformat = .*$/corr_iformat = $corr_iformat_otro/g" $rutainstancia
  sed -i "s/corr_user = .*$/corr_user = '$corr_user_otro'/g" $rutainstancia
  sed -i "s/corr_addr = .*$/corr_addr = '$corr_addr_otro'/g" $rutainstancia
  sed -i "s/corr_port = .*$/corr_port = '$corr_port_otro'/g" $rutainstancia
  sed -i "s/corr_pw = .*$/corr_pw = '$corr_pw_otro'/g" $rutainstancia
  sed -i "s/corr_mp = .*$/corr_mp = '$corr_mp_otro'/g" $rutainstancia
  python3 $rutainstancia
  footmp=`grep -n '%  GPST' $tmp_dir/$tmppos | cut -f1 -d:`
  lineatmp=`echo $footmp | awk '{print $1+0}'`
  nfixes=`tail -n +$lineatmp $tmp_dir/$tmppos | awk '$6==1 { print }' | wc -l`
  if [ $nfixes -ge 30 ]
  then
   { head -n +$lineatmp $tmp_dir/$tmppos & tail -n +$lineatmp $tmp_dir/$tmppos | awk '$6==1 { print }'; } > $tmp_dir/$pos
  else
   mv $tmp_dir/$tmppos $tmp_dir/$pos
  fi
fi

if [ $fuentedatos -lt 4 ]
then
# Convertir binario en RINEX
/home/pi/RTKLIB/app/convbin/gcc/convbin $tmp_dir/$raw*
# Calcular solución
/home/pi/RTKLIB/app/rnx2rtkp/gcc/rnx2rtkp -k /home/pi/TouchRTKStation/conf/ppp_static.conf $tmp_dir/$raw* -o $tmp_dir/$pos
# Borrar archivo temporizador
rm -f $file
fi

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
