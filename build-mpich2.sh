#!/bin/bash

source buildenv.sh

VERSION="1.5"
CONFIG_OPT="\
 --prefix=${MY_PREFIX}/mpich2 \
 --enable-static \
"

tar xvfz ${SRCDIR}/mpich2-${VERSION}.tar.gz
cd mpich2-${VERSION}
mkdir build
cd build
../configure ${CONFIG_OPT} 2>&1 | tee out.configure
make 2>&1 | tee out.make
make install 2>&1 | tee out.make_install

