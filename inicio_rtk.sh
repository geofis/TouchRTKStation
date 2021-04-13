#!/bin/bash
# Bash Menu Script Example

# Archivos
rutascript=/home/pi/TouchRTKStation/TouchRTKStation.py
rutainstancia=$(mktemp -t instance_$(date +%Y-%m-%d-%H-%M-%S)-XXXX.py --tmpdir=/home/pi/TouchRTKStation)
rutacredenciales=/home/pi/credenciales

# cmd
cmd1hz=m8t_1hz_demo5_github.cmd
cmd5hz=m8t_5hz_demo5_github.cmd

# Para RTK Base a rtk2go
output_flag=True
output_itype=1
output_user=user
output_addr=rtk2go.com
output_port=2101
output_pw=`grep -oP 'output_pw=\K\w+' $rutacredenciales`
output_mp=geofis_ovni

# Para RTK Base a telemetría
output2_flag=True
output2_iformat=1
output2_iport=4
output2_ibitrate=9

# Para RTK Rover correcciones desde UNAVCO
basepos_itype_unavco=1
corr_flag_unavco=True
corr_iformat_unavco=1
corr_user_unavco=`grep -oP 'corr_user_unavco=\K\w+' $rutacredenciales`
corr_addr_unavco=rtgpsout.unavco.org
corr_port_unavco=2101
corr_pw_unavco=`grep -oP 'corr_pw_unavco=\K\w+' $rutacredenciales`
corr_mp_unavco=RDSD_RTCM3

# Para RTK Rover correcciones desde rtk2go
corr_flag_rtk2go=True
corr_iformat_rtk2go=3
corr_user_rtk2go=$output_user
corr_addr_rtk2go=$output_addr
corr_port_rtk2go=$output_port
corr_pw_rtk2go=$output_pw
corr_mp_rtk2go=$output_mp

# Para RTK Rover correcciones desde telemetría
corr2_flag=True
corr2_iformat=$output2_iformat
corr2_iport=0
corr2_ibitrate=$output2_ibitrate

# ENU para static
optfile_enu='static_enu.conf'

# Menú
PS3='Elige tu opción: '
options=("Generar posición de la base" "RTK Base a rtk2go" "RTK Base a telemetría" "RTK Base a telemetría y rtk2go" "RTK Rover correcciones desde UNAVCO" "RTK Rover correcciones desde rtk2go" "RTK Rover correcciones desde rtk2go ENU" "RTK Rover correcciones desde telemetría" "RTK Rover correcciones desde telemetría ENU" "Salir")
select opt in "${options[@]}"
do
    case $opt in
        "Generar posición de la base")
            echo "Seleccionado: $opt"
            /home/pi/TouchRTKStation/obtener_coord_modo_ppp.sh
            break
            ;;
        "RTK Base a rtk2go")
            echo "Seleccionado: $opt"
            cp $rutascript $rutainstancia
            sed -i "s/ubx_m8t_bds_raw_1hz.cmd/$cmd1hz/g" $rutainstancia
            sed -i "s/output_flag = .*$/output_flag = $output_flag/g" $rutainstancia
            sed -i "s/output_itype = .*$/output_itype = $output_itype/g" $rutainstancia
            sed -i "s/output_user = .*$/output_user = '$output_user'/g" $rutainstancia
            sed -i "s/output_addr = .*$/output_addr = '$output_addr'/g" $rutainstancia
            sed -i "s/output_port = .*$/output_port = '$output_port'/g" $rutainstancia
            sed -i "s/output_pw = .*$/output_pw = '$output_pw'/g" $rutainstancia
            sed -i "s/output_mp = .*$/output_mp = '$output_mp'/g" $rutainstancia
            python3 $rutainstancia
            break
            ;;
        "RTK Base a telemetría")
            echo "Seleccionado: $opt"
            cp $rutascript $rutainstancia
            sed -i "s/ubx_m8t_bds_raw_1hz.cmd/$cmd1hz/g" $rutainstancia
            sed -i "s/output2_flag = .*$/output2_flag = $output2_flag/g" $rutainstancia
            sed -i "s/output2_ibitrate = .*$/output2_ibitrate = $output2_ibitrate/g" $rutainstancia
            sed -i "s/output2_iformat = .*$/output2_iformat = $output2_iformat/g" $rutainstancia
            sed -i "s/output2_iport = .*$/output2_iport = $output2_iport/g" $rutainstancia
            python3 $rutainstancia
            break
            ;;
        "RTK Base a telemetría y rtk2go")
            echo "Seleccionado: $opt"
            cp $rutascript $rutainstancia
            sed -i "s/ubx_m8t_bds_raw_1hz.cmd/$cmd1hz/g" $rutainstancia
            sed -i "s/output_flag = .*$/output_flag = $output_flag/g" $rutainstancia
            sed -i "s/output_itype = .*$/output_itype = $output_itype/g" $rutainstancia
            sed -i "s/output_user = .*$/output_user = '$output_user'/g" $rutainstancia
            sed -i "s/output_addr = .*$/output_addr = '$output_addr'/g" $rutainstancia
            sed -i "s/output_port = .*$/output_port = '$output_port'/g" $rutainstancia
            sed -i "s/output_pw = .*$/output_pw = '$output_pw'/g" $rutainstancia
            sed -i "s/output_mp = .*$/output_mp = '$output_mp'/g" $rutainstancia
            sed -i "s/output2_flag = .*$/output2_flag = $output2_flag/g" $rutainstancia
            sed -i "s/output2_ibitrate = .*$/output2_ibitrate = $output2_ibitrate/g" $rutainstancia
            sed -i "s/output2_iformat = .*$/output2_iformat = $output2_iformat/g" $rutainstancia
            sed -i "s/output2_iport = .*$/output2_iport = $output2_iport/g" $rutainstancia
            python3 $rutainstancia
            break
            ;;
        "RTK Rover correcciones desde UNAVCO")
            echo "Seleccionado: $opt"
            cp $rutascript $rutainstancia
            sed -i "s/basepos_itype = .*$/basepos_itype = $basepos_itype_unavco/g" $rutainstancia
            sed -i "s/ubx_m8t_bds_raw_1hz.cmd/$cmd5hz/g" $rutainstancia
            sed -i "s/corr_flag = .*$/corr_flag = $corr_flag_unavco/g" $rutainstancia
            sed -i "s/corr_iformat = .*$/corr_iformat = $corr_iformat_unavco/g" $rutainstancia
            sed -i "s/corr_user = .*$/corr_user = '$corr_user_unavco'/g" $rutainstancia
            sed -i "s/corr_addr = .*$/corr_addr = '$corr_addr_unavco'/g" $rutainstancia
            sed -i "s/corr_port = .*$/corr_port = '$corr_port_unavco'/g" $rutainstancia
            sed -i "s/corr_pw = .*$/corr_pw = '$corr_pw_unavco'/g" $rutainstancia
            sed -i "s/corr_mp = .*$/corr_mp = '$corr_mp_unavco'/g" $rutainstancia
            python3 $rutainstancia
            break
            ;;
        "RTK Rover correcciones desde rtk2go")
            echo "Seleccionado: $opt"
            cp $rutascript $rutainstancia
            sed -i "s/ubx_m8t_bds_raw_1hz.cmd/$cmd5hz/g" $rutainstancia
            sed -i "s/corr_flag = .*$/corr_flag = $corr_flag_rtk2go/g" $rutainstancia
            sed -i "s/corr_iformat = .*$/corr_iformat = $corr_iformat_rtk2go/g" $rutainstancia
            sed -i "s/corr_user = .*$/corr_user = '$corr_user_rtk2go'/g" $rutainstancia
            sed -i "s/corr_addr = .*$/corr_addr = '$corr_addr_rtk2go'/g" $rutainstancia
            sed -i "s/corr_port = .*$/corr_port = '$corr_port_rtk2go'/g" $rutainstancia
            sed -i "s/corr_pw = .*$/corr_pw = '$corr_pw_rtk2go'/g" $rutainstancia
            sed -i "s/corr_mp = .*$/corr_mp = '$corr_mp_rtk2go'/g" $rutainstancia
            python3 $rutainstancia
            break
            ;;
        "RTK Rover correcciones desde rtk2go ENU")
            echo "Seleccionado: $opt"
            cp $rutascript $rutainstancia
            sed -i "s/ubx_m8t_bds_raw_1hz.cmd/$cmd5hz/g" $rutainstancia
            sed -i "s/corr_flag = .*$/corr_flag = $corr_flag_rtk2go/g" $rutainstancia
            sed -i "s/corr_iformat = .*$/corr_iformat = $corr_iformat_rtk2go/g" $rutainstancia
            sed -i "s/corr_user = .*$/corr_user = '$corr_user_rtk2go'/g" $rutainstancia
            sed -i "s/corr_addr = .*$/corr_addr = '$corr_addr_rtk2go'/g" $rutainstancia
            sed -i "s/corr_port = .*$/corr_port = '$corr_port_rtk2go'/g" $rutainstancia
            sed -i "s/corr_pw = .*$/corr_pw = '$corr_pw_rtk2go'/g" $rutainstancia
            sed -i "s/corr_mp = .*$/corr_mp = '$corr_mp_rtk2go'/g" $rutainstancia
            sed -i "s/optfile='static.conf'/optfile='$optfile_enu'/g" $rutainstancia
            sed -i "s/oformat.append('llh')/oformat.append('enu')/g" $rutainstancia
            python3 $rutainstancia
            break
            ;;
        "RTK Rover correcciones desde telemetría")
            echo "Seleccionado: $opt"
            cp $rutascript $rutainstancia
            sed -i "s/ubx_m8t_bds_raw_1hz.cmd/$cmd5hz/g" $rutainstancia
            sed -i "s/corr2_flag = .*$/corr2_flag = $corr2_flag/g" $rutainstancia
            sed -i "s/corr2_iformat = .*$/corr2_iformat = $corr2_iformat/g" $rutainstancia
            sed -i "s/corr2_iport = .*$/corr2_iport = $corr2_iport/g" $rutainstancia
            sed -i "s/corr2_ibitrate = .*$/corr2_ibitrate = $corr2_ibitrate/g" $rutainstancia
            python3 $rutainstancia
            break
            ;;
        "RTK Rover correcciones desde telemetría ENU")
            echo "Seleccionado: $opt"
            cp $rutascript $rutainstancia
            sed -i "s/ubx_m8t_bds_raw_1hz.cmd/$cmd5hz/g" $rutainstancia
            sed -i "s/corr2_flag = .*$/corr2_flag = $corr2_flag/g" $rutainstancia
            sed -i "s/corr2_iformat = .*$/corr2_iformat = $corr2_iformat/g" $rutainstancia
            sed -i "s/corr2_iport = .*$/corr2_iport = $corr2_iport/g" $rutainstancia
            sed -i "s/corr2_ibitrate = .*$/corr2_ibitrate = $corr2_ibitrate/g" $rutainstancia
            sed -i "s/optfile='static.conf'/optfile='$optfile_enu'/g" $rutainstancia
            sed -i "s/oformat.append('llh')/oformat.append('enu')/g" $rutainstancia
            python3 $rutainstancia
            break
            ;;
        "Salir")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
