#!/bin/bash

. ./versions.inc

# Work out what system type we are operating on
case `uname` in
  "Darwin"|"Linux"|"FreeBSD")
    export OSTYPE=`uname -s`
    export LIBZA=libz.a
    ;;
  MINGW*)
    export OSTYPE="Msys"
    export LIBZA=libzs.a
    ;;
esac

export DO_CDFCE=""
export DO_CDFC=""
export DO_CDFF=""
export DO_MPICH=""
export DO_OMPI=""
export DO_GD=""

export CWD=`pwd`
if [ "${FINALDIR}" = "" ] ;  then
  echo no FINALDIR defined
  exit 1
fi

ARGS=""
while [ $# -gt 0 ] ; do
  case $1 in
    --all)
      export DO_CDFCE=true
      export DO_CDFC=true
      export DO_CDFF=true
#     export DO_MPICH=true
#     export DO_OMPI=true
      export DO_GD=true
      ./fetch_all.sh $1
      ;;
    --need-ncdfc-extras)
      export DO_CDFCE=true
      ./fetch_all.sh $1
      export DO_CDFC=true
      ;;
    --need-netcdf_c)
      ./fetch_all.sh $1
      export DO_CDFC=true
      ;;
    --need-netcdf_f)
      ./fetch_all.sh $1
      export DO_CDFF=true
      ;;
    --need-mpich)
      ./fetch_all.sh $1
      export DO_MPICH=true
      ;;
    --need-openmpi)
      ./fetch_all.sh $1
      export DO_OMPI=true
      ;;
    --need-gd)
      ./fetch_all.sh $1
      export DO_GD=true
      ;;
    --debug)
      export DEBUG=true
      ;;
    *)
      echo "build_all.sh: unknown flag $1"
      ;;
  esac
  shift
done

#----------------------------------------------------------------

if [ "$DO_CDFC" = "true" ] ; then
  if [ "$DO_CDFCE" = "true" ] ; then
    ./scripts/build_extras.sh || exit 1
  fi
  ./scripts/build_netcdf_c.sh || exit 1
fi
if [ "$DO_CDFF" = "true" ] ; then
  ./scripts/build_netcdf_f.sh || exit 1
fi
if [ "$DO_MPICH" = "true" ] ; then
  ./scripts/build_mpich.sh || exit 1
fi
if [ "$DO_OMPI" = "true" ] ; then
  ./scripts/build_openmpi.sh || exit 1
fi
if [ "$DO_GD" = "true" ] ; then
  ./scripts/build_gd.sh || exit 1
fi

exit 0
