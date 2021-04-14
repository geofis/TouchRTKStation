#!/bin/bash

rutaplantilla=/home/pi/TouchRTKStation/plantilla_credenciales
rutafinal=/home/pi/credenciales
cr=`echo $'\n'`

if [ -f "$rutafinal" ]
then
  read -p "Existe un archivo de credenciales, ¿borrarlo y continuar? [S/n]: " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Ss]$ ]]
  then
    read -p "Password en rtk2go [ENTER para dejar en blanco]: " output_pw
    read -p "Nombre de usuario en UNAVCO [ENTER para dejar en blanco]: " corr_user_unavco
    read -p "Password en UNAVCO [ENTER para dejar en blanco]: " corr_pw_unavco
    cp $rutaplantilla $rutafinal
    sed -i "s/output_pw=.*$/output_pw=$output_pw/g" $rutafinal
    sed -i "s/corr_user_unavco=.*$/corr_user_unavco=$corr_user_unavco/g" $rutafinal
    sed -i "s/corr_pw_unavco=.*$/corr_pw_unavco=$corr_pw_unavco/g" $rutafinal
  else
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
  fi
fi
