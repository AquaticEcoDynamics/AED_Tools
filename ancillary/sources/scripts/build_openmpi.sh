#!/bin/sh

. ./versions.inc

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

echo "====== building $OMPI"

\rm -rf $OMPI
tar xzf $OMPI.tar.gz
cd $OMPI

if [ "$OSNAME" = "Darwin" ] ; then
  # on macos we'll need --with-libevent=/opt/homebrew
  EXTRA_CONF="--with-libevent=/opt/homebrew"
else
  EXTRA_CONF=""
fi

./configure --prefix=${FINALDIR} --enable-shared=no ${EXTRA_CONF}
if [ $? = 0 ] ; then
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

cd $CWD
summary $OMPI

exit 0
