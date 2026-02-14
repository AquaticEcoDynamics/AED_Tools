#!/bin/bash

if [ "${OSTYPE}" = "Darwin" ] ; then
  export INC="/opt/homebrew/include"
else
  export INC="/usr/include"
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

# netcdff depends on netcdf
   echo "====== building $NETCDFF"

   export PATH="$PATH:${FINALDIR}/bin"
   unpack_src  $NETCDFF
   cd $NETCDFF
   if [ -d build ] ; then
     /bin/rm -rf build
   fi
   mkdir build
   cd build

   if [ "${FC}" = "gfortran" ] ; then
     FARG="-fallow-argument-mismatch"
   else
     FARG=""
   fi
 # export FCFLAGS="${IFLAGS} -I${FINALDIR}/include -fallow-argument-mismatch"
 # export FFLAGS="${IFLAGS} -I${FINALDIR}/include -fallow-argument-mismatch"
   if [ "${INC}" = "" ] ; then
     export FCFLAGS="${FCFLAGS} ${FARG}"
     export FFLAGS="${FFLAGS} ${FARG}"
     export CPPFLAGS="-I${FINALDIR}/include"
     export INC="${FINALDIR}/include"
   else
     export FCFLAGS="${FCFLAGS} -I${INC} ${FARG}"
     export FFLAGS="${FFLAGS} -I${INC} ${FARG}"
     export CPPFLAGS="-I${INC} -I${FINALDIR}/include"
   fi
   export LDFLAGS="-L${FINALDIR}/lib"

   cmake ..  -G "Unix Makefiles" \
             -DCMAKE_FIND_ROOT_PATH=${FINALDIR} \
             -DBUILD_SHARED_LIBS:BOOL=OFF  \
             -DCMAKE_BUILD_TYPE:STRING=Release \
             -DENABLE_TESTS=OFF \
             -DBUILD_TESTING:BOOL=OFF \
             -DBUILD_UTILITIES:BOOL=OFF \
             -DBUILD_EXAMPLES:BOOL=OFF \
             -DNETCDF_INCLUDE_DIR="${INC}" \
             -DCMAKE_INSTALL_PREFIX="${FINALDIR}"

#  export LDFLAGS="-static -L${FINALDIR}/lib"
#  export LIBS="-L${FINALDIR}/lib -lnetcdf -lhdf5_hl -lhdf5 -lm -lz -lsz -lxml2 -lcurl"
#  export LIBS="-L/opt/local/lib -lnetcdf"
   export LIBS="-lnetcdf"

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
   if [ -d "${FINALDIR}/include/Release" ] ; then
     mv "${FINALDIR}/include/Release/"* "${FINALDIR}/include/"
     rmdir "${FINALDIR}/include/Release"
   fi
   if [ ! -f ${FINALDIR}/include/netcdf.inc ] ; then
     cp ../fortran/netcdf3.inc ${FINALDIR}/include/netcdf.inc
   fi

   cd $CWD
   echo '****************' done building in $NETCDFF

exit 0
