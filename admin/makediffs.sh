#!/bin/sh
#
# This script attempts to produce a diff file for each of the git repositories 
# of changes since the last pull
#

if [ "$1" = '-m' ] ; then
   master=1
fi

CWD=`pwd`

do_diffs_here () {
  diff_f=$1

  if [ -d .git ] ; then
    REPO=`cat .git/config | grep -w url | head -n 1 | cut -f2 -d=`
    echo "*** creating diffs for [$diff_f] from $REPO"

    # empty any existing file
    /bin/echo -n > $CWD/$diff_f.diff

    # use "git add -N ." to allow for new files
    git add -N .
    BRANCH=`git branch -q | grep '*' | cut -f2 -d\ `
    if [ $master ] ; then
      # If we are not currently in the master, get the diffs against master
      if [ "$BRANCH" != "master" ] ; then
        git diff origin/master origin/$BRANCH > $CWD/$diff_f.diff
      fi
    fi

    # now get the diffs from the branch to the last commit
    git diff origin/$BRANCH HEAD >> $CWD/$diff_f.diff

    # and now the diffs since the last commit
    git diff >> $CWD/$diff_f.diff

    # If the diff file is empty, delete it
    SIZE=`wc -l $CWD/$diff_f.diff`
    SIZE=`echo $SIZE | cut -f1 -d\ `
    #echo "SIZE of $CWD/$diff_f.diff is $SIZE"
    if [ "$SIZE" = "0" ] ; then /bin/rm $CWD/$diff_f.diff ; fi
  else
    echo "*** Not a git repository (.git not found) in $diff_f"
  fi
}

# This should be the AED_Tools directory
do_diffs_here tools

for src in libplot libutil libaed2 libaed2-plus GLM libfvaed2 TUFLOWFV ; do
  echo "===================================================="
  if [ -d $src ] ; then
    cd $src
    do_diffs_here $src
    cd $CWD
  else
    echo "no directory for $src"
  fi
done

exit 0
