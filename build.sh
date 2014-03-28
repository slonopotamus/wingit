#!/bin/bash

set -e

DIR="$(dirname "${BASH_SOURCE[0]}")"
cd "${DIR}"
export DIR="$(pwd -W)"

# Sanitize PATH
export PATH="${PATH/.:/}"

export VC_ARCH="${1:-x86}"
export ARCH="${VC_ARCH/x86_amd64/amd64}"

LIBS="${DIR}/lib"
export DESTDIR="${DIR}/stage-${ARCH}"

export ZLIB_PATH="${DIR}/zlib"
pushd "${ZLIB_PATH}"
cmd /c "${DIR}/helper.bat nmake /f win32/Makefile.msc clean zlib1.dll"
# For git
ln -s zdll.lib zlib.lib
popd

export OPENSSLDIR="${DIR}/openssl"
# For CURL
export OPENSSL_PATH="${OPENSSLDIR}"
pushd "${OPENSSLDIR}"
if [ "$ARCH" = "amd64" ]; then
	cmd /c "${DIR}/helper.bat perl Configure VC-WIN64A no-asm"
else
	cmd /c "${DIR}/helper.bat perl Configure VC-WIN32 no-asm"
fi
# HACK, EOL troubles
sed -i 's/\\/\//g' ms/do_win64a.bat ms/do_ms.bat
# HACK, see http://stackoverflow.com/questions/7680189/openssl-cant-build-in-vc-2010
sed -i 's/chop;$/chop;s\/\\r$\/\/;/' util/mk1mf.pl
if [ "$ARCH" = "amd64" ]; then
	cmd /c "${DIR}/helper.bat cmd /c ms\\do_win64a.bat"
else
	cmd /c "${DIR}/helper.bat cmd /c ms\\do_ms.bat"
fi
cmd /c "${DIR}/helper.bat nmake /f ms/ntdll.mak clean" || true
cmd /c "${DIR}/helper.bat nmake /f ms/ntdll.mak"
# For git
cp -R inc32/* include
cp out32dll/ssleay32.lib out32dll/libeay32.lib .
popd

export CURLDIR="${DIR}/curl"
pushd "${CURLDIR}"
cmd /c "${DIR}/helper.bat buildconf.bat"
popd
pushd "${CURLDIR}/lib"
cmd /c "${DIR}/helper.bat nmake /f Makefile.vc6 clean"
cmd /c "${DIR}/helper.bat nmake /f Makefile.vc6 MACHINE=${ARCH/amd64/x64} CFG=release-dll-ssl-dll-zlib-dll all"
# For git
cp libcurl_imp.lib "${CURLDIR}/libcurl.lib"
cp libcurl_imp.lib "${CURLDIR}/libcurl.lib"
popd

pushd "${DIR}/git"
cmd /c "${DIR}/helper.bat make MSVC=1 prefix=/ NO_TCLTK=1 NO_PERL=1 clean install"
popd

cp "${ZLIB_PATH}/zlib1.dll" "${CURLDIR}/lib/libcurl.dll" "${OPENSSLDIR}/out32dll/libeay32.dll" "${OPENSSLDIR}/out32dll/ssleay32.dll" "${DESTDIR}/bin"
