#!/bin/bash

# Strip trailing blanks off source files

CWD=`pwd`
OSTYPE=`uname -s`

AED2DIR=libaed2
AED2PLS=libaed2-plus
FABMDIR=fabm-git
UTILDIR=libutil
PLOTDIR=libplot
GLMDIR=GLM
FVAED2D=libfvaed2

strip_file () {
    FILE=$1
    if [ "$OSTYPE" != "Darwin" ] ; then
       # The awk adds a trailing newline if there isn't one, macos sed does that anyway
       awk 1 $FILE | sed 's/[ \t\r]*$//' > tmpx
    else
       #  the above works for gnu-sed, but we need to replace \t with
       #  a tab character for Mac
       sed 's/[ 	]*$//' $FILE > tmpx
    fi
    \diff $FILE tmpx > /dev/null 2>&1
    if [ $? != 0 ] ; then
       echo changed $FILE
       /bin/rm $FILE
       /bin/mv tmpx $FILE
    else
       /bin/rm tmpx
    fi
}

for k in ${FABMDIR}/src/models/aed ${FABMDIR}/src/drivers/glm ${GLMDIR}/src ${GLMDIR}/Examples ${UTILDIR} ${PLOTDIR} ${AED2DIR} ${AED2PLS} ${FVAED2D} ; do
   if [ -d $k ] ; then
      cd $k
      for j in 'F90' 'c' 'h' 'm' 'sln' 'vfproj' 'vcproj' 'vcxproj' 'icproj' 'vcxproj.filters' 'nml' 'csv' 'sed' 'dat' 'sh' 'csh' 'def' 'plist' ; do
         echo "cleaning trailing spaces in $k/\*.$j"
         for i in `find . -name \*.$j` ;  do
            strip_file $i
         done
      done
      for j in .gitignore README COPYING KNOWN_ISSUES Changes Makefile changelog compat control rules;  do
         for i in `find . -name $j` ;  do
            strip_file $i
         done
      done
      cd $CWD
   else
      echo "No directory called" $k
   fi
done

if [ -d ${GLMDIR} ] ; then
  cd ${GLMDIR}
  for i in *.sh .gitignore README* GLM_CONFIG RELEASE-NOTES ; do
     strip_file $i
  done
  cd ..
fi
