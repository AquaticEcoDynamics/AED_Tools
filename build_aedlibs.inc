
cd ${CWD}
get_commit_id > cur_state.log

echo "build libaed-water"
cd "${CWD}/libaed-water"
get_commit_id >> ${CWD}/cur_state.log
${MAKE} || exit 1
DAEDWATDIR=`pwd`
if [ -d "${CWD}/libaed-benthic" ] ; then
  echo build libaed-benthic
  cd "${CWD}/libaed-benthic"
  get_commit_id >> ${CWD}/cur_state.log
  ${MAKE} || exit 1
  DAEDBENDIR=`pwd`
fi

if [ -d "${CWD}/libaed-demo" ] ; then
  echo build libaed-demo
  cd "${CWD}/libaed-demo"
  get_commit_id >> ${CWD}/cur_state.log
  ${MAKE} || exit 1
  DAEDDMODIR=`pwd`
fi

if [ "$WITH_AED_PLUS" = "true" ] ; then
  if [ -d "${CWD}/libaed-riparian" ] ; then
    echo build libaed-riparian
    cd "${CWD}/libaed-riparian"
    get_commit_id >> ${CWD}/cur_state.log
    ${MAKE} || exit 1
    DAEDRIPDIR=`pwd`
  fi

  if [ -d "${CWD}/libaed-light" ] ; then
    echo build libaed-light
    cd "${CWD}/libaed-light"
    get_commit_id >> ${CWD}/cur_state.log
    ${MAKE} || exit 1
    DAEDLGTDIR=`pwd`
  fi

  if [ -d "${CWD}/libaed-dev" ] ; then
    if [ -d "${CWD}/phreeqcrm" ] ; then
      PHREEQDIR="${CWD}/phreeqcrm"
      cd "${CWD}/phreeqcrm"
      mkdir build
      # build fortran test OFF
      sed -i -e 's/option(PHREEQCRM_FORTRAN_TESTING "Build Fortran test" OFF)/option(PHREEQCRM_FORTRAN_TESTING "Build Fortran test" ON)/' CMakeLists.txt
      cd build
      cmake ..
      # build CMakeCache.txt fix"
      sed -i -e 's/fiopenmp/fopenmp -fPIE/' CMakeCache.txt
      ${MAKE}
      if [ ! -f libPhreeqcRM.a ] ; then
        echo building libPhreeqcRM.a failed
        unset PHREEQDIR
      fi
    fi

    echo build libplot
    cd "${CWD}/libplot"
    get_commit_id >> ${CWD}/cur_state.log
    ${MAKE} || exit 1

    echo build libutil
    cd "${CWD}/libutil"
    get_commit_id >> ${CWD}/cur_state.log
    ${MAKE} || exit 1

    echo build libaed-dev
    cd "${CWD}/libaed-dev"
    get_commit_id >> ${CWD}/cur_state.log
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
  get_commit_id >> ${CWD}/cur_state.log
  ${MAKE} || exit 1
  ${MAKE} obj/aed_external.o
  DAEDAPIDIR=`pwd`
fi

cd ${CWD}
