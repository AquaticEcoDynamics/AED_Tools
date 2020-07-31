#!/bin/bash

# Replace tabs with spaces (set at 4 space stops)

CWD=`pwd`
OSTYPE=`uname -s`

AEDDIR="libaed-water libaed-benthic libaed-demo"
AEDPLS="libaed-riparian libaed-dev"
FABMDIR=fabm-git
UTILDIR=libutil
PLOTDIR=libplot
GLMDIR=GLM
AEDFV=libaed-fv

detab_file () {
    FILE=$1
    expand -t 4 $FILE > tmpx
#   if [ "$OSTYPE" != "Darwin" ] ; then
#      # The awk adds a trailing newline if there isn't one, macos sed does that anyway
#      awk 1 $FILE | sed 's/[ \t\r]*$//' > tmpx
#   else
#      #  the above works for gnu-sed, but we need to replace \t with
#      #  a tab character for Mac
#      sed 's/[ 	]*$//' $FILE > tmpx
#   fi
    \diff $FILE tmpx > /dev/null 2>&1
    if [ $? != 0 ] ; then
       echo changed $FILE
       /bin/rm $FILE
       /bin/mv tmpx $FILE
    else
       /bin/rm tmpx
    fi
}

for k in ${FABMDIR}/src/models/aed ${FABMDIR}/src/drivers/glm ${GLMDIR}/src ${UTILDIR} ${PLOTDIR} ${AEDDIR} ${AEDPLS} ${AEDFV} ; do
   if [ -d $k ] ; then
      cd $k
      for j in 'F90' 'c' 'h' ; do
         echo "detabbing in $k/\*.$j"
         for i in `find . -name \*.$j` ;  do
            detab_file $i
         done
      done
      cd $CWD
   else
      echo "No directory called" $k
   fi
done
