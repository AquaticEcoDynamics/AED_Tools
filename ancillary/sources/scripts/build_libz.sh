#!/bin/sh

if [ ! -f "${FINALDIR}/lib/${LIBZA}" ] ; then
  ZLIB="zlib-$ZLIBV"
fi

#---------------

CFLAGS="-I${FINALDIR}/include"
CPPFLAGS="-I${FINALDIR}/include"
LDFLAGS="-L${FINALDIR}/lib"

#---------------
summary () {
  where=$1
  echo "==================================="
  echo "${FINALDIR} after building $1"
  ls ${FINALDIR}
  echo 'include'
  ls ${FINALDIR}/include
  echo 'lib'
  ls ${FINALDIR}/lib
  echo "==================================="
  echo
}


#---------------
if [ ! -d ${FINALDIR}/include ] ; then
  mkdir ${FINALDIR}/include
fi
if [ ! -d ${FINALDIR}/lib ] ; then
  mkdir ${FINALDIR}/lib
fi
#---------------

if [ "$ZLIB" != "" ] ; then
  echo "====== building $ZLIB"

  \rm -rf $ZLIB
  tar xzf $ZLIB.tar.gz
  cd $ZLIB
  mkdir build
  cd build

  cmake .. -G "Unix Makefiles" \
           -DCMAKE_FIND_ROOT_PATH="${FINALDIR}" \
           -DBUILD_SHARED_LIBS:BOOL=OFF \
           -DZLIB_BUILD_EXAMPLES:BOOL=OFF \
           -DCMAKE_BUILD_TYPE:STRING=Release \
           -DCMAKE_INSTALL_PREFIX="${FINALDIR}" -LAH > ${FINALDIR}/cmake-info-zlib 2>&1
  if [ $? != 0 ] ; then
    echo cmake $ZLIB failed
    exit 1
  fi

  cmake --build . --clean-first --config Release #--target INSTALL
  if [ $? != 0 ] ; then
    echo $ZLIB build failed
    exit 1
  fi
  cmake -P cmake_install.cmake

# ln -s $FINALDIR/lib/libz.a $FINALDIR/lib/libzlibstatic.a

  cd $CWD

  summary $ZLIB
fi
#---------------

exit 0
