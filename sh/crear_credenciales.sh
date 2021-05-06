#!/bin/bash

rutaplantilla=/home/pi/TouchRTKStation/sh/plantilla_credenciales
rutafinal=/home/pi/TouchRTKStation/.credenciales/credenciales

while [ ! -f "$rutafinal" ]
do
  read -p "No existe archivo de credenciales, ¿crearlo? [S/n]: " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Ss]$ ]]
  then
    cp $rutaplantilla $rutafinal
    break
  else
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
  fi
done

PS3='Crear credenciales para: '
options=("rtk2go" "UNAVCO" "Otro" "Salir")
select opt in "${options[@]}"
do
  case $opt in
    "rtk2go")
      echo "Seleccionado: $opt"

      output_pw0=`awk -F '=' '$1=="output_pw" {print $2}' $rutafinal`
      read -p "Password en rtk2go [ENTER para dejar valor actual '$output_pw0']: " output_pw
      output_pw=${output_pw:-$output_pw0}
      sed -i "s/output_pw=.*$/output_pw=$output_pw/g" $rutafinal

      mp_rtk2go0=`awk -F '=' '$1=="mp_rtk2go" {print $2}' $rutafinal`
      read -p "Mount point en rtk2go [ENTER para dejar valor actual '$mp_rtk2go0']: " mp_rtk2go
      mp_rtk2go=${mp_rtk2go:-$mp_rtk2go0}
      sed -i "s/mp_rtk2go=.*$/mp_rtk2go=$mp_rtk2go/g" $rutafinal

      break
      ;;
    "UNAVCO")
      echo "Seleccionado: $opt"

      corr_user_unavco0=`awk -F '=' '$1=="corr_user_unavco" {print $2}' $rutafinal`
      read -p "Nombre de usuario en UNAVCO [ENTER para dejar valor actual '$corr_user_unavco0']: " corr_user_unavco
      corr_user_unavco=${corr_user_unavco:-$corr_user_unavco0}
      sed -i "s/corr_user_unavco=.*$/corr_user_unavco=$corr_user_unavco/g" $rutafinal

      corr_pw_unavco0=`awk -F '=' '$1=="corr_pw_unavco" {print $2}' $rutafinal`
      read -p "Password en UNAVCO [ENTER para dejar valor actual '$corr_pw_unavco0']: " corr_pw_unavco
      corr_pw_unavco=${corr_pw_unavco:-$corr_pw_unavco0}
      sed -i "s/corr_pw_unavco=.*$/corr_pw_unavco=$corr_pw_unavco/g" $rutafinal

      mp_unavco0=`awk -F '=' '$1=="mp_unavco" {print $2}' $rutafinal`
      read -p "Mount point en UNAVCO [ENTER para dejar valor actual '$mp_unavco0']: " mp_unavco
      mp_unavco=${mp_unavco:-$mp_unavco0}
      sed -i "s/mp_unavco=.*$/mp_unavco=$mp_unavco/g" $rutafinal

      break
      ;;
    "Otro")
      echo "Seleccionado: $opt"

      corr_user_otro0=`awk -F '=' '$1=="corr_user_otro" {print $2}' $rutafinal`
      read -p "Nombre de usuario [ENTER para dejar valor actual '$corr_user_otro0']: " corr_user_otro
      corr_user_otro=${corr_user_otro:-$corr_user_otro0}
      sed -i "s/corr_user_otro=.*$/corr_user_otro=$corr_user_otro/g" $rutafinal

      corr_pw_otro0=`awk -F '=' '$1=="corr_pw_otro" {print $2}' $rutafinal`
      read -p "Password [ENTER para dejar valor actual '$corr_pw_otro0']: " corr_pw_otro
      corr_pw_otro=${corr_pw_otro:-$corr_pw_otro0}
      sed -i "s/corr_pw_otro=.*$/corr_pw_otro=$corr_pw_otro/g" $rutafinal

      corr_addr_otro0=`awk -F '=' '$1=="corr_addr_otro" {print $2}' $rutafinal`
      read -p "URL o direccion IP [ENTER para dejar valor actual '$corr_addr_otro0']: " corr_addr_otro
      corr_addr_otro=${corr_addr_otro:-$corr_addr_otro0}
      sed -i "s/corr_addr_otro=.*$/corr_addr_otro=$corr_addr_otro/g" $rutafinal

      corr_port_otro0=`awk -F '=' '$1=="corr_port_otro" {print $2}' $rutafinal`
      read -p "Puerto [ENTER para dejar valor actual '$corr_port_otro0']: " corr_port_otro
      corr_port_otro=${corr_port_otro:-$corr_port_otro0}
      sed -i "s/corr_port_otro=.*$/corr_port_otro=$corr_port_otro/g" $rutafinal

      mp_otro0=`awk -F '=' '$1=="mp_otro" {print $2}' $rutafinal`
      read -p "Mount point [ENTER para dejar valor actual '$mp_otro0']: " mp_otro
      mp_otro=${mp_otro:-$mp_otro0}
      sed -i "s/mp_otro=.*$/mp_otro=$mp_otro/g" $rutafinal

      break
      ;;
    "Salir")
      break
      ;;
    *) echo "invalid option $REPLY";;
  esac
done
