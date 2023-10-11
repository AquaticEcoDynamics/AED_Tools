#!/bin/sh

if [ $# -eq 0 ] ; then
  export DOLIBGD=1
  export DONETCDF=1
else
  if [ $# -eq 1 -a "$1" = "--ignore-certs" ] ; then
    export DOLIBGD=1
    export DONETCDF=1
  else
    export DOLIBGD=0
    export DONETCDF=0
  fi
fi

while [ $# -gt 0 ] ; do
  case $1 in
    --gd)
      export DOLIBGD=1
      ;;
    --netcdf)
      export DONETCDF=1
      ;;
    --ignore-certs)
      export MINUS_K='-k'
      ;;
    *)
      ;;
  esac
  shift
done

if [ $DOLIBGD = 0 ] ; then
  if [ $DONETCDF = 0 ] ; then
    echo nothing to do\?
    exit 1
  fi
fi
echo OK
if [ ${DOLIBGD} != 0 ] ;then
  echo doing libgd
fi

if [ ${DONETCDF} != 0 ] ;then
  echo doing netcdf

  if [ "$FC" != "ifort" ] ; then
    echo 'not doing netcdff'
  fi
fi

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
   echo fetching ${ZLIB}.tar.gz
   curl ${MINUS_K} http://www.zlib.net/${ZLIB}.tar.gz -o ${ZLIB}.tar.gz
   if [ $? != 0 ] ; then
      echo failed to fetch ${ZLIB}.tar.gz
   fi
fi

if [ ${DOLIBGD} != 0 ] ;then
   if [ ! -f ${FREETYPE2}.tar.gz ] ; then
      echo fetching ${FREETYPE2}.tar.gz
      curl ${MINUS_K} -L https://download.savannah.gnu.org/releases/freetype/${FREETYPE2}.tar.gz -o ${FREETYPE2}.tar.gz
      if [ $? != 0 ] ; then
         echo failed to fetch ${FREETYPE2}.tar.gz
      fi
   fi

   if [ ! -f ${JPEG}.tar.gz ] ; then
      echo fetching ${JPEG}.tar.gz
      curl ${MINUS_K} http://www.ijg.org/files/${JPEG}.tar.gz -o ${JPEG}.tar.gz
      if [ $? != 0 ] ; then
         echo failed to fetch ${JPEG}.tar.gz
      fi
   fi

   if [ ! -f ${LIBPNG}.tar.gz ] ; then
      echo fetching ${LIBPNG}.tar.gz
      curl ${MINUS_K} -L http://prdownloads.sourceforge.net/libpng/${LIBPNG}.tar.gz -o ${LIBPNG}.tar.gz
      if [ $? != 0 ] ; then
         echo failed to fetch ${LIBPNG}.tar.gz
      fi
   fi

   if [ ! -f ${LIBGD}.tar.gz ] ; then
      echo fetching ${LIBGD}.tar.gz
      curl ${MINUS_K} -L https://github.com/libgd/libgd/releases/tag/${LIBGD}/${LIBGD}.tar.gz -o ${LIBGD}.tar.gz
      if [ $? != 0 ] ; then
         echo failed to fetch ${LIBGD}.tar.gz
      fi
   fi
fi

if [ ${DONETCDF} != 0 ] ;then
   if [ ! -f ${CURL}.tar.gz ] ; then
      echo fetching ${CURL}.tar.gz
      curl ${MINUS_K} -L https://curl.haxx.se/download/${CURL}.tar.gz -o ${CURL}.tar.gz
      if [ $? != 0 ] ; then
         echo failed to fetch ${CURL}.tar.gz
      fi
   fi

   if [ ! -f ${SZIP}.tar.gz ] ; then
      echo fetching ${SZIP}.tar.gz
      curl ${MINUS_K} https://support.hdfgroup.org/ftp/lib-external/szip/${SZIPV}/src/${SZIP}.tar.gz -o ${SZIP}.tar.gz
      if [ $? != 0 ] ; then
         echo failed to fetch ${SZIP}.tar.gz
      fi
   fi

   if [ ! -f ${HDF5}.tar.gz ] ; then
      HVER=`echo ${HDF5V} | cut -f1 -d\.`
      HMAJ=`echo ${HDF5V} | cut -f2 -d\.`
      HMIN=`echo ${HDF5V} | cut -f3 -d\.`
      HDFDV="HDF5_${HVER}_${HMAJ}_${HMIN}"
      HDF5URL="https://hdf-wordpress-1.s3.amazonaws.com/wp-content/uploads/manual/HDF5/${HDFDV}/src/${HDF5}.tar.gz"
      echo fetching ${HDF5}.tar.gz from \"${HDF5URL}\"
      curl ${MINUS_K}  -L ${HDF5URL} -o ${HDF5}.tar.gz
      if [ $? != 0 ] ; then
         echo failed to fetch ${HDF5}.tar.gz
      fi
   fi

   if [ ! -f ${NETCDF}.tar.gz ] ; then
      echo fetching ${NETCDF}.tar.gz
      curl ${MINUS_K} https://downloads.unidata.ucar.edu/netcdf-c/${NETCDFV}/${NETCDF}.tar.gz -o ${NETCDF}.tar.gz
      if [ $? != 0 ] ; then
         echo failed to fetch ${NETCDF}.tar.gz
      fi
   fi

   if [ "$FC" = "ifort" ] ; then
     if [ ! -f ${NETCDFF}.tar.gz ] ; then
       echo fetching ${NETCDFF}.tar.gz
       curl ${MINUS_K} https://downloads.unidata.ucar.edu/netcdf-fortran/${NETCDFFV}/${NETCDFF}.tar.gz -o ${NETCDFF}.tar.gz
       if [ $? != 0 ] ; then
         echo failed to fetch ${NETCDFF}.tar.gz
       fi
     fi
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

if [ ! -d include ] ; then
  mkdir include
fi
if [ ! -d lib ] ; then
  mkdir lib
fi
cd "$CWD"

   # The jpeg package and directory names differ, so it's a special case
   #   luckily it has no dependancies, so we can build it first
   if [ ! -d jpeg-${JPEGV} ] ; then
     if [ -f ${JPEG}.tar.gz ] ; then
       echo Unpacking ${JPEG}.tar.gz
       tar -xzf ${JPEG}.tar.gz
     else
       echo ${JPEG}.tar.gz not found!
     fi
   fi
   if [ -d jpeg-${JPEGV} ] ; then
      echo '****************' building in jpeg-${JPEGV}
      cd jpeg-${JPEGV}
      cp jconfig.vc jconfig.h
      sed -e 's/\<cc\>/gcc/' < makefile.ansi > Makefile
      if [ $? = 0 ] ; then
         make
         if [ $? = 0 ] ; then
	        cp jpeglib.h jerror.h jconfig.h jmorecfg.h ${FINALDIR}/include
            cp libjpeg.a ${FINALDIR}/lib
         else
            echo '****' build failed for jpeg-${JPEGV}
            exit 1
         fi
      else
        echo '****' config failed for jpeg-${JPEGV}
        exit 1
      fi
      cd ..
      echo '****************' done building in jpeg-${JPEGV}
   else
     echo no directory for jpeg-${JPEGV}
   fi

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
     exit 1
   fi
}
#----------------------------------------------------------------

## build zlib
   unpack_src $ZLIB
   cd $ZLIB
   make -f win32/Makefile.gcc
   if [ $? = 0 ] ; then
      export BINARY_PATH=${FINALDIR}/bin
      export LIBRARY_PATH=${FINALDIR}/lib
      export INCLUDE_PATH=${FINALDIR}/include
      make -f win32/Makefile.gcc install
   else
      echo '****' build failed for $ZLIB
      exit 1
   fi
   cd ..
   echo '****************' done building in $ZLIB

if [ ${DOLIBGD} != 0 ] ; then
## build png
# png depends on zlib
   unpack_src $LIBPNG
   cd $LIBPNG
   ./configure --prefix=${FINALDIR}
   if [ $? = 0 ] ; then
      sed -e 's/\<SHELL\>/XSHELL/' < Makefile > Makefile-x
      mv Makefile-x Makefile
      make
      if [ $? = 0 ] ; then
         make install
      else
         echo '****' build failed for $LIBPNG
         exit 1
      fi
   else
      echo '****' config failed for $LIBPNG
      exit 1
   fi
   cd ..
   echo '****************' done building in $LIBPNG

# freetype doesnt like having these set
unset CFLAGS
unset CPPFLAGS
unset LDFLAGS

## build freetype
# freetype depends on zlib and png
   unpack_src  $FREETYPE2
   cd $FREETYPE2
   ./configure --prefix=${FINALDIR}
   rm config.mk
   cp builds/windows/w32-gcc.mk config.mk
   make
   if [ $? = 0 ] ; then
      cp -r include/freetype ${FINALDIR}/include
      cp objs/freetype.a ${FINALDIR}/lib
   else
      echo '****' build failed for $FREETYPE2
      exit 1
   fi
   cd ..
   echo '****************' done building in $FREETYPE2
 
export CFLAGS="-I${FINALDIR}/include"
export CPPFLAGS="-I${FINALDIR}/include"
export LDFLAGS="-L${FINALDIR}/lib"

# build libgd
# libgd depends on jpeg, png and freetype
   if [ ! -d $LIBGD ] ; then
     unpack_src  $LIBGD
     patch -p0 < libgd.patch
   fi
   cd $LIBGD
   ./configure --prefix=${FINALDIR} --enable-shared=no --with-zlib=${FINALDIR} --with-png=${FINALDIR} --with-freetype=${FINALDIR} --with-jpeg=${FINALDIR}

   if [ $? = 0 ] ; then
      for j in `find . -name Makefile` ; do
         sed -e 's/\<SHELL\>/XSHELL/' < $j > Makefile-x
         mv Makefile-x $j
      done
      make
      if [ $? = 0 ] ; then
         make install
      else
         echo '****' build failed for $LIBGD
         exit 1
      fi
   else
      echo '****' config failed for $LIBGD
      exit 1
   fi
   cd ..
   echo '****************' done building in $LIBGD
fi


if [ ${DONETCDF} != 0 ] ; then

# build szip
   unpack_src  $SZIP
   cd $SZIP
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
         exit 1
      fi
   else
      echo '****' config failed for $SZIP
      exit 1
   fi
   cd ..
   echo '****************' done building in $SZIP

# build curl
# curl depends on zlib
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
         exit 1
      fi
   else
      echo '****' config failed for $CURL
      exit 1
   fi
   cd ..
   echo '****************' done building in $CURL

export CFLAGS="-I${FINALDIR}/include"
export CPPFLAGS="-I${FINALDIR}/include"
export LDFLAGS="-L${FINALDIR}/lib"

# build hdf5
# hdf5 depends on szip and zlib
   unpack_src  $HDF5
   cd $HDF5
   mkdir build
   cd build
   cmake ".." \
        -G "Unix Makefiles" \
		-DCMAKE_FIND_ROOT_PATH="$FINALDIR" \
        -DBUILD_TESTING=OFF \
        -DCMAKE_C_FLAGS="-I$FINALDIR/include" \
		-DHDF5_ENABLE_Z_LIB_SUPPORT:PATH="$FINALDIR" \
        -DHDF5_ENABLE_SZIP_SUPPORT:PATH="$FINALDIR" \
		-DHDF5_BUILD_CXX:BOOL=OFF \
        -DCMAKE_INSTALL_PREFIX="$FINALDIR" \
        -DEFAULT_API_VERSION:STRING=v110

#       -DBUILD_SHARED_LIBS:BOOL=OFF \

#   ./configure --prefix=$FINALDIR --with-zlib=$FINALDIR --with-szlib=$FINALDIR --disable-shared --disable-tests --enable-build-mode=production --with-default-api-version=v110
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
   cmake "." \
        -G "Unix Makefiles" \
                -DENABLE_DAP=0 \
                -DENABLE_TESTS=0 \
                -DENABLE_BYTERANGE=0 \
                -DCURL_LIBRARIES=0 \
        -DCMAKE_FIND_ROOT_PATH=$FINALDIR \
                -DCMAKE_PREFIX_PATH=$FINALDIR \
                -DHDF5_C_LIBRARY=$FINALDIR \
                -DHDF5_ROOT=$FINALDIR \
                -DSZIP_ROOT=$FINALDIR \
                -DZLIB_ROOT=$FINALDIR \
                -DHDF5_DIR=$FINALDIR\cmake\hdf5 \
        -DCMAKE_CXX_FLAGS="-I$FINALDIR/include" \
        -DCMAKE_INSTALL_PREFIX="$FINALDIR"

#  ./configure --prefix=${FINALDIR} --enable-static --enable-shared

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

  if [ "$FC" = "ifort" ] ; then
# netcdff depends on netcdf
   unpack_src  $NETCDFF
   cd $NETCDFF
   cmake "." \
        -G "Unix Makefiles" \
        -DCMAKE_FIND_ROOT_PATH=$FINALDIR \
        -DCMAKE_INSTALL_PREFIX="$FINALDIR"

#  export LDFLAGS="-static -L${FINALDIR}/lib"
#  export LIBS="-L${FINALDIR}/lib -lnetcdf -lhdf5_hl -lhdf5 -lm -lz -lsz -lxml2 -lcurl"

#  ./configure --prefix=${FINALDIR} --enable-static --enable-shared \
#   --disable-f03-compiler-check --disable-f03 --disable-fortran-type-check

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
  fi

fi

exit 0
