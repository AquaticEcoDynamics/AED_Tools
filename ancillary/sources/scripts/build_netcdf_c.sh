#!/bin/bash

  echo "====== building $NETCDF"

  export CFLAGS="-I${FINALDIR}/include"
  export CPPFLAGS="-I${FINALDIR}/include"
  export LDFLAGS="-L${FINALDIR}/lib"

  \rm -rf $NETCDF
  tar xzf $NETCDF.tar.gz
  cd $NETCDF
  if [ ! -d fuzz ] ; then
    mkdir fuzz
    touch fuzz/CMakeLists.txt
  fi

  mkdir build
  cd build

  cmake .. -G "Unix Makefiles" \
           -DCMAKE_FIND_ROOT_PATH="${FINALDIR}"  \
           -DBUILD_SHARED_LIBS:BOOL=ON \
           -DCMAKE_BUILD_TYPE:STRING=Release \
           -DCURL_LIBRARIES=OFF \
           -DENABLE_TESTS=OFF \
           -DENABLE_DAP=OFF \
           -DBUILD_UTILITIES:BOOL=OFF \
           -DENABLE_BYTERANGE:BOOL=OFF \
           -DENABLE_NCZARR:BOOL=OFF \
           -DCMAKE_MODULE_LINKER_FLAGS:STRING=-L"${FINALDIR}/lib" \
           -DZLIB_LIBRARY:PATH="${FINALDIR}/lib/${LIBZA}"  \
           -DSZIP_LIBRARY:PATH="${FINALDIR}/lib/libsz.a"  \
           -DCMAKE_INSTALL_PREFIX="${FINALDIR}" -LAH 

#  > ${FINALDIR}/cmake-info-netcdf-c 2>&1

#          -DZLIB_LIBRARY:PATH="${FINALDIR}/lib/${LIBZA}"  \
#          -DSZIP_LIBRARY:PATH="${FINALDIR}/lib/libsz.a"  \

#          -DBUILD_SHARED_LIBS:BOOL=ON \
#          -DCMAKE_BUILD_TYPE:STRING=Release \
#          -DHDF5_C_LIBRARY="${FINALDIR}" \
#          -DHDF5_ROOT="${FINALDIR}" \
#          -DSZIP_ROOT="${FINALDIR}" \
#          -DZLIB_ROOT="${FINALDIR}" \
#          -DHDF5_DIR="${FINALDIR}/cmake/hdf5" \
#          -DCMAKE_VERBOSE_MAKEFILE:BOOL=TRUE \
  
  if [ $? != 0 ] ; then
    echo cmake $NETCDF failed
    exit 1
  fi

  cmake --build . --clean-first --config Release #--target INSTALL
  if [ $? != 0 ] ; then
    echo $NETCDF build failed
    exit 1
  fi
  cmake -P cmake_install.cmake

  cd $CWD

exit 0
