#!/bin/sh

for dir in libaed-* ; do
   for i in `find ${dir}/. -name \*.F90` ; do
      grep 'NAMELIST /' $i >& /dev/null
      if [ "$?" != "0" ] ; then
         echo '! ***' $i nas no namelist
      else
         echo '!------------------------------------------------------------------'
         echo '! ***' $i
         echo '!------------------------------------------------------------------'
         sed -n '/%% NAMELIST/,/%% END NAMELIST/p' $i
# to strip the %% NAMELIST , %% END NAMELIST use :
#        sed -n '/%% NAMELIST/,/%% END NAMELIST/p' $i | sed '1d;$d'
         echo '!------------------------------------------------------------------'
      fi
      echo
   done
done
