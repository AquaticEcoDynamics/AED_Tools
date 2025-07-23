#!/bin/sh

# Get some missing stuff from :
# 
# https://github.com/flang-compiler/flang/tree/master/runtime/flang
# 
# 
# IE :
# 
if [ ! -d src ] ; then
   mkdir src
fi
cd src
if [ ! -f ieee_arithmetic.F95 ] ; then
  wget https://raw.githubusercontent.com/flang-compiler/flang/master/runtime/flang/ieee_arithmetic.F95
fi
if [ ! -f ieee_exceptions.F95 ] ; then
  wget https://raw.githubusercontent.com/flang-compiler/flang/master/runtime/flang/ieee_exceptions.F95
fi
if [ ! -f ieee_features.F95 ] ; then
  wget https://raw.githubusercontent.com/flang-compiler/flang/master/runtime/flang/ieee_features.F95
fi
if [ ! -f iso_c_bind.F95 ] ; then
  wget https://raw.githubusercontent.com/flang-compiler/flang/master/runtime/flang/iso_c_bind.F95
fi
if [ ! -f iso_fortran_env.F90 ] ; then
  wget https://raw.githubusercontent.com/flang-compiler/flang/master/runtime/flang/iso_fortran_env.F90
fi
if [ ! -f omp_lib.F95 ] ; then
  wget https://raw.githubusercontent.com/flang-compiler/flang/master/runtime/flang/omp_lib.F95
fi

exit 0
