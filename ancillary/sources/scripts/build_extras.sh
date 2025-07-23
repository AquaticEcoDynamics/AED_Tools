#!/bin/sh

if [ ! -f "${FINALDIR}/lib/${LIBZA}" ] ; then
  ZLIB="zlib-$ZLIBV"
fi

CURL="curl-$CURLV"
LIBAEC="libaec-${LIBAECV}"
HDF5="hdf5-$HDF5V"
NETCDF="netcdf-c-$NETCDFV"
NETCDFF="netcdf-fortran-$NETCDFFV"

#---------------

CFLAGS="-I${FINALDIR}/include"
CPPFLAGS="-I${FINALDIR}/include"
LDFLAGS="-L${FINALDIR}/lib"

#---------------

summary () {
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
  ./scripts/build_libz.sh || exit 1
  if [ $? != 0 ] ; then
    exit 1
  fi
fi

#---------------

if [ "$LIBAEC" != "" ] ; then
  echo "====== building $LIBAEC"

  \rm -rf $LIBAEC
  tar xzf $LIBAEC.tar.gz
  cd $LIBAEC
  mkdir build
  cd build

  cmake .. -G "Unix Makefiles" \
           -DCMAKE_FIND_ROOT_PATH="${FINALDIR}" \
           -DBUILD_SHARED_LIBS:BOOL=OFF \
           -DCMAKE_BUILD_TYPE:STRING=Release \
           -DCMAKE_INSTALL_PREFIX="${FINALDIR}" -LAH > ${FINALDIR}/cmake-info-libaec 2>&1
  if [ $? != 0 ] ; then
    echo cmake $LIBAEC failed
    exit 1
  fi

  cmake --build . --clean-first --config Release #--target INSTALL
  if [ $? != 0 ] ; then
    echo $LIBAEC build failed
    exit 1
  fi
  cmake -P cmake_install.cmake
  /bin/rm ${FINALDIR}/lib/libsz.dll.a

  cd $CWD

  summary $LIBAEC
fi

#---------------

if [ "$CURL" != "" ] ; then
  echo "====== building $CURL"

  \rm -rf $CURL
  tar xzf $CURL.tar.gz
  cd $CURL
  mkdir build
  cd build

  cmake .. -G "Unix Makefiles" \
           -DCMAKE_FIND_ROOT_PATH="${FINALDIR}" \
           -DBUILD_SHARED_LIBS:BOOL=OFF \
           -DBUILD_STATIC_CURL:BOOL=ON \
           -DCMAKE_BUILD_TYPE:STRING=Release \
           -DZLIB_LIBRARY_RELEASE:FILEPATH="${FINALDIR}/lib/${LIBZA}" \
           -DCMAKE_INSTALL_PREFIX="${FINALDIR}" -LAH > ${FINALDIR}/cmake-info-curl 2>&1
  if [ $? != 0 ] ; then
    echo cmake $CURL failed
    exit 1
  fi

  cmake --build . --clean-first --config Release #--target INSTALL
  if [ $? != 0 ] ; then
    echo $CURL build failed
    exit 1
  fi
  cmake -P cmake_install.cmake

  cd $CWD

  summary $CURL
fi

#---------------

if [ "$HDF5" != "" ] ; then
  echo "====== building $HDF5"

  \rm -rf $HDF5
  tar xzf $HDF5.tar.gz
  cd $HDF5
  mkdir build
  cd build

  cmake .. -G "Unix Makefiles" \
           -DCMAKE_FIND_ROOT_PATH="${FINALDIR}"  \
           -DBUILD_SHARED_LIBS:BOOL=OFF \
           -DCMAKE_BUILD_TYPE:STRING=Release \
           -DBUILD_TESTING=OFF  \
           -DCMAKE_C_FLAGS="-I${FINALDIR}/include"  \
           -DHDF5_ENABLE_Z_LIB_SUPPORT:PATH="${FINALDIR}"  \
           -DHDF5_ENABLE_SZIP_SUPPORT:PATH="${FINALDIR}" \
           -Dlibaec_DIR="${FINALDIR}" \
           -Dlibaec_LIBRARY="${FINALDIR}/lib/libaec.a" \
           -DZLIB_DIR:PATH="${FINALDIR}" \
           -DZLIB_LIBRARY:PATH="${FINALDIR}/lib/${LIBZA}"  \
           -DSZIP_LIBRARY:PATH="${FINALDIR}/lib/libsz.a"  \
           -DHDF5_BUILD_CXX:BOOL=OFF \
           -DHDF5_BUILD_FORTRAN:BOOL=OFF \
           -DCMAKE_INSTALL_PREFIX="${FINALDIR}" -LAH > ${FINALDIR}/cmake-info-hdf5 2>&1

#          -DZLIB_INCLUDE_DIR="${FINALDIR}/include"  \
#          -DSZIP_INCLUDE_DIR="${FINALDIR}/include"  \
#          -DDEFAULT_API_VERSION:STRING=v110  \

  if [ $? != 0 ] ; then
    echo cmake $HDF5 failed
    exit 1
  fi

  cmake --build . --clean-first --config Release #--target INSTALL
  if [ $? != 0 ] ; then
    echo $HDF5 build failed
    exit 1
  fi
  cmake -P cmake_install.cmake

  cd $CWD

  summary $HDF5
fi

#---------------

exit 0
