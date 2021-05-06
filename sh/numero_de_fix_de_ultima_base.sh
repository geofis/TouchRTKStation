#!/bin/bash

dir=`ls -td /home/pi/TouchRTKStation/bases/* | head -n 1`
if [ -f "$dir/tmp_out.pos" ]
then
nfix=`tail -n +2 $dir/tmp_out.pos | awk '$6==1 { print }' | wc -l`
echo "$nfix FIXES tiene la base más reciente.
Se encuentra en $dir"
else
echo "Actualmente, no se está generando archivo de posiciones RTK"
fi
read -p "Presiona ENTER para salir" x

