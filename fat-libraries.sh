#!/bin/bash

PJSIP_PATH="trunk"
LIBRARY_PATH="output"
FAT_LIBRARY_PATH="$LIBRARY_PATH/unified"
DEVPATH="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer"

ARCH_LIST="i386 armv7 armv7s arm64"

function mkdirArch
{
    echo mkdirARch

    if [ ! -d "$LIBRARY_PATH" ]; then
        echo mkdir $LIBRARY_PATH
        mkdir $LIBRARY_PATH
    fi

    for arch in $ARCH_LIST;
    do
        if [ ! -d "$LIBRARY_PATH/$arch" ]; then
            echo mkdir $LIBRARY_PATH/$arch
            mkdir $LIBRARY_PATH/$arch
        fi
    done
}

function makeLibrary
{
    echo makeLibrary
    for arch in $ARCH_LIST;
    do
        cd $PJSIP_PATH

        if [ "$arch" == "i386" ]
        then
            ARCH="-arch $arch" CFLAGS="-O2 -m32 -mios-simulator-version-min=5.0" LDFLAGS="-O2 -m32 -mios-simulator-version-min=5.0" \
                DEVPATH="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer" \
                ./configure-iphone --prefix=`pwd`/$LIBRARY_PATH/$arch/ && make dep && make clean && make
        else
            ARCH="-arch $arch" ./configure-iphone --prefix=`pwd`/$LIBRARY_PATH/$arch/ && make dep && make clean && make
        fi

        libraryList=`find . -name *arm-apple-darwin9.a`
        cd ..

        for lib in $libraryList
        do
            mv $PJSIP_PATH/$lib ./$LIBRARY_PATH/$arch/
        done
    done
}

function makeFatLibraries
{
    echo makeFatLibraries
    if [ ! -d "$FAT_LIBRARY_PATH" ]; then
        echo mkdir $FAT_LIBRARY_PATH
        mkdir $FAT_LIBRARY_PATH
    fi

    libraryList=`find ./$LIBRARY_PATH/armv7/ -name *arm-apple-darwin9.a`

    echo $libraryList


    for LIB_NAME in $libraryList
    do
        echo $LIB_NAME
        lipoArchArgs=""
        for arch in $ARCH_LIST;
        do
            lipoArchArgs="$lipoArchArgs -arch $arch ./$LIBRARY_PATH/$arch/`basename $LIB_NAME`"
        done

        echo $lipoArchArgs | xargs lipo -create -output ./$FAT_LIBRARY_PATH/`basename $LIB_NAME`
        lipo -info ./$FAT_LIBRARY_PATH/`basename $LIB_NAME`
    done
}


mkdirArch
makeLibrary
makeFatLibraries

