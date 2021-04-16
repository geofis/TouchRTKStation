#!/bin/bash

rutaplantilla=/home/pi/TouchRTKStation/sh/plantilla_credenciales
rutafinal=/home/pi/TouchRTKStation/.credenciales/credenciales

while [ -f "$rutafinal" ]
do
  read -p "Existe un archivo de credenciales, ¿borrarlo? [S/n]: " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Ss]$ ]]
  then
    rm $rutafinal
    break
  else
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
  fi
done
read -p "Password en rtk2go [ENTER para dejar en blanco]: " output_pw
read -p "Mount point en rtk2go [ENTER para dejar en blanco]: " mp_rtk2go
read -p "Nombre de usuario en UNAVCO [ENTER para dejar en blanco]: " corr_user_unavco
read -p "Password en UNAVCO [ENTER para dejar en blanco]: " corr_pw_unavco
read -p "Mount point en UNAVCO [ENTER para dejar en blanco]: " mp_unavco
cp $rutaplantilla $rutafinal
sed -i "s/output_pw=.*$/output_pw=$output_pw/g" $rutafinal
sed -i "s/mp_rtk2go=.*$/mp_rtk2go=$mp_rtk2go/g" $rutafinal
sed -i "s/corr_user_unavco=.*$/corr_user_unavco=$corr_user_unavco/g" $rutafinal
sed -i "s/corr_pw_unavco=.*$/corr_pw_unavco=$corr_pw_unavco/g" $rutafinal
sed -i "s/mp_unavco=.*$/mp_unavco=$mp_unavco/g" $rutafinal
