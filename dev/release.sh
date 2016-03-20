#!/usr/bin/env bash

echo -e "\nBuild Release"
echo "--------------"
read -p "Version: " VER
if [ -z $VER ]; then
    echo "No version given. Exiting."
    exit 1
fi

# The love version to build against
LOVER="0.9.2"

# Win32
love-release -W32 -t "mmscope-$VER" -l $LOVER -v $VER -x image-sources\/\* -x dev\/\* -x love-android-sdl2\/\* -x research\/\*
