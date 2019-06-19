#!/bin/bash

if [ -d GLM ] ; then
  echo cleaning GLM
  cd GLM
  ./clean_glm.sh
  cd ..
fi
if [ -d GLM_Examples ] ; then
  echo cleaning GLM_Examples
  cd GLM_Examples
  DBGS=`find . -name glm_lake_dbg.csv`
  if [ "$DBGS" != "" ] ; then
    /bin/rm $DBGS
  fi
  DIRS=`find . -name output`
  if [ "$DIRS" != "" ] ; then
    /bin/rm -rf $DIRS
  fi
  cd ..
fi
if [ -d fabm-git ] ; then
  echo cleaning fabm-git
  /bin/rm -rf fabm-git/build
fi
if [ -d libutil ] ; then
  echo cleaning libutil
  cd libutil
  make distclean
  cd ..
fi
if [ -d libplot ] ; then
  echo cleaning libplot
  cd libplot
  make distclean
  cd ..
fi
if [ -d libaed2 ] ; then
  echo cleaning libaed2
  cd libaed2
  make distclean
  cd ..
fi
if [ -d libaed2-plus ] ; then
  echo cleaning libaed2-plus
  cd libaed2-plus
  make distclean
  cd ..
fi
if [ -d libfvaed2 ] ; then
  echo cleaning libfvaed2
  cd libfvaed2
  make distclean
  cd ..
fi
if [ -d gotm-git ] ; then
  echo cleaning gotm-git
  if [ -d ${GOTMDIR}/compilers ] ; then
    export FORTRAN_COMPILER=IFORT
    export GOTMDIR=`pwd`/gotm-git
    cd gotm-git
    make distclean
    cd ..
  else
    /bin/rm -rf gotm-git/build
  fi
fi
if [ -d TUFLOWFV ] ; then
  echo cleaning TUFLOWFV
  if [ "$FC" = "pgfortran" ] ; then
     FCD="pgi"
  elif [ "$FC" = "gfortran" ] ; then
     FCD="gfortran"
  elif [ "$FC" = "gfortran-8" ] ; then
     FCD="gfortran"
  else
     FCD="ifort"
  fi
  if [ `uname -s` = Darwin ] ; then
    cd TUFLOWFV/platform/macos_${FCD}/
  else
    cd TUFLOWFV/platform/linux_${FCD}/
  fi
  make clean
  cd ../../..
fi
if [ -d GLM_Examples ] ; then
   cd GLM_Examples
   LIST1=`find . -name WQ\*.csv`
   LIST2=`find . -name output.nc`
   LIST3=`find . -name lake.csv`
   LIST4=`find . -name outlet_\?\?.csv`
   LIST5=`find . -name overflow.csv`
   LIST6=`find . -name stress_dbg.csv`
   LIST=`echo $LIST1 $LIST2 $LIST3 $LIST4 $LIST5 $LIST6`
   #echo $LIST1
   #echo $LIST2
   #echo $LIST3
   #echo $LIST
   if [ "$LIST" != "" ] ; then
     /bin/rm $LIST
   fi
   cd ..
fi

exit 0
