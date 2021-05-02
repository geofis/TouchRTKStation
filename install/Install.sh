#!/bin/sh

cd /home/pi/

apt-get update -y

# Install gfortran
apt install -y gfortran

# Install xterm
apt install -y xterm

# Install gpsd
apt install -y gpsd gpsd-clients python-gps

# Install pyqt5
apt-get install -y qt5-default pyqt5-dev pyqt5-dev-tools

# Install RTKLIB
#git clone -b rtklib_2.4.3 https://github.com/tomojitakasu/RTKLIB.git
git clone https://github.com/rtklibexplorer/RTKLIB.git

# Detect architecture
architecture=`uname -m`
if [[ $architecture == *"arm"* ]]
then
  sed -i "s/F77      = gfortran/F77      = arm-linux-gnueabihf-gfortran/g" ./RTKLIB/lib/iers/gcc/makefile
fi

# Symlink app dir
ln -s /home/pi/RTKLIB/app/consapp/* /home/pi/RTKLIB/app/

# Compile RTKLIB executables
cd ./RTKLIB/app/str2str/gcc/
make
cd ../../rtkrcv/gcc/
make
cd ../../convbin/gcc/
make
cd ../../../lib/iers/gcc
make
cd ../../../app/rnx2rtkp/gcc
make
cd ../../pos2kml/gcc/
make

# Create directories for bases and credentials
mkdir /home/pi/TouchRTKStation/{bases,.credenciales}

# Copy shortcuts to desktop
cp -avr /home/pi/TouchRTKStation/install/shortcuts/* /home/pi/Desktop

# Install LCD Driver. Uncomment if LCD is available
#cd /home/pi/
#wget http://www.waveshare.com/w/upload/0/00/LCD-show-170703.tar.gz
#tar xzvf LCD*.tar.gz
#cd ./LCD-show/
#chmod +x LCD4-show
#./LCD4-show
