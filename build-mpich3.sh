#!/bin/bash

source buildenv.sh

VERSION="3.1.4"
CONFIG_OPT="\
 --prefix=${MY_PREFIX}/mpich-${VERSION} \
 --disable-silent-rules \
 --enable-static \
"

CFLAGS="${CFLAGS} -D_XOPEN_SOURCE=500"
CXXFLAGS="${CXXFLAGS} -D_XOPEN_SOURCE=500"

tar xvfz ${SRCDIR}/mpich-${VERSION}.tar.gz
cd mpich-${VERSION}
mkdir build
cd build
../configure ${CONFIG_OPT} 2>&1 | tee out.configure
make 2>&1 | tee out.make
make install 2>&1 | tee out.make_install

