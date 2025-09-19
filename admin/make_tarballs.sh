#!/bin/sh

CWD=`pwd`

./clean.sh # start by cleaning the respositories


if [ -d tttt ] ; then
   /bin/rm -rf tttt
fi

do_tarball () {
   BASEN=$1
   VERSN=$2
   echo $1 $2

   if [ -f ${BASEN}-${VERSN}.tar.gz ] ; then
      echo already have a tarball for ${BASEN}-${VERSN}.tar.gz
   else
      if [ -d ${BASEN} ] ; then
         /bin/mv ${BASEN} tttt/${BASEN}-${VERSN}
         cd tttt/${BASEN}-${VERSN}
         /bin/mv .git* ..
         cd ..
         tar czf ../${BASEN}-${VERSN}.tar.gz ${BASEN}-${VERSN}
         /bin/mv .git* ${BASEN}-${VERSN}
         /bin/mv ${BASEN}-${VERSN} ../${BASEN}
         cd ..
      fi
   fi
}

mkdir tttt

if [ -d libplot ] ; then
  PLOTVRS=`grep LIB_PLOT_VERSION libplot/include/libplot.h | cut -f2 -d\"`
  do_tarball libplot ${PLOTVRS}
fi

if [ -d libutil ] ; then
  UTILVRS=`grep LIB_UTIL_VERSION libutil/include/libutil.h | cut -f2 -d\"`
  do_tarball libutil ${UTILVRS}
fi

if [ -d libaed-water ] ; then
  AEDVRS=`grep AED_VERSION libaed-water/include/aed.h | cut -f2 -d\"`
  do_tarball libaed-water ${AEDVRS}
fi

if [ -d libaed-benthic ] ; then
  AEDVRS=`grep AED_VERSION libaed-water/include/aed.h | cut -f2 -d\"`
  do_tarball libaed-benthic ${AEDVRS}
fi

if [ -d libaed-demo ] ; then
  AEDVRS=`grep AED_VERSION libaed-water/include/aed.h | cut -f2 -d\"`
  do_tarball libaed-demo ${AEDVRS}
fi

if [ -d libaed-riparian ] ; then
  AEDVRS=`grep AED_PLUS_VERSION libaed-water/include/aed+.h | cut -f2 -d\"`
  do_tarball libaed-riparian ${AEDVRS}
fi

if [ -d libaed-light ] ; then
  AEDVRS=`grep AED_PLUS_VERSION libaed-water/include/aed+.h | cut -f2 -d\"`
  do_tarball libaed-light ${AEDVRS}
fi

if [ -d libaed-dev ] ; then
  AEDVRS=`grep AED_PLUS_VERSION libaed-water/include/aed+.h | cut -f2 -d\"`
  do_tarball libaed-dev ${AEDVRS}
fi

if [ -d libaed-api ] ; then
  AEDVRS=`grep AED_VERSION libaed-water/include/aed.h | cut -f2 -d\"`
  do_tarball libaed-api ${AEDVRS}
fi

if [ -d GLM ] ; then
  GLM_VRS=`grep GLM_VERSION GLM/src/glm.h | cut -f2 -d\"`
  do_tarball GLM ${GLM_VRS}
fi

rmdir tttt

exit 0
