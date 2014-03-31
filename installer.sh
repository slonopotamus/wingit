#!/bin/bash

set -e

DIR="$(dirname "${BASH_SOURCE[0]}")"
cd "${DIR}"

if [ -z "${WIX}" ]; then
	print "ERROR: WiX Toolset not installed"
	exit 1
fi

ARCH="${1:-x86}"
WIX_ARCH="${ARCH/amd64/x64}"

mkdir -p mingw/bin

if [ ! -f mingw-get.zip ]; then
	wget -O mingw-get.zip http://downloads.sourceforge.net/project/mingw/Installer/mingw-get/mingw-get-0.6.2-beta-20131004-1/mingw-get-0.6.2-mingw32-beta-20131004-1-bin.zip
fi

unzip -o -d mingw mingw-get.zip
./mingw/bin/mingw-get.exe install msys-base msys-openssh

rsync --progress -h -a mingw/msys/1.0/ stage-${ARCH}/

"${WIX}/bin/heat.exe" dir stage-${ARCH} -dr INSTALLLOCATION -cg files -o wix-tmp/files-${ARCH}.wxs -srd -sfrag -suid -ag -sw5150 -nologo
"${WIX}/bin/candle.exe" -arch ${WIX_ARCH} wix-tmp/files-${ARCH}.wxs -o wix-tmp/files-${WIX_ARCH}.wixobj -nologo
"${WIX}/bin/candle.exe" -arch ${WIX_ARCH} wingit.wix -o wix-tmp/wingit-${WIX_ARCH}.wixobj -nologo
"${WIX}/bin/light.exe" -sw1076 -ext WixUIExtension -o WinGit-${WIX_ARCH}.msi -b stage-${ARCH} -nologo \
	 wix-tmp/wingit-${WIX_ARCH}.wixobj wix-tmp/files-${WIX_ARCH}.wixobj
