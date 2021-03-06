#!/bin/bash

LOCATION=/media/administrator/Boss/compiler
MXE_PATH=$LOCATION/mxe/

echo We are assuming the location of this script is $LOCATION
echo If not, please terminate and edit this script and change it to the appropriate location
echo
echo We are now installing.....

sudo apt-get update
sudo apt-get install -y p7zip-full autoconf automake autopoint bash bison bzip2 cmake flex gettext git g++ gperf intltool libffi-dev libtool libltdl-dev libssl-dev libxml-parser-perl make openssl patch perl pkg-config python ruby scons sed unzip wget xz-utils
sudo apt-get install -y g++-multilib libc6-dev-i386 libtool-bin libgtk2.0-dev
sudo apt-get install -y autoconf automake autopoint bash bison bzip2 p7zip-full cmake flex gettext git g++ gperf intltool libffi-dev libtool libltdl-dev libssl-dev libxml-parser-perl make openssl patch perl pkg-config python ruby scons sed unzip wget xz-utils

echo
echo We will now compile the libraries...

function compiledb {
	sed -i "s/WinIoCtl.h/winioctl.h/g" src/dbinc/win_db.h
	mkdir build_mxe
	cd build_mxe

	CC=$MXE_PATH/usr/bin/i686-w64-mingw32.static-gcc \
	CXX=$MXE_PATH/usr/bin/i686-w64-mingw32.static-g++ \
	../dist/configure \
		--disable-replication \
		--enable-mingw \
		--enable-cxx \
		--host x86 \
		--prefix=$MXE_PATH/usr/i686-w64-mingw32.static

	make
	make install
}

cd mxe
echo Compiling the Boost Libaries
echo
make MXE_TARGETS="i686-w64-mingw32.static" boost

echo Compiling the Qt Libraries
make MXE_TARGETS="i686-w64-mingw32.static" qttools
make MXE_TARGETS="i686-w64-mingw32.static" qt

echo Compiling the Berkley DB Libaries and Includes
cd ../berkleydb
compiledb

function compileupnp {
        CC=$MXE_PATH/usr/bin/i686-w64-mingw32.static-gcc \
        AR=$MXE_PATH/usr/bin/i686-w64-mingw32.static-ar \
        CFLAGS="-DSTATICLIB -I$MXE_PATH/usr/i686-w64-mingw32.static/include" \
        LDFLAGS="-L$MXE_PATH/usr/i686-w64-mingw32.static/lib" \
        make libminiupnpc.a

        mkdir $MXE_PATH/usr/i686-w64-mingw32.static/include/miniupnpc
        cp *.h $MXE_PATH/usr/i686-w64-mingw32.static/include/miniupnpc
        cp libminiupnpc.a $MXE_PATH/usr/i686-w64-mingw32.static/lib
}

echo Compiling the MiniUPNPC Libraries
cd $LOCATION/miniupnpc
compileupnp

function compilesecp {
	CC=$MXE_PATH/usr/bin/i686-w64-mingw32.static-gcc \
        AR=$MXE_PATH/usr/bin/i686-w64-mingw32.static-ar \
        CFLAGS="-DSTATICLIB -I$MXE_PATH/usr/i686-w64-mingw32.static/include" \
        LDFLAGS="-L$MXE_PATH/usr/i686-w64-mingw32.static/lib" \
        ./autogen.sh

	./configure \
                --disable-replication \
                --enable-mingw \
                --enable-cxx \
                --host x86 \
                --prefix=$MXE_PATH/usr/i686-w64-mingw32.static

	make
	make install
}

echo Compiling the SECP256k1
cd $LOCATION/secp256k1
compilesecp
cd $LOCATION

function compilegmp {
        CC=$MXE_PATH/usr/bin/i686-w64-mingw32.static-gcc \
        AR=$MXE_PATH/usr/bin/i686-w64-mingw32.static-ar \
        CFLAGS="-DSTATICLIB -I$MXE_PATH/usr/i686-w64-mingw32.static/include" \
        LDFLAGS="-L$MXE_PATH/usr/i686-w64-mingw32.static/lib"

	./configure --disable-replication \
                --enable-mingw \
                --enable-cxx \
                --host x86 \
                --prefix=$MXE_PATH/usr/i686-w64-mingw32.static

	make
        make install
}

echo Compiling the GMP Libararies
cd $LOCATION/gmp
compilegmp
cd $LOCATION

function cevent { 
        CC=$MXE_PATH/usr/bin/i686-w64-mingw32.static-gcc \
        AR=$MXE_PATH/usr/bin/i686-w64-mingw32.static-ar \
        CFLAGS="-DSTATICLIB -I$MXE_PATH/usr/i686-w64-mingw32.static/include" \
        LDFLAGS="-L$MXE_PATH/usr/i686-w64-mingw32.static/lib"

        ./configure \
                --disable-replication \
                --enable-mingw \
                --enable-cxx \
                --host x86 \
                --prefix=$MXE_PATH/usr/i686-w64-mingw32.static

	make
	make install
}

echo Compiling the Event Libraries
cd $LOCATION/event
cevent
cd $LOCATION
