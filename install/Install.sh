#!/bin/sh

cd /home/pi/

apt-get update -y

# Install xterm
apt -y install xterm

# Install pyqt5
apt-get install -y qt5-default pyqt5-dev pyqt5-dev-tools

# Install RTKLIB
git clone -b rtklib_2.4.3 https://github.com/tomojitakasu/RTKLIB.git

ln -s /home/pi/RTKLIB/app/consapp/* /home/pi/RTKLIB/app/

cd ./RTKLIB/app/str2str/gcc/
make
cd ../../rtkrcv/gcc/
make

cp -avr /home/pi/TouchRTKStation/install/shortcuts/* /home/pi/Desktop

# Install LCD Driver. Uncomment if LCD is available
#cd /home/pi/
#wget http://www.waveshare.com/w/upload/0/00/LCD-show-170703.tar.gz
#tar xzvf LCD*.tar.gz
#cd ./LCD-show/
#chmod +x LCD4-show
#./LCD4-show
