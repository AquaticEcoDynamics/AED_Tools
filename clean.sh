#!/bin/sh

CWD=`pwd`
DO_ANC="false"
SQUEEKY=false

while [ $# -gt 0 ] ; do
  case $1 in
    --debug)
      export DEBUG=true
      ;;
    --squeeky)
      export SQUEEKY=true
      export DO_ANC=true
      ;;
    --ancillary)
      export DO_ANC=true
      ;;
    --no-ancillary)
      export DO_ANC=false
      ;;
    --gfort)
      export FC=gfortran
      ;;
    --ifx)
      export FC=ifx
      ;;
    --ifort)
      export FC=ifort
      ;;
    --flang)
      export FC=flang
      ;;
    *)
      echo "unknown option \"$1\""
      ;;
  esac
  shift
done

if [ -f "cur_state.log" ] ; then
  /bin/rm cur_state.log
fi

if [ "$FC" = "" ] ; then
  export FC=gfortran
fi
export MAKE=make
export OSTYPE=`uname -s`
if [ "$OSTYPE" = "FreeBSD" ] ; then
  export MAKE=gmake
  export FC=flang
fi

for i in api water benthic riparian demo dev light fv fv2 ; do
   if [ -d libaed-$i ] ; then
     echo clean libaed-$i
     cd libaed-$i
     ${MAKE} distclean
     if [ -d win/x64-Release ] ; then
       /bin/rm -rf win/x64-Release
     fi
     cd "$CWD"
   fi
done

for i in libaed2 libaed2-plus libplot libutil GLM zeroD ; do
   if [ -d $i ] ; then
     echo clean $i
     cd $i
     ${MAKE} distclean
     cd "$CWD"
   fi
done

cd "$CWD"
if [ -d phreeqcrm ] ; then
  echo cleaning in phreeqcrm
  cd phreeqcrm
  if [ -d build ] ; then
    echo cleaning phreeqcrm
    /bin/rm -rf build
    git checkout .
  fi
  cd "$CWD"
fi

if [ -d fabm-git ] ; then
  echo clean fabm-git
  cd fabm-git
  if [ -d build ] ; then
    /bin/rm -rf build
  fi
  cd "$CWD"
fi

if [ -d gotm-git ] ; then
  echo cleaning in gotm-git
  export GOTMDIR=${CWD}/gotm-git
  export FORTRAN_COMPILER=IFORT
  cd gotm-git
  ${MAKE} distclean
  cd "$CWD"
fi

if [ -d swan ] ; then
  echo cleaning in swan
  cd swan
  cmake -P clobber.cmake
  cd "$CWD"
fi

if [ -d tuflowfv ] ; then
  if [ "$OSTYPE" != "FreeBSD" ] ; then
    export FC=ifort
  fi

  echo cleaning tuflowfv
  cd ${CWD}/tuflowfv
  ${MAKE} clean

  cd "$CWD"
fi

if [ -d ELCOM ] ; then
  echo cleaning ELCOM
  cd ELCOM
  ./clean.sh
  cd "$CWD"
fi

if [ -d modflow6 ] ; then
  echo cleaning modflow6
  cd modflow6/make
  make clean
  cd "$CWD"
fi

if [ "$DO_ANC" = "true" ] ; then
  cd ancillary
  if [ "$SQUEEKY" = "true" ] ; then
    ./clean_anc.sh --squeeky
  else
    ./clean_anc.sh
  fi
  cd "$CWD"
fi

cd "$CWD"
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
    cd "$CWD"
  fi
  if [ -f schism/src/AED/CMakeLists.txt ] ; then
    /bin/rm schism/src/AED/CMakeLists.txt
  fi
fi

cd "$CWD"
if [ -d swan ] ; then
  if [ -d swan/build ] ; then
    echo cleaning swan
    /bin/rm -rf swan/build
  fi
fi

if [ "$SQUEEKY" = "true" ] ; then
  export FILELST=`find . -name \*.u2d | grep -w win`
  if [ "$FILELST" != "" ] ; then
    /bin/rm $FILELST
  fi
  export FILELST=`find . -name .vs | grep -w win`
  if [ "$FILELST" != "" ] ; then
    /bin/rm -r $FILELST
  fi
fi

exit 0
