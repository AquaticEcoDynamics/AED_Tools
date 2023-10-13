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
wget https://raw.githubusercontent.com/flang-compiler/flang/master/runtime/flang/ieee_arithmetic.F95
wget https://raw.githubusercontent.com/flang-compiler/flang/master/runtime/flang/ieee_exceptions.F95
wget https://raw.githubusercontent.com/flang-compiler/flang/master/runtime/flang/ieee_features.F95
wget https://raw.githubusercontent.com/flang-compiler/flang/master/runtime/flang/iso_c_bind.F95
wget https://raw.githubusercontent.com/flang-compiler/flang/master/runtime/flang/iso_fortran_env.f90

exit 0
