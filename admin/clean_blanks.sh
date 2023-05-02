#!/bin/sh

ARGS=""
while [ $# -gt 0 ] ; do
  if [ -f $1 ] ; then
     ARGS="$ARGS $1"
  fi
  shift
done

# Strip trailing blanks off source files

CWD=`pwd`
OSTYPE=`uname -s`

AEDDIR="libaed-water libaed-benthic libaed-demo"
AEDPLS="libaed-riparian libaed-light libaed-dev"
FABMDIR=fabm-git
UTILDIR=libutil
PLOTDIR=libplot
GLMDIR=GLM
GLMEGS=GLM_Examples
AEDFV=libaed-fv

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

if [ $ARGS != "" ] ; then
   for i in $ARGS ; do
     strip_file $i
   done
   exit 0
fi

for k in ${GLMDIR} ${UTILDIR} ${PLOTDIR} ${AEDDIR} ${AEDPLS} ${AEDFV} ${AEDEX} ; do
   if [ -d $k ] ; then
      cd $k
      for j in 'f90' 'F90' 'F95' 'c' 'h' 'm' 'sln' 'vfproj' 'vcproj' 'vcxproj' 'icproj' 'vcxproj.filters' 'nml' 'csv' 'sed' 'dat' 'sh' 'csh' 'def' 'plist' ; do
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
     if [ -f $i ] ; then
       strip_file $i
     fi
  done
  cd ..
fi
