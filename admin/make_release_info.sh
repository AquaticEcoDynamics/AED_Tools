#!/bin/sh

export OUTFILE="ReleaseInfo.txt"
export MAINLIST="GLM libplot libutil libaed-water libaed-benthic libaed-demo libaed-api libaed2"
export PLUSLIST="libaed-riparian libaed-light libaed-dev libaed2-plus"
export GITPATH=".git"

extract_vers () {
# export RPO=`cat .git/config | grep -w url | rev | cut -d'/' -f 1 | rev`
# mingw doesnt have rev, so do it this way.
  export RPO=`cat ${GITPATH}/config | grep -w url | tr '/' '\n' | tail -1`
  # HEAD tells us where the head info is
  WHR=`cat ${GITPATH}/HEAD | cut -f2 -d:`
  # fudge to remove leading/trailing spaces
  WHR=`echo $WHR`
  export VRS=`cat ${GITPATH}/${WHR} | cut -c -7`
  echo "$VRS $RPO"
}

do_list () {
  for src in $* ; do
    if [ -d $src ] ; then
      cd $src
        extract_vers
      cd ..
    fi
  done
}

do_it () {
  echo "This build is produced from the following git points :"
  echo
  extract_vers
  do_list ${MAINLIST}

  # For the PLUS versions :
  echo
  echo "The plus version also has :"
  echo
  do_list ${PLUSLIST}
}

do_it #> ${OUTFILE}

exit 0
