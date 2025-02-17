
echo "build libaed-water"
cd "${CWD}/libaed-water"
${MAKE} || exit 1
DAEDWATDIR=`pwd`
if [ -d "${CWD}/libaed-benthic" ] ; then
  echo build libaed-benthic
  cd "${CWD}/libaed-benthic"
  ${MAKE} || exit 1
  DAEDBENDIR=`pwd`
fi

if [ -d "${CWD}/libaed-demo" ] ; then
  echo build libaed-demo
  cd "${CWD}/libaed-demo"
  ${MAKE} || exit 1
  DAEDDMODIR=`pwd`
fi

if [ "$WITH_AED_PLUS" = "true" ] ; then
  if [ -d "${CWD}/libaed-riparian" ] ; then
    echo build libaed-riparian
    cd "${CWD}/libaed-riparian"
    ${MAKE} || exit 1
    DAEDRIPDIR=`pwd`
  fi

  if [ -d "${CWD}/libaed-light" ] ; then
    echo build libaed-light
    cd "${CWD}/libaed-light"
    ${MAKE} || exit 1
    DAEDLGTDIR=`pwd`
  fi

  if [ -d "${CWD}/libaed-dev" ] ; then
    if [ -d "${CWD}/phreeqcrm" ] ; then
      PHREEQDIR="${CWD}/phreeqcrm"
      cd "${CWD}/phreeqcrm"
      mkdir build
      sed -i -e 's/option(PHREEQCRM_FORTRAN_TESTING "Build Fortran test" OFF)/option(PHREEQCRM_FORTRAN_TESTING "Build Fortran test" ON)/' CMakeLists.txt
      cd build
      cmake ..
      ${MAKE}
      if [ ! -f libPhreeqcRM.a ] ; then
        echo building libPhreeqcRM.a failed
        unset PHREEQDIR
      fi
    fi

 #  echo build libplot
 #  cd "${CWD}/libplot"
 #  ${MAKE} || exit 1

    echo build libaed-dev
    cd "${CWD}/libaed-dev"
    if [ "$PHREEQDIR" != "" ] ; then
      ${MAKE} PHREEQDIR=$PHREEQDIR || exit 1
    else
      ${MAKE} || exit 1
    fi
    DAEDDEVDIR=`pwd`
  fi
fi

if [ -d "${CWD}/libaed-api" ] ; then
  echo build libaed-api
  cd "${CWD}/libaed-api"
  ${MAKE} || exit 1
  ${MAKE} obj/aed_external.o
  DAEDAPIDIR=`pwd`
fi

cd ${CWD}
