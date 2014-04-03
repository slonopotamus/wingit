#!/bin/bash

set -e

DIR="$(dirname "${BASH_SOURCE[0]}")"
cd "${DIR}"
export DIR="$(pwd -W)"

# Sanitize PATH
export PATH="${PATH/.:/}"

export VC_ARCH="${1:-x86}"
export ARCH="${VC_ARCH/x86_amd64/amd64}"

export DESTDIR="${DIR}/stage-${ARCH}"

export ZLIB_PATH="${DIR}/zlib"
pushd "${ZLIB_PATH}"
cmd.exe /c "${DIR}/helper.bat nmake /f win32/Makefile.msc clean zlib1.dll"
# For git
ln -s zdll.lib zlib.lib
popd

export OPENSSLDIR="${DIR}/openssl"
# For CURL
export OPENSSL_PATH="${OPENSSLDIR}"
pushd "${OPENSSLDIR}"
if [ "$ARCH" = "amd64" ]; then
	cmd.exe /c "${DIR}/helper.bat perl Configure VC-WIN64A no-asm"
else
	cmd.exe /c "${DIR}/helper.bat perl Configure VC-WIN32 no-asm"
fi
# HACK, EOL troubles
sed -i 's/\\/\//g' ms/do_win64a.bat ms/do_ms.bat
# HACK, see http://stackoverflow.com/questions/7680189/openssl-cant-build-in-vc-2010
sed -i 's/chop;$/chop;s\/\\r$\/\/;/' util/mk1mf.pl
if [ "$ARCH" = "amd64" ]; then
	cmd.exe /c "${DIR}/helper.bat cmd.exe /c ms\\do_win64a.bat"
else
	cmd.exe /c "${DIR}/helper.bat cmd.exe /c ms\\do_ms.bat"
fi
cmd.exe /c "${DIR}/helper.bat nmake /f ms/ntdll.mak clean" || true
cmd.exe /c "${DIR}/helper.bat nmake /f ms/ntdll.mak"
# For git
cp -R inc32/* include
cp out32dll/ssleay32.lib out32dll/libeay32.lib .
popd

export CURLDIR="${DIR}/curl"
pushd "${CURLDIR}"
cmd.exe /c "${DIR}/helper.bat buildconf.bat"
popd
pushd "${CURLDIR}/lib"
cmd.exe /c "${DIR}/helper.bat nmake /f Makefile.vc6 clean"
cmd.exe /c "${DIR}/helper.bat nmake /f Makefile.vc6 MACHINE=${ARCH/amd64/x64} CFG=release-dll-ssl-dll-zlib-dll all"
# For git
cp libcurl_imp.lib "${CURLDIR}/libcurl.lib"
popd

pushd "${DIR}/git"
cmd.exe /c "${DIR}/helper.bat make MSVC=1 prefix=/ DEFAULT_EDITOR=/bin/vim.exe NO_TCLTK=1 CFLAGS=-Zi LDFLAGS=-debug clean install"
popd

mkdir -p "${DESTDIR}/cmd"
cmd.exe /c "helper.bat cl shell32.lib shlwapi.lib git-wrapper.c /Fe${DESTDIR}/cmd/git.exe"

cp "${ZLIB_PATH}/zlib1.dll" "${CURLDIR}/lib/libcurl.dll" "${OPENSSLDIR}/out32dll/libeay32.dll" \
	"${OPENSSLDIR}/out32dll/ssleay32.dll" "${DESTDIR}/bin"

mkdir -p mingw/bin

if [ ! -f mingw-get.zip ]; then
	wget -O mingw-get.zip http://downloads.sourceforge.net/project/mingw/Installer/mingw-get/mingw-get-0.6.2-beta-20131004-1/mingw-get-0.6.2-mingw32-beta-20131004-1-bin.zip
fi

unzip -o -d mingw mingw-get.zip
./mingw/bin/mingw-get.exe install msys-base msys-openssh msys-vim msys-perl

if [ ! -f mingw/msys/1.0/etc/curl-ca-bundle.crt ]; then
	./curl/lib/mk-ca-bundle.pl mingw/msys/1.0/etc/curl-ca-bundle.crt
fi

rsync --progress -h -a mingw/msys/1.0/ stage-${ARCH}

if [ -z "${WIX}" ]; then
	print "ERROR: WiX Toolset not installed"
	exit 1
fi

WIX_ARCH="${ARCH/amd64/x64}"

"${WIX}/bin/heat.exe" dir "${DESTDIR}" -dr INSTALLLOCATION -cg files -o wix-tmp/files-${ARCH}.wxs -srd -sfrag -ag -sw5150 -nologo
"${WIX}/bin/candle.exe" -arch ${WIX_ARCH} wix-tmp/files-${ARCH}.wxs -o wix-tmp/files-${WIX_ARCH}.wixobj -nologo
"${WIX}/bin/candle.exe" -arch ${WIX_ARCH} wingit.wix -o wix-tmp/wingit-${WIX_ARCH}.wixobj -nologo \
	"-dGitVersion=$(awk -F ' = ' '{print $2}' git/GIT-VERSION-FILE)"
"${WIX}/bin/light.exe" -sw1076 -ext WixUIExtension -o WinGit-${WIX_ARCH}.msi -b stage-${ARCH} -nologo \
	wix-tmp/wingit-${WIX_ARCH}.wixobj wix-tmp/files-${WIX_ARCH}.wixobj

