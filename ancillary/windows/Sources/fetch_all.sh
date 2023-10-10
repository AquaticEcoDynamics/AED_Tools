#!/bin/sh

while [ $# -gt 0 ] ; do
   case $1 in
    --unpack)
      export UNPACK=true
      ;;
    --ignore-certs)
      export MINUS_K='-k'
      ;;
    *)
      ;;
  esac
  shift
done

. ./versions.inc

export DSTDIR=msys
export ZLIB=zlib-${ZLIBV}
export FREETYPE2=freetype-${FRREETYPE2V}
export JPEG=jpegsrc.v${JPEGV}
export LIBPNG=libpng-${LIBPNGV}
export LIBGD=lib${GD}
export CURL=curl-${CURLV}
export SZIP=szip-${SZIPV}
export HDF5=hdf5-${HDF5V}
export NETCDF=netcdf-c-${NETCDFV}
export NETCDFF=netcdf-fortran-${NETCDFFV}

if [ ! -f ${ZLIB}.tar.gz ] ; then
   curl ${MINUS_K} http://www.zlib.net/${ZLIB}.tar.gz -o ${ZLIB}.tar.gz
   if [ $? != 0 ] ; then
      echo failed to fetch ${ZLIB}.tar.gz
   elif [ "$UNPACK" = "true" ] ; then
      tar -xzf ${ZLIB}.tar.gz
   fi
fi

if [ ! -f ${FREETYPE2}.tar.gz ] ; then
   curl ${MINUS_K} -L https://download.savannah.gnu.org/releases/freetype/${FREETYPE2}.tar.gz -o ${FREETYPE2}.tar.gz
   if [ $? != 0 ] ; then
      echo failed to fetch ${FREETYPE2}.tar.gz
   elif [ "$UNPACK" = "true" ] ; then
      tar -xzf ${FREETYPE2}.tar.gz
   fi
fi

if [ ! -f ${JPEG}.tar.gz ] ; then
   curl ${MINUS_K} http://www.ijg.org/files/${JPEG}.tar.gz -o ${JPEG}.tar.gz
   if [ $? != 0 ] ; then
      echo failed to fetch ${JPEG}.tar.gz
   elif [ "$UNPACK" = "true" ] ; then
      tar -xzf ${JPEG}.tar.gz
   fi
fi

if [ ! -f ${LIBPNG}.tar.gz ] ; then
   curl ${MINUS_K} -L http://prdownloads.sourceforge.net/libpng/${LIBPNG}.tar.gz -o ${LIBPNG}.tar.gz
   if [ $? != 0 ] ; then
      echo failed to fetch ${LIBPNG}.tar.gz
   elif [ "$UNPACK" = "true" ] ; then
      tar xzf ${LIBPNG}.tar.gz
   fi
fi

if [ ! -f ${LIBGD}.tar.gz ] ; then
   curl ${MINUS_K} -L https://github.com/libgd/libgd/releases/tag/${LIBGD}/${LIBGD}.tar.gz -o ${LIBGD}.tar.gz
   if [ $? != 0 ] ; then
      echo failed to fetch ${LIBGD}.tar.gz
   elif [ "$UNPACK" = "true" ] ; then
      tar xzf ${LIBGD}.tar.gz
   fi
fi

if [ ! -f ${CURL}.tar.gz ] ; then
   curl ${MINUS_K} -L https://curl.haxx.se/download/${CURL}.tar.gz -o ${CURL}.tar.gz
   if [ $? != 0 ] ; then
      echo failed to fetch ${CURL}.tar.gz
   elif [ "$UNPACK" = "true" ] ; then
      tar xzf ${CURL}.tar.gz
   fi
fi

if [ ! -f ${SZIP}.tar.gz ] ; then
   curl ${MINUS_K} https://support.hdfgroup.org/ftp/lib-external/szip/${SZIPV}/src/${SZIP}.tar.gz -o ${SZIP}.tar.gz
   if [ $? != 0 ] ; then
      echo failed to fetch ${SZIP}.tar.gz
   elif [ "$UNPACK" = "true" ] ; then
      tar xzf ${SZIP}.tar.gz
   fi
fi

if [ ! -f ${HDF5}.tar.gz ] ; then
  #curl ${MINUS_K} -L "https://www.hdfgroup.org/package/hdf5-1-12-0-tar-gz/?wpdmdl=14582&refresh=629d65fd013e61654482429" -o ${HDF5}.tar.gz
   curl ${MINUS_K} -L "https://hdf-wordpress-1.s3.amazonaws.com/wp-content/uploads/manual/HDF5/HDF5_1_14_2/src/hdf5-1.14.2.tar.gz" -o ${HDF5}.tar.gz
   if [ $? != 0 ] ; then
      echo failed to fetch ${HDF5}.tar.gz
   elif [ "$UNPACK" = "true" ] ; then
      tar xzf ${HDF5}.tar.gz
   fi
fi

if [ ! -f ${NETCDF}.tar.gz ] ; then
   curl ${MINUS_K} https://downloads.unidata.ucar.edu/netcdf-c/${NETCDFV}/${NETCDF}.tar.gz -o ${NETCDF}.tar.gz
  #curl ${MINUS_K} -LJO https://github.com/Unidata/netcdf-c/archive/refs/tags/v${NETCDFV}.tar.gz
   if [ $? != 0 ] ; then
      echo failed to fetch ${NETCDF}.tar.gz
   elif [ "$UNPACK" = "true" ] ; then
      tar xzf ${NETCDF}.tar.gz
   fi
fi

if [ ! -f ${NETCDFF}.tar.gz ] ; then
   curl ${MINUS_K} https://downloads.unidata.ucar.edu/netcdf-fortran/${NETCDFFV}/${NETCDFF}.tar.gz -o ${NETCDFF}.tar.gz
   # curl ${MINUS_K} -LJO https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v${NETCDFFV}.tar.gz
   if [ $? != 0 ] ; then
      echo failed to fetch ${NETCDFF}.tar.gz
   elif [ "$UNPACK" = "true" ] ; then
      tar xzf ${NETCDFF}.tar.gz
   fi
fi

exit 0
