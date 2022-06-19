#!/bin/sh

export ZLIBV=1.2.12
export CURLV=7.83.1
export SZIPV=2.1.1
export HDF5V=1.12.0
export NETCDFV=4.8.1
export NETCDFFV=4.5.4

#@REM The directory Build has project files to build the libraries using
#@REM VisualStudio 2017/2019 ; use all_libs.sln. They are set up to
#@REM access source files from directories in this directory called :
#@REM 
#@REM They are available from :
#@REM 
#@REM zlib           : http://www.zlib.net/
#@REM freetype       : http://www.freetype.org/download.html
#@REM jpeg           : http://www.ijg.org/
#@REM libpng         : http://www.libpng.org/pub/png/libpng.html
#@REM libgd          : http://libgd.github.io/
#@REM curl           : https://curl.haxx.se/download.html
#@REM szip           : https://support.hdfgroup.org/doc_resource/SZIP/
#@REM hdf5           : https://www.hdfgroup.org/downloads/hdf5/source-code/
#@REM netcdf &
#@REM netcdf-fortran : https://www.unidata.ucar.edu/downloads/netcdf/index.jsp
#@REM 

export DSTDIR=x64-Release
export ZLIB=zlib-${ZLIBV}
export CURL=curl-${CURLV}
export SZIP=szip-${SZIPV}
export HDF5=hdf5-${HDF5V}
export NETCDF=netcdf-c-${NETCDFV}
export NETCDFF=netcdf-fortran-${NETCDFFV}

if [ ! -f ${ZLIB}.tar.gz ] ; then
   curl  http://www.zlib.net/${ZLIB}.tar.gz -o ${ZLIB}.tar.gz
   if [ $? != 0 ] ; then
      echo failed to fetch ${ZLIB}.tar.gz
   fi
fi

if [ ! -f ${CURL}.tar.gz ] ; then
   curl  -L https://curl.haxx.se/download/${CURL}.tar.gz -o ${CURL}.tar.gz
   if [ $? != 0 ] ; then
      echo failed to fetch ${CURL}.tar.gz
   fi
fi

if [ ! -f ${SZIP}.tar.gz ] ; then
   curl  https://support.hdfgroup.org/ftp/lib-external/szip/${SZIPV}/src/${SZIP}.tar.gz -o ${SZIP}.tar.gz
   if [ $? != 0 ] ; then
      echo failed to fetch ${SZIP}.tar.gz
   fi
fi

if [ ! -f ${HDF5}.tar.gz ] ; then
   curl  -L "https://www.hdfgroup.org/package/hdf5-1-12-0-tar-gz/?wpdmdl=14582&refresh=629d65fd013e61654482429" -o ${HDF5}.tar.gz
   if [ $? != 0 ] ; then
      echo failed to fetch ${HDF5}.tar.gz
   fi
fi

if [ ! -f ${NETCDF}.tar.gz ] ; then
   # curl https://downloads.unidata.ucar.edu/netcdf-c/${NETCDFV}/${NETCDF}.tar.gz -o ${NETCDF}.tar.gz
   curl https://github.com/Unidata/netcdf-c/archive/refs/tags/v${NETCDFV}.tar.gz -o ${NETCDF}.tar.gz
   if [ $? != 0 ] ; then
      echo failed to fetch ${NETCDF}.tar.gz
   fi
fi

if [ ! -f ${NETCDFF}.tar.gz ] ; then
   # curl https://downloads.unidata.ucar.edu/netcdf-fortran/${NETCDFFV}/${NETCDFF}.tar.gz -o ${NETCDFF}.tar.gz
   curl https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v${NETCDFFV}.tar.gz -o ${NETCDFF}.tar.gz
   if [ $? != 0 ] ; then
      echo failed to fetch ${NETCDFF}.tar.gz
   fi
fi

#===============================================================================
export CC=gcc
export FC=gfortran

CWD=`pwd`
cd ..
if [ ! -d $DSTDIR ] ; then
  mkdir $DSTDIR
fi
cd $DSTDIR
export FINALDIR=`pwd`
cd "$CWD"

if [ ! -d "${FINALDIR}"/include ] ; then
  mkdir "${FINALDIR}"/include
fi
if [ ! -d "${FINALDIR}"/lib ] ; then
  mkdir "${FINALDIR}"/lib
fi
echo -n > fail.log

export CFLAGS="-I${FINALDIR}/include"
export CPPFLAGS="-I${FINALDIR}/include"
export LDFLAGS="-L${FINALDIR}/lib"

# The following gets around a problem that inside "make" the SHELL var is
# "Program Files" somewhere and it cannot be redefined so I define XSHELL
# and replace 'SHELL' with 'XSHELL' in the Makefiles 
export XSHELL=/usr/bin/sh

# choco install cmake.install --installargs '"ADD_CMAKE_TO_PATH=System"'
# choco install pkgconfiglite
export PKG_CONFIG_PATH=/c/ProgramData/chocolatey/bin/
alias pkgconfig=pkg-config

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
     echo no directory for $src >> fail.log
     exit 1
   fi
}
#----------------------------------------------------------------

## build zlib
   unpack_src  $ZLIB
   cd $ZLIB
#   cmake . -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$FINALDIR"
#   make
   make -f win32/Makefile.gcc
   if [ $? = 0 ] ; then
      export BINARY_PATH=${FINALDIR}/bin
      export LIBRARY_PATH=${FINALDIR}/lib
      export INCLUDE_PATH=${FINALDIR}/include
      make -f win32/Makefile.gcc install
#      make install
   else
      echo '****' build failed for $ZLIB
      echo '****' build failed for $ZLIB >> fail.log
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
      for j in `find . -name Makefile` ; do
         sed -e 's/\<SHELL\>/XSHELL/' < $j > Makefile-x
         mv Makefile-x $j
      done
      make
      if [ $? = 0 ] ; then
         make install
      else
         echo '****' build failed for $SZIP
         echo '****' build failed for $SZIP >> fail.log
         exit 1
      fi
   else
      echo '****' config failed for $SZIP
      echo '****' config failed for $SZIP >> fail.log
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
        -DCMAKE_INSTALL_PREFIX="$FINALDIR"
	  
   if [ $? = 0 ] ; then
      make
      if [ $? = 0 ] ; then
         make install
      else
         echo '****' build failed for $CURL
         echo '****' build failed for $CURL >> fail.log
         exit 1
      fi
   else
      echo '****' config failed for $CURL
      echo '****' config failed for $CURL >> fail.log
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
		-DCMAKE_FIND_ROOT_PATH="$FINALDIR" \
        -DBUILD_TESTING=OFF \
        -DBUILD_SHARED_LIBS:BOOL=OFF \
        -DCMAKE_C_FLAGS="-I$FINALDIR/include" \
		-DHDF5_ENABLE_Z_LIB_SUPPORT:PATH="$FINALDIR" \
        -DHDF5_ENABLE_SZIP_SUPPORT:PATH="$FINALDIR" \
		-DHDF5_BUILD_CXX:BOOL=OFF \
        -DCMAKE_INSTALL_PREFIX="$FINALDIR"

#   ./configure --prefix=$FINALDIR --with-zlib=$FINALDIR --with-szlib=$FINALDIR --disable-shared --disable-tests --enable-build-mode=production
   if [ $? = 0 ] ; then
#      for j in `find . -name Makefile` ; do
#         sed -e 's/\<SHELL\>/XSHELL/' < $j > Makefile-x
#         mv Makefile-x $j
#      done
      make
#	  cmake --build . --clean-first --config Release --target INSTALL
      if [ $? = 0 ] ; then
         make install
      else
         echo '****' build failed for $HDF5
         echo '****' build failed for $HDF5 >> fail.log
         exit 1
      fi
   else
      echo '****' config failed for $HDF5
      echo '****' config failed for $HDF5 >> fail.log
      exit 1
   fi
   cd ..
   cd ..
   echo '****************' done building in $HDF5

# netcdf depends on hdf5 and curl
   unpack_src  $NETCDF
   cd $NETCDF
   cmake "." \
        -G "Unix Makefiles" \
		-DENABLE_DAP=0 \
		-DENABLE_TESTS=0 \
        -DCMAKE_FIND_ROOT_PATH=$FINALDIR \
		-DCMAKE_PREFIX_PATH=$FINALDIR \
		-DHDF5_C_LIRARY=$FINALDIR \
		-DHDF5_ROOT=$FINALDIR \
		-DSZIP_ROOT=$FINALDIR \
		-DZLIB_ROOT=$FINALDIR \
		-DHDF5_DIR=$FINALDIR\cmake\hdf5 \
        -DCMAKE_CXX_FLAGS="-I$FINALDIR/include" \
        -DCMAKE_INSTALL_PREFIX="$FINALDIR"
   if [ $? = 0 ] ; then
      make
      if [ $? = 0 ] ; then
         make install
      else
         echo '****' build failed for $NETCDF
         echo '****' build failed for $NETCDF >> fail.log
         exit 1
      fi
   else
      echo '****' config failed for $NETCDF
      echo '****' config failed for $NETCDF >> fail.log
      exit 1
   fi
   cd ..
   echo '****************' done building in $NETCDF

# netcdff depends on netcdf
   unpack_src  $NETCDFF
   cd $NETCDFF
   cmake "." \
        -G "Unix Makefiles" \
        -DCMAKE_FIND_ROOT_PATH=$FINALDIR \
        -DCMAKE_INSTALL_PREFIX="$FINALDIR"
   if [ $? = 0 ] ; then
      make
      if [ $? = 0 ] ; then
         make install
      else
         echo '****' build failed for $NETCDFF
         echo '****' build failed for $NETCDFF >> fail.log
         exit 1
      fi
   else
      echo '****' config failed for $NETCDFF
      echo '****' config failed for $NETCDFF >> fail.log
      exit 1
   fi
   cd ..
   echo '****************' done building in $NETCDFF

exit 0

