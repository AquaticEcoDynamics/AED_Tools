#!/bin/sh

if [ "$1" = '-v' ] ; then
   verbose=1
fi

CWD=`pwd`

check_remote () {
  BRANCH=`git branch | cut -f2 -d\ `
# echo "on branch $BRANCH"
  LOCAL=`git show-ref -s refs/remotes/origin/$BRANCH`
  REMOTE=`git ls-remote --heads 2> /dev/null | grep $BRANCH | cut -f1`
# echo local SHA1 is $LOCAL remote SHA1 is $REMOTE
  if [ "$LOCAL" != "$REMOTE" ] ; then
    echo "an update is available"
  else
    echo "your branch is up to date with remote"
  fi
}


echo '*** checking status for . from' `cat .git/config | grep -w url`
git status
if [ $verbose ] ; then check_remote ; fi

for src in libplot libutil libaed2 GLM libfvaed2 ; do
  if [ -d $src ] ; then
    echo "===================================================="
    echo '*** checking status for ['$src'] from ' `cat $src/.git/config | grep -w url`
    cd $src
    git status
    if [ $verbose ] ; then check_remote ; fi
    cd $CWD
  fi
done

exit 0
