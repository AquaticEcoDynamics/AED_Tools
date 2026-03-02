# ===========================================================================

if [ "${OSTYPE}" = "Darwin" ] ; then
  export INC="/opt/homebrew/include"
else
  export INC="/usr/include"
fi

#----------------------------------------------------------------

if [ "$NETCDFF" != "" ] ; then
#if [ ! -f "${FINALDIR}/lib/libnetcdff.a" ] ; then
# netcdff depends on netcdf
  echo "====== building $NETCDFF"

  export PATH="${FINALDIR}/bin:$PATH"
  /bin/rm -rf $NETCDFF
  tar -xzf $NETCDFF.tar.gz
  if [ ! -d $NETCDFF ] ; then
    echo cant unpack $NETCDFF.tar.gz
    exit 1
  fi
  cd $NETCDFF
  mkdir build
  cd build

  cmake .. -G "Unix Makefiles" \
           -DCMAKE_FIND_ROOT_PATH=${FINALDIR} \
           -DCMAKE_BUILD_TYPE:STRING=Release \
           -DBUILD_SHARED_LIBS:BOOL=ON \
           -DENABLE_TESTS=OFF \
           -DBUILD_TESTING:BOOL=OFF \
           -DBUILD_UTILITIES:BOOL=OFF \
           -DBUILD_EXAMPLES:BOOL=OFF \
           -DNETCDF_C_INCLUDE_DIR="${INC}" \
           -DNETCDF_C_LIBRARY="${FINALDIR}/lib/libnetcdf.so" \
           -DCMAKE_INSTALL_PREFIX="${FINALDIR}" -LAH > ${FINALDIR}/cmake-info-netcdf-f 2>&1

#          -DBUILD_SHARED_LIBS:BOOL=OFF  \
#          -DBUILD_STATIC_LIBS:BOOL=ON \

#          -DHDF5_hdf5_LIBRARY_RELEASE:FILEPATH="${FINALDIR}/lib/libhdf5.a" \
#          -DHDF5_hdf5_hl_LIBRARY_RELEASE:FILEPATH="${FINALDIR}/lib/libhdf5_hl.a" \
#          -DHDF5_DIR:PATH="${FINALDIR}/cmake" \
#          -DHDF5_C_INCLUDE_DIR:PATH="${FINALDIR}/include" \
#          -DHDF5_C_COMPILER_EXECUTABLE:FILEPATH="${FINALDIR}/bin/h5cc" \


  if [ $? != 0 ] ; then
    echo $NETCDFF cmake failed
    exit 1
  fi

  cmake --build . --clean-first --config Release #--target INSTALL
  if [ $? != 0 ] ; then
    echo $NETCDFF build failed
    exit 1
  fi
  cmake -P cmake_install.cmake
  if [ $? != 0 ] ; then
     echo $NETCDFF install failed
    exit 1
  fi

  cd $CWD

  summary $NETCDFF
fi
