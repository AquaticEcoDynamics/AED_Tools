#!/bin/sh

. ./versions.inc

export NETCDF=netcdf-c-${NETCDFV}
export NETCDFF=netcdf-fortran-${NETCDFFV}


#
#  https://github.com/Unidata/netcdf-c/releases
#  https://github.com/Unidata/netcdf-fortran/releases
#

#if [ ! -f ${NETCDF}.tar.gz ] ; then
#   # curl https://downloads.unidata.ucar.edu/netcdf-c/${NETCDFV}/${NETCDF}.tar.gz -o ${NETCDF}.tar.gz
#   curl ${MINUS_K} -LJO https://github.com/Unidata/netcdf-c/archive/refs/tags/v${NETCDFV}.tar.gz
#   if [ $? != 0 ] ; then
#      echo failed to fetch ${NETCDF}.tar.gz
#   elif [ "$UNPACK" = "true" ] ; then
#      tar xzf ${NETCDF}.tar.gz
#   fi
#fi

if [ ! -f ${NETCDFF}.tar.gz ] ; then
   # curl https://downloads.unidata.ucar.edu/netcdf-fortran/${NETCDFFV}/${NETCDFF}.tar.gz -o ${NETCDFF}.tar.gz
   curl ${MINUS_K} -LJO https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v${NETCDFFV}.tar.gz
   if [ $? != 0 ] ; then
      echo failed to fetch ${NETCDFF}.tar.gz
   elif [ "$UNPACK" = "true" ] ; then
      tar xzf ${NETCDFF}.tar.gz
   fi
fi

exit 0
