#!/bin/sh

echo '*** checking status for .'
git status

CWD=`pwd`
for src in libplot libutil libaed2 GLM ; do
   echo '*** checking status for' $src
   if [ -d $src ] ; then
     cd $src
     git status
     cd $CWD
  fi
done

exit 0
