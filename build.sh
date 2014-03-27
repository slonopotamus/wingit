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
export ZLIB_PATH="${DIR}/zlib"
export OPENSSLDIR="${LIBS}/openssl-1.0.1.24/${ARCH}"
export CURLDIR="${LIBS}/curl-7.30.0.2/${ARCH}"
export DESTDIR="${DIR}/stage-${ARCH}"

pushd "${ZLIB_PATH}"
cmd /c "${DIR}/helper.bat nmake /f win32/Makefile.msc clean zlib1.dll"
ln -s zdll.lib zlib.lib
popd

pushd "${DIR}/git"
cmd /c "${DIR}/helper.bat make MSVC=1 INLINE=__inline prefix=/ NO_TCLTK=1 V=1 NO_PERL=1 install"
popd

find "${ZLIB_PATH}" "${OPENSSLDIR}" "${CURLDIR}" -name \*.dll -print0 | xargs -0 -I{} cp "{}" "${DESTDIR}/bin"
