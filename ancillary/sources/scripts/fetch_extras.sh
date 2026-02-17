#!/bin/sh

#while [ $# -gt 0 ] ; do
#   case $1 in
#    --unpack)
#      export UNPACK=true
#      ;;
#    --ignore-certs)
#      export MINUS_K='-k'
#      ;;
#    *)
#      ;;
#  esac
#  shift
#done

#. ./versions.inc

export ZLIB=zlib-${ZLIBV}
export CURL=curl-${CURLV}
export LIBAEC=libaec-${LIBAECV}
export HDF5=hdf5-${HDF5V}

if [ ! -f ${ZLIB}.tar.gz ] ; then
   echo fetching ${ZLIB}.tar.gz
   curl ${MINUS_K} http://www.zlib.net/${ZLIB}.tar.gz -o ${ZLIB}.tar.gz
   if [ $? != 0 ] ; then
      echo failed to fetch ${ZLIB}.tar.gz
   elif [ "$UNPACK" = "true" ] ; then
      tar -xzf ${ZLIB}.tar.gz
   fi
fi

if [ ! -f ${CURL}.tar.gz ] ; then
   echo fetching ${CURL}.tar.gz
   curl ${MINUS_K} -L https://curl.haxx.se/download/${CURL}.tar.gz -o ${CURL}.tar.gz
   if [ $? != 0 ] ; then
      echo failed to fetch ${CURL}.tar.gz
   elif [ "$UNPACK" = "true" ] ; then
      tar xzf ${CURL}.tar.gz
   fi
fi

if [ ! -f  ${LIBAEC}.tar.gz ] ; then
   echo fetching ${LIBAEC}.tar.gz
   echo curl ${MINUS_K} -L https://gitlab.dkrz.de/k202009/libaec/-/archive/${LIBAECV}/${LIBAEC}.tar.gz -o ${LIBAEC}.tar.gz
   curl ${MINUS_K} -LJO https://gitlab.dkrz.de/k202009/libaec/-/archive/${LIBAECV}/${LIBAEC}.tar.gz
   if [ $? != 0 ] ; then
      echo failed to fetch ${LIBAEC}.tar.gz
   elif [ "$UNPACK" = "true" ] ; then
      tar xzf ${LIBAEC}.tar.gz
   fi
fi

if [ ! -f ${HDF5}.tar.gz ] ; then
   HVER=`echo ${HDF5V} | cut -f1 -d\.`
   HMAJ=`echo ${HDF5V} | cut -f2 -d\.`
   HMIN=`echo ${HDF5V} | cut -f3 -d\.`
   HDFDV="HDF5_${HVER}_${HMAJ}_${HMIN}"
   HDF5URL="https://support.hdfgroup.org/releases/hdf5/v${HVER}_${HMAJ}/v${HVER}_${HMAJ}_${HMIN}/downloads/${HDF5}.tar.gz"
   echo fetching ${HDF5}.tar.gz from \"${HDF5URL}\"
   curl ${MINUS_K}  -L ${HDF5URL} -o ${HDF5}.tar.gz
   if [ $? != 0 ] ; then
      echo failed to fetch ${HDF5}.tar.gz
   elif [ "$UNPACK" = "true" ] ; then
      tar xzf ${HDF5}.tar.gz
   fi
fi

exit 0
