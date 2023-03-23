#!/bin/sh

CWD=`pwd`

if [ "$FC" = "" ] ; then
  export FC=gfortran
fi
export MAKE=make
export OSTYPE=`uname -s`
if [ "$OSTYPE" = "FreeBSD" ] ; then
  export MAKE=gmake
  export FC=flang
fi

for i in water benthic riparian demo dev light fv ; do
   echo clean libaed-$i
   if [ -d libaed-$i ] ; then
     cd  libaed-$i
     ${MAKE} distclean
     cd $CWD
   fi
done

for i in libaed2 libaed2-plus libplot libutil GLM ; do
   echo clean $i
   if [ -d $i ] ; then
     cd  $i
     ${MAKE} distclean
     cd $CWD
   fi
done

if [ "$OSTYPE" = "FreeBSD" ] ; then
  cd ancillary/freebsd
  ${MAKE} distclean
  # the rest are currently not supported on FreeBSD anyway
  exit 0
fi

if [ -d gotm-git ] ; then
  echo cleaning in gotm-git
  export GOTMDIR=${CWD}/gotm-git
  export FORTRAN_COMPILER=IFORT
  cd gotm-git
  ${MAKE} distclean
  cd $CWD
fi

if [ -d tuflowfv-svn ] ; then
  if [ "${OSTYPE}" = "Linux" ] ; then
    PLATFORM=linux_ifort
  elif [ "${OSTYPE}" = "Darwin" ] ; then
    PLATFORM=macos_ifort
  fi
  if [ "$OSTYPE" != "FreeBSD" ] ; then
    export FC=ifort
  fi

  if [ -d ${CWD}/tuflowfv-svn/platform/${PLATFORM} ] ; then
    echo cleaning tuflowfv
    cd ${CWD}/tuflowfv-svn/platform/${PLATFORM}
    ${MAKE} clean
  fi
fi
if [ -d ancillary/ifort/lib ] ; then
  /bin/rm -rf ancillary/ifort/lib
fi
if [ -d ancillary/ifort/include ] ; then
  /bin/rm -rf ancillary/ifort/include
fi
if [ -d ancillary/ifort/bin ] ; then
  /bin/rm -rf ancillary/ifort/bin
fi
if [ -d ancillary/ifort/share ] ; then
  /bin/rm -rf ancillary/ifort/share
fi

cd $CWD
if [ -d schism ] ; then
  if [ -d schism/build ] ; then
    echo cleaning schism
    /bin/rm -rf schism/build
    /bin/rm schism/cmake/SCHISM.*.aed
  fi
  if [ -f schish/mk/Make.defs.local ] ; then
    echo cleaning schism
    cd schism/src
    ${MAKE} clean
    cd ../mk
    /bin/rm Make.defs.aed Make.defs.local
    cd $CWD
  fi
fi

exit 0
