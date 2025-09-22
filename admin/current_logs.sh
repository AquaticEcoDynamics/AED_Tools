#!/bin/sh

if [ "$1" = '-v' ] ; then
   verbose=1
fi

CWD=`pwd`


get_commit_id () {
  cid=`git log -1 | head -1 | cut -f2 -d\ `
  me=`grep -w url .git/config | head -1 | cut -f3 -d\ `
  stat=`git status -s --untracked-files=no | wc -l`
  echo "$cid from $me with $stat changes"
}

get_commit_id

for src in libplot libutil libaed-api libaed-water libaed-benthic libaed-demo libaed-riparian libaed-light libaed-dev libaed-fv libaed2 libaed2-plus GLM gotm-git ELCOM schism ; do
  if [ -d $src ] ; then
    cd $src
    get_commit_id
    cd $CWD
  fi
done

exit 0
