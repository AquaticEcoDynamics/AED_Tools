#!/bin/sh

export ZLIBV=1.2.13
export CURLV=7.88.1
export SZIPV=2.1.1
export HDF5V=1.12.0
export NETCDFV=4.9.1
export NETCDFFV=4.6.0

export ZLIB=zlib-${ZLIBV}
export CURL=curl-${CURLV}
export SZIP=szip-${SZIPV}
export HDF5=hdf5-${HDF5V}
export NETCDF=netcdf-c-${NETCDFV}
export NETCDFF=netcdf-fortran-${NETCDFFV}

export CC=gcc
export FC=ifort
case `uname` in
  "Darwin"|"Linux"|"FreeBSD")
    export OSTYPE=`uname -s`
    ;;
  MINGW*)
    export OSTYPE="Msys"
    ;;
esac

if [ "$FC" = "ifort" ] ; then
  if [ -x /opt/intel/setvars.sh ] ; then
     . /opt/intel/setvars.sh
  elif [ -d /opt/intel/oneapi ] ; then
     . /opt/intel/oneapi/setvars.sh
  else
    if [ -d /opt/intel/bin ] ; then
       . /opt/intel/bin/compilervars.sh intel64
    fi
    which ifort > /dev/null 2>&1
    if [ $? != 0 ] ; then
       echo ifort compiler requested, but not found
       exit 1
    fi
  fi
fi

export F77=$FC
export F90=$FC
export F95=$FC

if [ ! -f ${ZLIB}.tar.gz ] ; then
   echo fetching ${ZLIB}
   curl http://www.zlib.net/${ZLIB}.tar.gz -o ${ZLIB}.tar.gz
   if [ $? != 0 ] ; then
      echo failed to fetch ${ZLIB}.tar.gz
   fi
fi

if [ ! -f ${CURL}.tar.gz ] ; then
   echo fetching ${CURL}
   curl -L https://curl.haxx.se/download/${CURL}.tar.gz -o ${CURL}.tar.gz
   if [ $? != 0 ] ; then
      echo failed to fetch ${CURL}.tar.gz
   fi
fi

if [ ! -f ${SZIP}.tar.gz ] ; then
   echo fetching ${SZIP}
   curl https://support.hdfgroup.org/ftp/lib-external/szip/${SZIPV}/src/${SZIP}.tar.gz -o ${SZIP}.tar.gz
   if [ $? != 0 ] ; then
      echo failed to fetch ${SZIP}.tar.gz
   fi
fi

if [ ! -f ${HDF5}.tar.gz ] ; then
   echo fetching ${HDF5}
   curl -L "https://www.hdfgroup.org/package/hdf5-1-12-0-tar-gz/?wpdmdl=14582&refresh=629d65fd013e61654482429" -o ${HDF5}.tar.gz
   if [ $? != 0 ] ; then
      echo failed to fetch ${HDF5}.tar.gz
   fi
fi

if [ ! -f ${NETCDF}.tar.gz ] ; then
   echo fetching ${NETCDF}
   curl -LJO https://github.com/Unidata/netcdf-c/archive/refs/tags/v${NETCDFV}.tar.gz
   if [ $? != 0 ] ; then
      echo failed to fetch ${NETCDF}.tar.gz
   fi
fi

if [ ! -f ${NETCDFF}.tar.gz ] ; then
   echo fetching ${NETCDFF}
   curl -LJO https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v${NETCDFFV}.tar.gz
   if [ $? != 0 ] ; then
      echo failed to fetch ${NETCDFF}.tar.gz
   fi
fi

#===============================================================================

CWD=`pwd`
cd ..
export FINALDIR=`pwd`
cd "$CWD"

if [ ! -d "${FINALDIR}"/include ] ; then
  mkdir "${FINALDIR}"/include
fi
if [ ! -d "${FINALDIR}"/lib ] ; then
  mkdir "${FINALDIR}"/lib
fi
if [ ! -d "${FINALDIR}"/bin ] ; then
  mkdir "${FINALDIR}"/bin
fi

export CFLAGS="-I${FINALDIR}/include"
export CPPFLAGS="-I${FINALDIR}/include"
#export LDFLAGS="-static -L${FINALDIR}/lib"
export LDFLAGS="-L${FINALDIR}/lib"

if [ "$OSTYPE" = "Msys" ] ; then
  # The following gets around a problem that inside "make" the SHELL var is
  # "Program Files" somewhere and it cannot be redefined so I define XSHELL
  # and replace 'SHELL' with 'XSHELL' in the Makefiles 
  export XSHELL=/usr/bin/sh

  # choco install cmake.install --installargs '"ADD_CMAKE_TO_PATH=System"'
  # choco install pkgconfiglite
  export PKG_CONFIG_PATH=/c/ProgramData/chocolatey/bin/
  alias pkgconfig=pkg-config
fi

#----------------------------------------------------------------
unpack_src () {
   src=$1
   if [ ! -d $src ] ; then
      if [ -f $src.tar.gz ] ; then
       echo Unpacking $src.tar.gz
       tar -xzf $src.tar.gz
     else
       echo $src.tar.gz not found!
       exit 1
     fi
   fi
   if [ -d $src ] ; then
      echo '****************' building in $src
   else
     echo no directory for $src
     exit 1
   fi
}
#----------------------------------------------------------------

if [ "1" = "1" ] ; then

## build zlib
   unpack_src  $ZLIB
   cd $ZLIB
   ./configure --static --prefix=${FINALDIR}
   if [ $? = 0 ] ; then
      export BINARY_PATH=${FINALDIR}/bin
      export LIBRARY_PATH=${FINALDIR}/lib
      export INCLUDE_PATH=${FINALDIR}/include
      make install
   else
      echo '****' build failed for $ZLIB
      exit 1
   fi
   cd ..
   echo '****************' done building in $ZLIB

# build szips	
   unpack_src  $SZIP
   cd $SZIP
#   cmake . -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$FINALDIR"
   ./configure --prefix=${FINALDIR}
   if [ $? = 0 ] ; then
      if [ "$XSHELL" != "" ] ; then
         for j in `find . -name Makefile` ; do
            sed -e 's/\<SHELL\>/XSHELL/' < $j > Makefile-x
            mv Makefile-x $j
         done
      fi
      make
      if [ $? = 0 ] ; then
         make install
      else
         echo '****' build failed for $SZIP
         exit 1
      fi
   else
      echo '****' config failed for $SZIP
      exit 1
   fi
   cd ..
   echo '****************' done building in $SZIP

# build curl
   unpack_src  $CURL
   cd $CURL
   cmake "." \
        -G "Unix Makefiles" \
        -DBUILD_TESTING=OFF \
        -DBUILD_SHARED_LIBS:BOOL=OFF \
        -DCMAKE_INSTALL_PREFIX="${FINALDIR}"
	  
   if [ $? = 0 ] ; then
      make
      if [ $? = 0 ] ; then
         make install
      else
         echo '****' build failed for $CURL
         exit 1
      fi
   else
      echo '****' config failed for $CURL
      exit 1
   fi
   cd ..
   echo '****************' done building in $CURL

# build hdf5
   unpack_src  $HDF5
   cd $HDF5
   mkdir build
   cd build
   cmake ".." \
        -G "Unix Makefiles" \
		-DCMAKE_FIND_ROOT_PATH="${FINALDIR}" \
        -DBUILD_TESTING=OFF \
        -DBUILD_SHARED_LIBS:BOOL=OFF \
        -DCMAKE_C_FLAGS="-I$FINALDIR/include" \
		-DHDF5_ENABLE_Z_LIB_SUPPORT:PATH="${FINALDIR}" \
        -DHDF5_ENABLE_SZIP_SUPPORT:PATH="${FINALDIR}" \
		-DHDF5_BUILD_CXX:BOOL=OFF \
        -DCMAKE_INSTALL_PREFIX="${FINALDIR}"

#   ./configure --prefix=${FINALDIR} --with-zlib=${FINALDIR} --with-szlib=${FINALDIR} --disable-shared --disable-tests --enable-build-mode=production
   if [ $? = 0 ] ; then
#     for j in `find . -name Makefile` ; do
#        sed -e 's/\<SHELL\>/XSHELL/' < $j > Makefile-x
#        mv Makefile-x $j
#     done
      make
      if [ $? = 0 ] ; then
         make install
      else
         echo '****' build failed for $HDF5
         exit 1
      fi
   else
      echo '****' config failed for $HDF5
      exit 1
   fi
   cd ..
   cd ..
   echo '****************' done building in $HDF5

# netcdf depends on hdf5 and curl
   unpack_src  $NETCDF
   cd $NETCDF
#  cmake "." \
#       -G "Unix Makefiles" \
#	-DENABLE_DAP=0 \
#	-DENABLE_TESTS=0 \
#       -DCMAKE_FIND_ROOT_PATH=${FINALDIR} \
#	-DCMAKE_PREFIX_PATH=${FINALDIR} \
#	-DHDF5_C_LIRARY=${FINALDIR} \
#	-DHDF5_ROOT=${FINALDIR} \
#	-DSZIP_ROOT=${FINALDIR} \
#	-DZLIB_ROOT=${FINALDIR} \
#	-DHDF5_DIR=${FINALDIR}\cmake\hdf5 \
#       -DCMAKE_CXX_FLAGS="-I${FINALDIR}/include" \
#       -DCMAKE_INSTALL_PREFIX="${FINALDIR}"

   ./configure --prefix=${FINALDIR} --enable-static --disable-shared

   if [ $? = 0 ] ; then
      make
      if [ $? = 0 ] ; then
         make install
      else
         echo '****' build failed for $NETCDF
         exit 1
      fi
   else
      echo '****' config failed for $NETCDF
      exit 1
   fi
   cd ..
   echo '****************' done building in $NETCDF

fi

# netcdff depends on netcdf
   export PATH="$PATH:${FINALDIR}/bin"
   unpack_src  $NETCDFF
   cd $NETCDFF
#  cmake "." \
#       -G "Unix Makefiles" \
#       -DCMAKE_FIND_ROOT_PATH=${FINALDIR} \
#       -DCMAKE_INSTALL_PREFIX="${FINALDIR}"

   export LDFLAGS="-static -L${FINALDIR}/lib"
   export LIBS="-L${FINALDIR}/lib -lnetcdf -lhdf5_hl -lhdf5 -lm -lz -lsz -lxml2 -lcurl"

   ./configure --prefix=${FINALDIR} --enable-static --disable-shared

   if [ $? = 0 ] ; then
      make
      if [ $? = 0 ] ; then
         make install
      else
         echo '****' build failed for $NETCDFF
         exit 1
      fi
   else
      echo '****' config failed for $NETCDFF
      exit 1
   fi
   cd ..
   echo '****************' done building in $NETCDFF

exit 0

