#!/bin/bash

export WITH_AED="ON"
export WITH_AED_PLUS=false

export CWD=`pwd`
export MAKE=make
export BFLAG='-j8'
export ERROR=0
export MDEBUG=false

# Start by figuring out what system we're on
case `uname` in
  "Darwin"|"Linux"|"FreeBSD")
    export OSTYPE=`uname -s`
    ;;
  MINGW*)
    export OSTYPE="Msys"
    ;;
esac

#-------------------------------------------------------------------------------
# Set up some defaults

export FC=gfortran
export CC=gcc
export MAKE=make

#-------------------------------------------------------------------------------
# Now scan the argument list

ARGS=""
while [ $# -gt 0 ] ; do
  ARGS="$ARGS $1"
  case $1 in
    --debug)
      export DEBUG=true
      ;;
    --mdebug)
      export MDEBUG=true
      ;;
    --fence)
      export FENCE=true
      ;;
    --gfort)
      export FC=gfortran
      ;;
    --ifx)
      export FC=ifx
      ;;
    --ifort)
      export FC=ifort
      ;;
    --flang)
      export FC=flang
      ;;
      ;;
    --with-aed-plus)
      export WITH_AED_PLUS=true
      ;;

    --help)
      echo "build_schism accepts the following flags:"
      echo "  --debug          : build with debugging symbols"
      echo "  --gfort          : use the gfortran compiler"
      echo "  --ifort          : use the older intel fortran compiler"
      echo "  --ifx            : use the newer intel fortran compiler"
#     echo "  --flang          : use the flang compiler"
      echo
      echo "  --with-aed-plus  : build with aed and aed-plus enabled"
      echo

      exit 0
      ;;
    *)
      echo "Unknown option \"$1\""
      export ERROR=1
      ;;
  esac
  shift
done

#-------------------------------------------------------------------------------

export F77=$FC
export F90=$FC
export F95=$FC

. ${CWD}/build_env.inc

. ${CWD}/build_aedlibs.inc


exit 0
