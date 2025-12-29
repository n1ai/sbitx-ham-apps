#!/bin/bash

# Exit on any error
set -e

# Set TOP if it isn't already set in the environment
: "${TOP:=/home/pi}"
printf "$0: TOP: >%s<\n" $TOP
[ -z "${TOP}" ] && false

banner "InstCuSDR"
banner "Pre-Reqs"
echo "Starting installation process..."

# Update package lists
echo "Updating package lists..."
sudo apt update

# Install dependencies
echo "Installing dependencies..."
sudo apt install -y \
    libwxgtk3.2-dev \
    libpulse-dev \
    libasound2-dev \
    libportaudio2 \
    portaudio19-dev \
    libliquid-dev \
    libsoapysdr-dev \
    soapysdr-tools \
    soapysdr-module-rtlsdr \
    librtlsdr-dev \
    libgtk-3-dev \
    freeglut3-dev \
    cmake \
    git

################################################################################
# Don't build SoapySDR since we install libsoapysdr-dev and soapysdr-tools from
# the OS repositories above
################################################################################
# # Install SoapySDR
# echo "Installing SoapySDR..."
# cd ~
# rm -rf SoapySDR
# git clone https://github.com/pothosware/SoapySDR.git
# cd SoapySDR
# mkdir -p build && cd build
# cmake .. -DCMAKE_BUILD_TYPE=Release
# make -j4
# sudo make install
# sudo ldconfig

# Install SDRplay API only if necessary
n=`ldconfig -p | grep sdrplay | wc -l`
if [ $n -eq 0 ] 
then
  banner "SdrPlayAPI"
  SPAPI="SDRplay_RSP_API-Linux-3.15.2.run"
  echo "Installing SDRplay API..."
  mkdir -p ${TOP}/SDRplay-API
  pushd ${TOP}/SDRplay-API
  if [ ! -f "${SPAPI}" ] 
  then 
    wget -nc https://www.sdrplay.com/software/${SPAPI}
    echo "Running SDRplay installer (press Enter, then q, then y, then y when prompted)"
   sudo bash ${SPAPI}
  fi
  popd
fi

# Install SoapySDRPlay
banner "SoapySPlay"
echo "Installing SoapySDRPlay..."
pushd ${TOP}
[ ! -d  SoapySDRPlay ] && \
  git clone https://github.com/pothosware/SoapySDRPlay.git
cd SoapySDRPlay
git pull 
rm -rf build
mkdir -p build && cd build
cmake ..
make -j4
sudo make install
sudo ldconfig
SoapySDRUtil --info
popd

# Install AirSpyHF+ API
banner "AirSpyHF"
echo "Installing AirSpyHF+ API..."
pushd ${TOP}
[ ! -d  airspyhf ] && \
  git clone https://github.com/airspy/airspyhf.git
cd airspyhf
git pull
rm -rf build 
mkdir build && cd build
cmake .. -Wno-dev -DINSTALL_UDEV_RULES=ON -DUSE_UACCESS_RULES=ON |& tee cmake.log
make -j4 |& tee make.log
sudo make install
sudo ldconfig
popd

# Install SoapyAirspyHF
banner "SoapyAirSpy"
echo "Installing SoapyAirspyHF..."
pushd ${TOP}
rm -rf SoapyAirspyHF
[ ! -d  SoapyAirspyHF ] && \
  git clone https://github.com/pothosware/SoapyAirspyHF.git
cd SoapyAirspyHF
git pull
rm -rf build
mkdir build && cd build
cmake .. |& tee cmake.log
make -j4 |& tee make.log
sudo make install
sudo ldconfig
SoapySDRUtil --info
popd

################################################################################
# Don't build SoapyRTLSDR since we install soapysdr-module-rtlsdr from # the OS 
# repositories above
################################################################################
# # Install SoapyRTLSDR
# echo "Installing SoapyRTLSDR..."
# cd ~
# rm -rf SoapyRTLSDR
# git clone https://github.com/pothosware/SoapyRTLSDR.git
# cd SoapyRTLSDR
# mkdir -p build && cd build
# cmake .. -DCMAKE_BUILD_TYPE=Release
# make -j4
# sudo make install
# sudo ldconfig

# Install CubicSDR WITH AUDIO SUPPORT
banner "CubicSDR"
echo "Installing CubicSDR (with ALSA / Audio IQ support)..."
pushd ${TOP}
[ ! -d  CubicSDR ] && \
  git clone https://github.com/cjcliffe/CubicSDR.git
cd CubicSDR
git pull
rm -rf build
mkdir -p build && cd build
# Note: -DUSE_AUDIO=ON and -DUSE_PORTAUDIO=ON do nothing - what was the intent?
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DUSE_HAMLIB=ON \
    -DUSE_AUDIO=ON \
    -DUSE_PORTAUDIO=ON \
    	|& tee cmake.log
make -j4
sudo make install
sudo ldconfig
popd

# Install Icon Fix
echo "Fix CubicSDR Menu Icon..."
pushd ${TOP}/sbitx-ham-apps/cubicsdr
sudo bash ./cubicsdr-icon-fix.sh
popd

# Done!
echo "Installation complete!"
banner "NOTICE!:"
echo "Reboot or log out/in before starting CubicSDR."

