#!/bin/bash

# initialize script
set -u
umask 0022
PATH='/usr/bin:/bin'
IFS=$(printf ' \t\n_'); IFS=${IFS%_}
export IFS LC_ALL=C LANG=C PATH


# parse OPTION
PROGNAME=$(basename $0)
CWD=`pwd`

usage()
{
    echo "Usage: $PROGNAME [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help"
    echo "  -c, --compiler COMPILER [gnu, intel, pgi]"
    echo "  -l, --lib      LINEAR ALGEBRA PACKAGE [netlib, openblas]"
    echo "  -m, --mpi      MPI PACKAGE [openmpi, openmpi2, mpich]"
}

ARGS=""
ARG_C="gnu"
ARG_L="netlib"
ARG_M="openmpi"

#for OPT in "$@"
while [ $# -gt 0 ]
do
    OPT=$1
    case "$OPT" in
        '-h' | '--help')
            usage
            exit 1
            ;;

        '-c' | '--compiler')
            if [ $# -lt 2 ] || [ ! -z "`echo "$2" | grep -E "^-+"`" ]; then
                echo "$PROGNAME: option requires an argument -- $1" 1>&2
                exit 1
            fi
            ARG_C="$2"
            shift 2
            ;;

        '-l' | '--lib')
            if [ $# -lt 2 ] || [ ! -z "`echo "$2" | grep -E "^-+"`" ]; then
                echo "$PROGNAME: option requires an argument -- $1" 1>&2
                exit 1
            fi
            ARG_L="$2"
            shift 2
            ;;

        '-m' | '--mpi')
            if [ $# -lt 2 ] || [ ! -z "`echo "$2" | grep -E "^-+"`" ]; then
                echo "$PROGNAME: option requires an argument -- $1" 1>&2
                exit 1
            fi
            ARG_M="$2"
            shift 2
            ;;

        '--' | '-')
            shift 1
            ARGS="${ARGS} $@"
            break
            ;;

        -*)
            echo "$PROGNAME: illegal option -- '$(echo $1 | sed 's/^-*//')'" 1>&2
            exit 1
            ;;

        *)
            ARGS="${ARGS} $1"
            shift 1
            ;;
    esac
done


# check ARGS
check_ARGS()
{
    if [ -z "${ARGS}" ]; then
        echo "$PROGNAME: too few arguments" 1>&2
        echo "try '$PROGNAME --help' for more information." 1>&2
        exit 1
    fi
}


# MAIN func ============================================================
env_common()
{
    export SRCDIR="${CWD}/archives"
    export WORKDIR="${CWD}/build"
}

env_comp_gnu()
{
    export MY_PREFIX=${HOME}/local/gnu
    export CC=gcc
    export CFLAGS="-fopenmp"
    export CXX=g++
    export CXXFLAGS="${CFLAGS}"
    export FC=gfortran
    export FCFLAGS="-fopenmp"
    export OMPOPT="-fopenmp"
}

env_libblas_netlib()
{
    export USE_OPENBLAS=no
    export BLAS_DIST=netlib
    export BLAS_LIBRARIES=${HOME}/local/gnu/lib/libblas.a
    export LAPACK_LIBRARIES=${HOME}/local/gnu/lib/liblapack.a
}

env_libblas_openblas()
{
    export USE_OPENBLAS=yes
    export BLAS_DIST=openblas
    export OPENBLAS_TARGET="SANDYBRIDGE"
    export BLAS_LIBRARIES="${HOME}/local/gnu/lib/libopenblas.a"
    export LAPACK_LIBRARIES="${HOME}/local/gnu/lib/libopenblas.a"
}

env_mpi_mpich()
{
    export MY_MPI_PREFIX="${MY_PREFIX}/mpich"
    export MPI_BASE_DIR="${MY_MPI_PREFIX}"
    export MPICC="${MY_MPI_PREFIX}/bin/mpicc"
    export MPIFC="${MY_MPI_PREFIX}/bin/mpif90"
}

env_mpi_openmpi()
{
    export MY_MPI_PREFIX="${MY_PREFIX}/openmpi"
    export MPI_BASE_DIR="${MY_MPI_PREFIX}"
    export MPICC="${MY_MPI_PREFIX}/bin/mpicc"
    export MPIFC="${MY_MPI_PREFIX}/bin/mpif90"
}

env_mpi_openmpi2()
{
    export MY_MPI_PREFIX="${MY_PREFIX}/openmpi2"
    export MPI_BASE_DIR="${MY_MPI_PREFIX}"
    export MPICC="${MY_MPI_PREFIX}/bin/mpicc"
    export MPIFC="${MY_MPI_PREFIX}/bin/mpif90"
}


# MAIN =================================================================
# set env
env_common

case ${ARG_C} in
    'gnu')
        env_comp_gnu
        ;;

    *)
        echo "unsupport compiler env."
        echo "use default: gnu"
        env_comp_gnu
        ARG_C="gnu"
        ;;
esac

case ${ARG_L} in
    'netlib')
        env_libblas_netlib
        ;;
    
    'openblas')
        env_libblas_openblas
        ;;

    *)
        echo "unsupport BLAS/LAPACK env."
        echo "use default: netlib"
        env_libblas_netlib
        ARG_L="netlib"
        ;;
esac

case ${ARG_M} in
    'openmpi2')
        env_mpi_openmpi2
        ;;
    'openmpi')
        env_mpi_openmpi
        ;;

    'mpich')
        env_mpi_mpich
        ;;

    *)
        echo "unsupport MPI env."
        echo "use default: openmpi"
        env_mpi_openmpi
        ARG_M="openmpi"
        ;;

esac

build_blas()
{
    # build BLAS/LAPACK
    echo ">>>> BLAS/LAPACK"
    cd ${CWD}
    case ${ARG_L} in
    'netlib')
        ./build-lapack.sh
        ;;
    
    'openblas')
        ./build-openblas.sh
        ;;
    
    *)
        echo "unsupport BLAS/LAPACK env."
        exit 1
        ;;
    esac
    echo
}

build_mpi()
{
    # build MPI
    echo ">>>> MPI"
    cd ${CWD}
    case ${ARG_M} in
        'openmpi2')
            ./build-openmpi2.sh
            ;;

        'openmpi')
            ./build-openmpi.sh
            ;;
        
        'mpich')
            ./build-mpich.sh
            ;;
        
        *)
            echo "unsupport MPI env."
            exit 1
            ;;
        
    esac
    echo
}

build_scalapack()
{
    # build ScaLAPACK
    echo ">>>> ScaLAPACK"
    cd ${CWD}
    ./build-scalapack.sh
}


if [ x"${ARGS}" = x ]; then
    ARGS="blas mpi scalapack"
fi

for target in ${ARGS}; do
    case ${target} in
        'blas')
            build_blas
            ;;

        'mpi')
            build_mpi
            ;;

        'scalapack')
            build_scalapack
            ;;

        *)
            echo "unknown build target: ${target}. continue."
            ;;
    esac
done

echo "done."

