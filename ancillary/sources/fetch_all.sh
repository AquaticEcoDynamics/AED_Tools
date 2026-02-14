#!/bin/bash

. ./versions.inc

if [ "$OSTYPE" = "Msys" ] ; then
  export MINUS_K='-k'
fi

export GETCDFC=""
export GETCDFCE=""
export GETCDFF=""
export GETMPICH=""
export GETOMPI=""
export GET_GD=""

ARGS=""
while [ $# -gt 0 ] ; do
  case $1 in
    --all)
      export GETCDFC=true
      export GETCDFCE=true
      export GETCDFF=true
#     export GETMPICH=true
#     export GETOMPI=true
      export GET_GD=true
      ;;
    --unpack)
      export UNPACK=true
      ;;
    --ignore-certs)
      export MINUS_K='-k'
      ;;
    --need-ncdfc-extras)
      export GETCDFCE=true
      export GETCDFC=true
      ;;
    --need-netcdf_c)
      export GETCDFC=true
      ;;
    --need-netcdf_f)
      export GETCDFF=true
      ;;
    --need-mpich)
      export GETMPICH=true
      ;;
    --need-openmpi)
      export GETOMPI=true
      ;;
    --need-gd)
      export GET_CD=true
      ;;
    --debug)
      export DEBUG=true
      ;;
    *)
      echo "fetch_all.sh: unknown flag $1"
      ;;
  esac
  shift
done

#
#  https://github.com/Unidata/netcdf-c/releases
#  https://github.com/Unidata/netcdf-fortran/releases
#
#  https://www.mpich.org/static/downloads/${MPICHV}/mpich-${MPICHV}.tar.gz
#  https://download.open-mpi.org/release/open-mpi/v5.0/openmpi-5.0.6.tar.gz
#

if [ "$GETCDFC" = "true" ] ; then
  if [ ! -f ${NETCDF}.tar.gz ] ; then
    echo fetching ${NETCDF}.tar.gz
    # curl https://downloads.unidata.ucar.edu/netcdf-c/${NETCDFV}/${NETCDF}.tar.gz -o ${NETCDF}.tar.gz
    curl ${MINUS_K} -LJO https://github.com/Unidata/netcdf-c/archive/refs/tags/v${NETCDFV}.tar.gz
    if [ $? != 0 ] ; then
      echo failed to fetch ${NETCDF}.tar.gz
    elif [ "$UNPACK" = "true" ] ; then
      tar xzf ${NETCDF}.tar.gz
    fi
  fi
  if [ "$GETCDFC" = "true" ] ; then
    ./scripts/fetch_extras.sh
  fi
fi

if [ "$GETCDFF" = "true" ] ; then
  if [ ! -f ${NETCDFF}.tar.gz ] ; then
    echo fetching ${NETCDFF}.tar.gz
    # curl https://downloads.unidata.ucar.edu/netcdf-fortran/${NETCDFFV}/${NETCDFF}.tar.gz -o ${NETCDFF}.tar.gz
    curl ${MINUS_K} -LJO https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v${NETCDFFV}.tar.gz
    if [ $? != 0 ] ; then
      echo failed to fetch ${NETCDFF}.tar.gz
    elif [ "$UNPACK" = "true" ] ; then
      tar xzf ${NETCDFF}.tar.gz
    fi
  fi
fi

if [ "$GETMPICH" = "true" ] ; then
  if [ ! -f ${MPICH}.tar.gz ] ; then
    echo fetching ${MPICH}.tar.gz
    curl ${MINUS_K} -LJO https://www.mpich.org/static/downloads/${MPICHV}/${MPICH}.tar.gz
      if [ $? != 0 ] ; then
      echo failed to fetch ${MPICH}.tar.gz
    elif [ "$UNPACK" = "true" ] ; then
      tar xzf ${MPICH}.tar.gz
    fi
  fi
fi

if [ "$GETOMPI" = "true" ] ; then
  if [ ! -f ${OMPI}.tar.gz ] ; then
    echo fetching ${OMPI}.tar.gz
    curl ${MINUS_K} -LJO https://download.open-mpi.org/release/open-mpi/v${OMPIMAJ}/openmpi-${OMPIV}.tar.gz
    if [ $? != 0 ] ; then
      echo failed to fetch ${OMPI}.tar.gz
    elif [ "$UNPACK" = "true" ] ; then
      tar xzf ${OMPI}.tar.gz
    fi
  fi
fi

if [ "$GET_GD" = "true" ] ; then
  ./scripts/fetch_gd.sh
fi

exit 0
