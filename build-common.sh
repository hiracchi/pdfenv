#!/bin/bash

set -u
umask 0022
PATH='/usr/bin:/bin'
IFS=$(printf ' \t\n_'); IFS=${IFS%_}
export IFS LC_ALL=C LANG=C PATH

source ./utils/utils.sh
#source ./env.sh

# check workdir
if [ ! -d ${WORKDIR} ]; then
    mkdir ${WORKDIR}
fi

# set parallel build
CPUS=`get-num-of-cpu-cores`
MAKE_ARGS_PARALLEL="-j $((${CPUS}+1))"
