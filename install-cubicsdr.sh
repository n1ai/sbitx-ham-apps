#!/bin/bash

# Exit on any error
set -e

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

# Install SDRplay API
echo "Installing SDRplay API..."
mkdir -p ~/code/hamradio/SDRplay-API
pushd ~/code/hamradio/SDRplay-API
wget -nc https://www.sdrplay.com/software/SDRplay_RSP_API-Linux-3.15.2.run
chmod +x SDRplay_RSP_API-Linux-3.15.2.run
echo "Running SDRplay installer (press Enter, then q, then y, then y when prompted)"
sudo ./SDRplay_RSP_API-Linux-3.15.2.run
popd

# Install SoapySDRPlay
echo "Installing SoapySDRPlay..."
pushd ~/code/hamradio
rm -rf SoapySDRPlay
git clone https://github.com/pothosware/SoapySDRPlay.git
cd SoapySDRPlay
mkdir -p build && cd build
cmake ..
make -j4
sudo make install
sudo ldconfig
SoapySDRUtil --info
popd

# Install AirSpyHF+ API
echo "Installing AirSpyHF+ API..."
pushd ~/code/hamradio
git clone https://github.com/airspy/airspyhf.git
cd airspyhf
mkdir build
cd build
cmake .. -Wno-dev -DINSTALL_UDEV_RULES=ON -DUSE_UACCESS_RULES=ON |& tee cmake.log
make -j4 |& tee make.log
sudo make install
sudo ldconfig
popd

# Install SoapyAirspyHF
echo "Installing SoapyAirspyHF..."
pushd ~/code/hamradio
git clone https://github.com/pothosware/SoapyAirspyHF.git
cd SoapyAirspyHF
mkdir build
cd build
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
sudo ldconfig

# Install CubicSDR WITH AUDIO SUPPORT
echo "Installing CubicSDR (with ALSA / Audio IQ support)..."
pushd ~/code/hamradio
rm -rf CubicSDR
git clone https://github.com/cjcliffe/CubicSDR.git
cd CubicSDR
mkdir -p build && cd build
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DUSE_HAMLIB=ON \
    -DUSE_AUDIO=ON \
    -DUSE_PORTAUDIO=ON \
    	|& tee cmake.log
make -j8
sudo make install
sudo ldconfig
popd

# Install Icon Fix
echo "Fix CubicSDR Menu Icon..."
pushd ~/code/hamradio/sbitx-ham-apps/cubicsdr
sudo chmod +x ./cubicsdr-icon-fix.sh
sudo ./cubicsdr-icon-fix.sh
popd

# Done!
echo "Installation complete!"
popd
echo
echo "IMPORTANT:"
echo "Reboot or log out/in before starting CubicSDR."

