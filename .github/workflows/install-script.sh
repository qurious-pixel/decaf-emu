#!/bin/bash

set -ex

GCCVER=10
UBUNTU_VER=focal

LLD_BINARY=lld-${LLVMVER}
GCC_BINARY=gcc-${GCCVER}
GXX_BINARY=g++-${GCCVER}

# Packages - Build Environment
declare -a BUILD_PACKAGES=(
    "$GCC_BINARY" 
    "$GXX_BINARY"
    "libxcb-keysyms1"
    "libxcb-randr0"
    "libxcb-render-util0"
    "libxcb-icccm4"
    "libxcb-image0-dev"
    "libboost-all-dev"
    "liblz4-dev"
    "libcurl4-openssl-dev"
    "libssl-dev"
    "libopus-dev"
    "libzstd-dev"
    "libasound2-dev"
    "libpulse-dev"
    "pulseaudio"
    "python3-setuptools"
    "libxi-dev"
    "libavcodec-dev"
    "libavutil-dev"
    "libavfilter-dev"
    "libva-dev"
    "libswscale-dev"
    "libudev-dev"
    "libusb-1.0-0-dev"
    "libevdev-dev"
    "libavformat-dev"
    "libavdevice-dev"
    "libfmt-dev"
    "libwayland-dev"
    "libxrandr-dev"
    "libglu1-mesa-dev"
    "zenity"
    "ccache"
    "ninja-build"
)

# Install packages needed for building
BUILD_PACKAGE_STR=""
for i in "${BUILD_PACKAGES[@]}"; do
  BUILD_PACKAGE_STR="${BUILD_PACKAGE_STR} ${i}"
done

sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
sudo apt-get update
sudo apt-get -y install ${BUILD_PACKAGE_STR}
pip3 install wheel
pip3 install --upgrade conan && conan user runner
conan --version

sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-${GCCVER} 10
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-${GCCVER} 10
gcc --version
g++ --version

echo "install source packages"

if [[ ! -e $HOME/.ccache ]]; then
	mkdir $HOME/.ccache 
fi 
CACHEDIR=$HOME/.ccache
ls -al $CACHEDIR

#CMAKEVER=3.20.3
#cd $CACHEDIR
#if [[ ! -e cmake-${CMAKEVER}-linux-x86_64.sh ]]; then
#	curl -sLO https://cmake.org/files/v${CMAKEVER%.*}/cmake-${CMAKEVER}-linux-x86_64.sh
#fi
#sudo sh cmake-${CMAKEVER}-linux-x86_64.sh --prefix=/usr --skip-license
cmake --version
###############################################

LIBZIPVER=1.8.0
cd $CACHEDIR
if [[ ! -e libzip-${LIBZIPVER} ]]; then
	curl -sLO https://libzip.org/download/libzip-${LIBZIPVER}.tar.gz
	tar -xzf libzip-${LIBZIPVER}.tar.gz
	cd libzip-${LIBZIPVER}
	mkdir build && cd build
	cmake .. -DCMAKE_INSTALL_PREFIX=/usr
	make && cd ../../
	rm libzip-${LIBZIPVER}.tar.gz
fi
sudo make -C libzip-${LIBZIPVER}/build install 
###############################################

SDL2VER=2.0.22
#SDL2
cd $CACHEDIR
if [[ ! -e SDL2-${SDL2VER} ]]; then
	curl -sLO https://libsdl.org/release/SDL2-${SDL2VER}.tar.gz
	tar -xzf SDL2-${SDL2VER}.tar.gz
	cd SDL2-${SDL2VER}
	./configure --prefix=/usr
	make && cd ../
	rm SDL2-${SDL2VER}.tar.gz
fi
sudo make -C SDL2-${SDL2VER} install
###############################################

VULKANVER=1.3.211
#VULKANHEADERS
cd $CACHEDIR
if [[ ! -e Vulkan-Headers-${VULKANVER} ]]; then
	curl -sL -o Vulkan-Headers.tar.gz https://github.com/KhronosGroup/Vulkan-Headers/archive/v${VULKANVER}.tar.gz
	tar -xf Vulkan-Headers.tar.gz
	cd Vulkan-Headers-${VULKANVER}/
	mkdir build && cd build
	cmake ../ -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER=$GCC_BINARY -DCMAKE_CXX_COMPILER=$GXX_BINARY -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_INSTALL_LIBDIR=/usr/
	ninja
	cd ../../
	rm Vulkan-Headers.tar.gz
fi
sudo ninja -C Vulkan-Headers-${VULKANVER}/build install
###############################################

#VULKANLOADER
cd $CACHEDIR
if [[ ! -e Vulkan-Loader-${VULKANVER} ]]; then
	curl -sL -o Vulkan-Loader.tar.gz https://github.com/KhronosGroup/Vulkan-Loader/archive/v${VULKANVER}.tar.gz
	tar -xf Vulkan-Loader.tar.gz
	cd Vulkan-Loader-${VULKANVER}/
	mkdir build && cd build
	cmake ../ -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER=$GCC_BINARY -DCMAKE_CXX_COMPILER=$GXX_BINARY \
	-DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_INSTALL_LIBDIR=/usr/lib -DCMAKE_INSTALL_SYSCONFDIR=/etc -DCMAKE_INSTALL_DATADIR=/share
	ninja
	cd ../../
	rm Vulkan-Loader.tar.gz
fi
sudo ninja -C Vulkan-Loader-${VULKANVER}/build install
###############################################	

#GLSLANG	
cd $CACHEDIR
if [[ ! -e glslang/ ]]; then
	git clone https://github.com/KhronosGroup/glslang.git
	cd glslang
	mkdir -p build && cd build
	cmake .. -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="/usr"
	ninja
	cd ../../
fi
sudo ninja -C glslang/build install
glslangValidator --version
###############################################

#LIBBOOST
cd $CACHEDIR
if [[ ! -e boost_1_75_0/ ]]; then
	wget https://github.com/yuzu-emu/ext-linux-bin/raw/main/boost/boost_1_75_0.tar.xz
	tar xvf boost_1_75_0.tar.xz
	sudo chown -R root:root boost_1_75_0/
	rm boost_1_75_0.tar.xz
fi
sudo cp -r boost_1_75_0/include boost_1_75_0/lib /usr  
###############################################

LIBUSBVER=1.0.24
#LIBUSB
cd $CACHEDIR
if [[ ! -e libusb-${LIBUSBVER} ]]; then
	curl -sLO https://github.com/libusb/libusb/releases/download/v${LIBUSBVER}/libusb-${LIBUSBVER}.tar.bz2
	tar -xvf libusb-${LIBUSBVER}.tar.bz2
	cd libusb-${LIBUSBVER}
	./configure
	make && cd ../
	rm libusb-${LIBUSBVER}.tar.bz2
fi
sudo make -C libusb-${LIBUSBVER} install
###############################################

HIDAPIVER=0.11.0
#LIBHIDAPI
cd $CACHEDIR
if [[ ! -e hidapi-hidapi-${HIDAPIVER} ]]; then
	curl -sLO https://github.com/libusb/hidapi/archive/refs/tags/hidapi-${HIDAPIVER}.tar.gz
	tar -xvf hidapi-${HIDAPIVER}.tar.gz
	cd hidapi-hidapi-${HIDAPIVER}
	./bootstrap
	./configure --prefix=/usr
	make && cd ../
	rm hidapi-${HIDAPIVER}.tar.gz
fi
sudo make -C hidapi-hidapi-${HIDAPIVER} install
###############################################

LIBUVVER=v1.43.0
#LIBUV
cd $CACHEDIR
if [[ ! -e libuv-${LIBUVVER} ]]; then
	curl -sSLO https://dist.libuv.org/dist/v1.43.0/libuv-${LIBUVVER}.tar.gz
	tar -xvf libuv-${LIBUVVER}.tar.gz
	cd libuv-${LIBUVVER}
	sh autogen.sh
	./configure --prefix=/usr
	make && cd ../
	rm libuv-${LIBUVVER}.tar.gz
fi
sudo make -C libuv-${LIBUVVER} install
###############################################

CARESVER=1.18.1
#C-ARES
cd $CACHEDIR
if [[ ! -e c-ares-${CARESVER} ]]; then
	curl -sSLO https://c-ares.org/download/c-ares-${CARESVER}.tar.gz
	tar -xvf c-ares-${CARESVER}.tar.gz
	cd c-ares-${CARESVER}
	./configure --prefix=/usr
	make && cd ../
	rm c-ares-${CARESVER}.tar.gz
fi
sudo make -C c-ares-${CARESVER} install
###############################################

PELFVER=0.14
#PATCHELF
cd $CACHEDIR
if [[ ! -e patchelf-${PELFVER}* ]]; then
	curl -sSfLO https://github.com/NixOS/patchelf/releases/download/${PELFVER}/patchelf-${PELFVER}.tar.bz2        
	tar xvf patchelf-${PELFVER}.tar.bz2
	cd patchelf-${PELFVER}*/ 
	./configure
	make && cd ../
	rm patchelf-${PELFVER}.tar.bz2
fi
sudo make -C patchelf-${PELFVER}* install
###############################################
sudo apt-get clean autoclean && sudo apt-get autoremove --yes && sudo rm -rf /var/lib/apt /var/lib/cache /var/lib/log
