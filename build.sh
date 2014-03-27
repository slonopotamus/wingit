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
export ZLIB_PATH="${LIBS}/zlib-1.2.8.1/${ARCH}"
export OPENSSLDIR="${LIBS}/openssl-1.0.1.24/${ARCH}"
export CURLDIR="${LIBS}/curl-7.30.0.2/${ARCH}"
export DESTDIR="${DIR}/stage-${ARCH}"

cmd /c "helper.bat make -C '${DIR}/git' MSVC=1 INLINE=__inline prefix=/ NO_TCLTK=1 V=1 NO_PERL=1 install"
find "${OPENSSLDIR}" "${ZLIB_PATH}" "${CURLDIR}" -name \*.dll -print0 | xargs -0 -I{} cp "{}" "${DESTDIR}/bin"
