#!/bin/bash

if [ -d GLM ] ; then
  echo cleaning GLM
  cd GLM
  ./clean_glm.sh
  cd ..
fi
if [ -d fabm-git ] ; then
  echo cleaning fabm-git
  cd fabm-git
  /bin/rm -rf build
  cd ..
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

exit 0
