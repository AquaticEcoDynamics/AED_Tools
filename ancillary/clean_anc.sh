#!/bin/bash

SQUEEKY=false

while [ $# -gt 0 ] ; do
  case $1 in
    --debug)
      export DEBUG=true
      ;;
    --squeeky)
      export SQUEEKY=true
      ;;
    *)
      echo "unknown option \"$1\""
      ;;
  esac
  shift
done

if [ "$SQUEEKY" = "true" ] ; then
  for dir in gfortran ifort ifx windows ; do
    cd $dir
    /bin/rm -rf include bin lib share etc cmake*
    cd ..
  done

  cd sources
  ./clean_all.sh --squeeky
else
  cd sources
  ./clean_all.sh
fi

exit 0
