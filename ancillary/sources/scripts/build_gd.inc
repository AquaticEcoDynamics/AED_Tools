# ===========================================================================

. ./scripts/build_zlib.inc

#---------------

if [ "$JPEG" != "" ] ; then
#if [ ! -f "${FINALDIR}/lib/libjpeg.a" ] ; then
  echo "====== building $JPEG"

  \rm -rf jpeg-$JPEGV
  tar xzf $JPEG.tar.gz
  if [ ! -d jpeg-$JPEGV ] ; then
    echo cant unpack $JPEG.tar.gz
    exit 1
  fi
  cd jpeg-$JPEGV

# not sure we still need to do the vc version
# cp jconfig.vc jconfig.h
  cp jconfig.txt jconfig.h

  /usr/bin/sed -e 's/\<cc\>/gcc/' < makefile.ansi | sed -e 's/CFLAGS= -O/CFLAGS= -O2 -fPIC/' > Makefile
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
#if [ ! -f "${FINALDIR}/lib/libpng.a" ] ; then
  echo "====== building $LIBPNG"

  \rm -rf $LIBPNG
  tar xzf $LIBPNG.tar.gz
  if [ ! -d $LIBPNG ] ; then
    echo cant unpack $LIBPNG.tar.gz
    exit 1
  fi
  cd $LIBPNG
  mkdir build
  cd build

  cmake .. -G "Unix Makefiles" \
           -DCMAKE_FIND_ROOT_PATH="$FINALDIR" \
           -DCMAKE_BUILD_TYPE:STRING=Release \
           -DPNG_SHARED:BOOL=OFF \
           -DPNG_STATIC:BOOL=ON \
           -DPNG_TESTS:BOOL=OFF \
           -DPNG_TOOLS:BOOL=OFF \
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
#if [ ! -f "${FINALDIR}/lib/libfreetype.a" ] ; then
  echo "====== building $FREETYPE2"

  \rm -rf $FREETYPE2
  tar xzf $FREETYPE2.tar.gz
  if [ ! -d $FREETYPE2 ] ; then
    echo cant unpack $FREETYPE2.tar.gz
    exit 1
  fi
  cd $FREETYPE2
  mkdir build
  cd build

  cmake .. -G "Unix Makefiles" \
           -DCMAKE_FIND_ROOT_PATH="$FINALDIR" \
           -DCMAKE_BUILD_TYPE:STRING=Release \
           -DBUILD_SHARED_LIBS:BOOL=OFF \
           -DBUILD_STATIC_LIBS:BOOL=ON \
           -DFT_DISABLE_BZIP2=TRUE \
           -DFT_DISABLE_BROTLI=TRUE \
           -DFT_DISABLE_HARFBUZZ=TRUE \
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

#if [ "$LIBGD" != "" ] ; then
if [ ! -f "${FINALDIR}/lib/libgd.a" ] ; then
  echo "====== building $LIBGD"

  \rm -rf $LIBGD
  tar xzf $LIBGD.tar.gz
  if [ ! -d $LIBGD ] ; then
    echo cant unpack $LIBGD.tar.gz
    exit 1
  fi
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
