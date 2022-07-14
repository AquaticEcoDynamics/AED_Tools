#!/bin/sh

export ZLIBV=1.2.12
export FRREETYPE2V=2.12.1
export JPEGV=9e
export LIBPNGV=1.6.37
export GD=gd-2.3.3

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

export DSTDIR=msys
export ZLIB=zlib-${ZLIBV}
export FREETYPE2=freetype-${FRREETYPE2V}
export JPEG=jpegsrc.v${JPEGV}
export LIBPNG=libpng-${LIBPNGV}
export LIBGD=lib${GD}

if [ ! -f ${ZLIB}.tar.gz ] ; then
   curl  http://www.zlib.net/${ZLIB}.tar.gz -o ${ZLIB}.tar.gz
   if [ $? != 0 ] ; then
      echo failed to fetch ${ZLIB}.tar.gz
   fi
fi

if [ ! -f ${FREETYPE2}.tar.gz ] ; then
   curl  -L https://download.savannah.gnu.org/releases/freetype/${FREETYPE2}.tar.gz -o ${FREETYPE2}.tar.gz
   if [ $? != 0 ] ; then
      echo failed to fetch ${FREETYPE2}.tar.gz
   fi
fi

if [ ! -f ${JPEG}.tar.gz ] ; then
   curl  http://www.ijg.org/files/${JPEG}.tar.gz -o ${JPEG}.tar.gz
   if [ $? != 0 ] ; then
      echo failed to fetch ${JPEG}.tar.gz
   fi
fi

if [ ! -f ${LIBPNG}.tar.gz ] ; then
   curl  -L http://prdownloads.sourceforge.net/libpng/${LIBPNG}.tar.gz -o ${LIBPNG}.tar.gz
   if [ $? != 0 ] ; then
      echo failed to fetch ${LIBPNG}.tar.gz
   fi
fi

if [ ! -f ${LIBGD}.tar.gz ] ; then
   curl  -L https://github.com/libgd/libgd/releases/download/${GD}/${LIBGD}.tar.gz -o ${LIBGD}.tar.gz
   if [ $? != 0 ] ; then
      echo failed to fetch ${LIBGD}.tar.gz
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
            echo '****' build failed for jpeg-${JPEGV} >> fail.log
            exit 1
         fi
      else
        echo '****' config failed for jpeg-${JPEGV}
        echo '****' config failed for jpeg-${JPEGV} >> fail.log
        exit 1
      fi
      cd ..
      echo '****************' done building in jpeg-${JPEGV}
   else
     echo no directory for jpeg-${JPEGV}
     echo no directory for jpeg-${JPEGV} >> fail.log
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
     echo no directory for $src >> fail.log
     exit 1
   fi
}
#----------------------------------------------------------------

## build zlib
   unpack_src  $ZLIB
   cd $ZLIB
   make -f win32/Makefile.gcc
   if [ $? = 0 ] ; then
      export BINARY_PATH=${FINALDIR}/bin
      export LIBRARY_PATH=${FINALDIR}/lib
      export INCLUDE_PATH=${FINALDIR}/include
      make -f win32/Makefile.gcc install
   else
      echo '****' build failed for $ZLIB
      echo '****' build failed for $ZLIB >> fail.log
      exit 1
   fi
   cd ..
   echo '****************' done building in $ZLIB

## build png
# png depends on zlib
   unpack_src  $LIBPNG
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
         echo '****' build failed for $LIBPNG >> fail.log
         exit 1
      fi
   else
      echo '****' config failed for $LIBPNG
      echo '****' config failed for $LIBPNG >> fail.log
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
      echo '****' build failed for $FREETYPE2 >> fail.log
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
         echo '****' build failed for $LIBGD >> fail.log
         exit 1
      fi
   else
      echo '****' config failed for $LIBGD
      echo '****' config failed for $LIBGD >> fail.log
      exit 1
   fi
   cd ..
   echo '****************' done building in $LIBGD

exit 0
