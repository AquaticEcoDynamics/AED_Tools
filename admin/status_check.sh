#!/bin/sh

echo '*** checking status for . from' `cat .git/config | grep -w url`
git status

CWD=`pwd`
for src in libplot libutil libaed2 GLM ; do
   echo '*** checking status for' $src ' from ' `cat $src/.git/config | grep -w url`
   if [ -d $src ] ; then
     cd $src
     git status
     cd $CWD
  fi
done

exit 0
