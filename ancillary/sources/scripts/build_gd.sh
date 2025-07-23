#!/bin/sh

if [ ! -f "$FINALDIR/lib/${LIBZA}" ] ; then
  ZLIB="zlib-$ZLIBV"
fi

FREETYPE2=freetype-${FRREETYPE2V}
JPEG=jpegsrc.v${JPEGV}
LIBPNG=libpng-${LIBPNGV}
LIBGD=lib${GD}

#---------------

CFLAGS="-I${FINALDIR}/include"
CPPFLAGS="-I${FINALDIR}/include"
LDFLAGS="-L${FINALDIR}/lib"

#---------------
summary () {
  where=$1
  echo "==================================="
  echo "$FINALDIR after building $1"
  ls $FINALDIR
  echo 'include'
  ls $FINALDIR/include
  echo 'lib'
  ls $FINALDIR/lib
  echo "==================================="
  echo
}

#---------------
if [ ! -d $FINALDIR/include ] ; then
  mkdir $FINALDIR/include
fi
if [ ! -d $FINALDIR/lib ] ; then
  mkdir $FINALDIR/lib
fi
#---------------

if [ "$ZLIB" != "" ] ; then
  ./scripts/build_libz.sh
  if [ $? != 0 ] ; then
    exit 1
  fi
fi

#---------------

if [ "$JPEG" != "" ] ; then
  \rm -rf jpeg-$JPEGV
  tar xzf $JPEG.tar.gz
  cd jpeg-$JPEGV

# not sure we still need to do the vc version
# cp jconfig.vc jconfig.h
  cp jconfig.txt jconfig.h

  sed -e 's/\<cc\>/gcc/' < makefile.ansi > Makefile
  make
  if [ $? != 0 ] ; then
    echo $JPEG build failed
    exit 1
  fi
  cp jpeglib.h jerror.h jconfig.h jmorecfg.h ${FINALDIR}/include
  cp libjpeg.a ${FINALDIR}/lib/

  cd $CWD

  summary $JPEG
fi

#---------------

if [ "$LIBPNG" != "" ] ; then
  \rm -rf $LIBPNG
  tar xzf $LIBPNG.tar.gz
  cd $LIBPNG
  mkdir build
  cd build

  cmake .. -G "Unix Makefiles" \
           -DCMAKE_FIND_ROOT_PATH="$FINALDIR" \
           -DCMAKE_BUILD_TYPE:STRING=Release \
           -DBUILD_SHARED_LIBS:BOOL=OFF \
           -DBUILD_STATIC_LIBS:BOOL=ON \
           -DZLIB_LIBRARY_RELEASE:FILEPATH="$FINALDIR/lib/${LIBZA}" \
           -DCMAKE_INSTALL_PREFIX="$FINALDIR" -LAH > $FINALDIR/cmake-info-libpng 2>&1
  if [ $? != 0 ] ; then
    echo cmake $LIBPNG failed
    exit 1
  fi

  cmake --build . --clean-first --config Release #--target INSTALL
  if [ $? != 0 ] ; then
    echo $LIBPNG build failed
    exit 1
  fi
  cmake -P cmake_install.cmake
# /bin/rm $FINALDIR/lib/libpng16.dll.a
# /bin/rm $FINALDIR/lib/libpng.dll.a

  cd $CWD

  summary $LIBPNG
fi

#---------------

if [ "$FREETYPE2" != "" ] ; then
  \rm -rf $FREETYPE2
  tar xzf $FREETYPE2.tar.gz
  cd $FREETYPE2
  mkdir build
  cd build

  cmake .. -G "Unix Makefiles" \
           -DCMAKE_FIND_ROOT_PATH="$FINALDIR" \
           -DCMAKE_BUILD_TYPE:STRING=Release \
           -DBUILD_SHARED_LIBS:BOOL=OFF \
           -DBUILD_STATIC_LIBS:BOOL=ON \
           -DZLIB_LIBRARY_RELEASE:FILEPATH="$FINALDIR/lib/${LIBZA}" \
           -DPNG_LIBRARY_RELEASE:FILEPATH="$FINALDIR/lib/libpng.a" \
           -DCMAKE_INSTALL_PREFIX="$FINALDIR" -LAH > $FINALDIR/cmake-info-libfreetype 2>&1
  if [ $? != 0 ] ; then
    echo cmake $FREETYPE2 failed
    exit 1
  fi

  cmake --build . --clean-first --config Release #--target INSTALL
  if [ $? != 0 ] ; then
    echo $FREETYPE2 build failed
    exit 1
  fi
  cmake -P cmake_install.cmake

  cd $CWD

  summary $FREETYPE2
fi

#---------------

if [ "$LIBGD" != "" ] ; then
  \rm -rf $LIBGD
  tar xzf $LIBGD.tar.gz
  cd $LIBGD

  mkdir build
  cd build

  cmake .. -G "Unix Makefiles" \
           -DCMAKE_FIND_ROOT_PATH="$FINALDIR" \
           -DCMAKE_BUILD_TYPE:STRING=Release \
           -DENABLE_JPEG:BOOL=ON \
           -DENABLE_PNG:BOOL=ON  \
           -DENABLE_FREETYPE:BOOL=ON \
           -DVERBOSE_MAKEFILE:BOOL=TRUE \
           -DZLIB_LIBRARY_RELEASE:FILEPATH="$FINALDIR/lib/${LIBZA}" \
           -DPNG_LIBRARY_RELEASE:FILEPATH="$FINALDIR/lib/libpng.a" \
           -DCMAKE_INSTALL_PREFIX="$FINALDIR" -LAH > $FINALDIR/cmake-info-libgd 2>&1
  if [ $? != 0 ] ; then
    echo cmake $LIBGD failed
    exit 1
  fi

# For some reason including these builds a lib that is missing symbols on windows
#          -DBUILD_SHARED_LIBS:BOOL=OFF \
#          -DBUILD_STATIC_LIBS:BOOL=ON \

  cmake --build . --clean-first --config Release #--target INSTALL
  if [ $? != 0 ] ; then
    echo $LIBGD build failed
    exit 1
  fi
  cmake -P cmake_install.cmake

  cd $CWD

  summary $LIBGD
fi

#---------------

exit 0
