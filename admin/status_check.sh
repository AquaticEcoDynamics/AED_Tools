#!/bin/sh

if [ "$1" = '-v' ] ; then
   verbose=1
fi

CWD=`pwd`

check_remote () {
  BRANCH=`git branch | cut -f2 -d\ `
# echo "on branch $BRANCH at repo $REPO"
  LOCAL=`git show-ref -s refs/remotes/origin/$BRANCH`
  REMOTE=`git ls-remote --heads $REPO 2> /dev/null | grep $BRANCH | cut -f1`
# echo local SHA1 is $LOCAL remote SHA1 is $REMOTE
  if [ "$LOCAL" != "$REMOTE" ] ; then
    echo "an update is available"
  else
    echo "your branch is up to date with remote"
  fi
}


echo '*** checking status for . from' `cat .git/config | grep -w url`
git status
REPO=`cat .git/config | grep -w url | head -n 1 | cut -f2 -d=`
if [ $verbose ] ; then check_remote $REPO; fi

for src in libplot libutil libaed-water libaed-benthic libaed-demo libaed-riparian libaed-light libaed-dev libaed-fv libaed2 libaed2-plus GLM ; do
  if [ -d $src ] ; then
#   if [ "$src" = "tuflowfv-svn" ] ; then
#     echo "===================================================="
#     svn --version > /dev/null 2>&1
#     if [ $? = 0 ] ; then
#       echo "*** checking status for [$src]"
#       cd $src
#       svn status | grep '^M'
#     else
#       echo "*** cannot check status for [$src]"
#     fi
#   else
      REPO=`cat $src/.git/config | grep -w url | head -n 1 | cut -f2 -d=`
      echo "===================================================="
      echo "*** checking status for [$src] from $REPO"
      cd $src
      git status
#   fi
    if [ $verbose ] ; then check_remote $REPO; fi
    cd $CWD
  else
    echo "no directory for $src"
  fi
done

exit 0
