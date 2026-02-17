#!/bin/sh

#while [ $# -gt 0 ] ; do
#   case $1 in
#    --unpack)
#      export UNPACK=true
#      ;;
#    --ignore-certs)
#      export MINUS_K='-k'
#      ;;
#    *)
#      ;;
#  esac
#  shift
#done
#
#. ./versions.inc

export ZLIB=zlib-${ZLIBV}
export FREETYPE2=freetype-${FREETYPE2V}
export JPEG=jpegsrc.v${JPEGV}
export LIBPNG=libpng-${LIBPNGV}
export LIBGD=lib${GD}

if [ ! -f ${ZLIB}.tar.gz ] ; then
   echo fetching ${ZLIB}.tar.gz
   curl ${MINUS_K} http://www.zlib.net/${ZLIB}.tar.gz -o ${ZLIB}.tar.gz
   if [ $? != 0 ] ; then
      echo failed to fetch ${ZLIB}.tar.gz
   elif [ "$UNPACK" = "true" ] ; then
      tar -xzf ${ZLIB}.tar.gz
   fi
fi

if [ ! -f ${FREETYPE2}.tar.gz ] ; then
   echo fetching ${FREETYPE2}.tar.gz
   curl ${MINUS_K} -L https://download.savannah.gnu.org/releases/freetype/${FREETYPE2}.tar.gz -o ${FREETYPE2}.tar.gz
   if [ $? != 0 ] ; then
      curl  ${MINUS_K} -L https://ixpeering.dl.sourceforge.net/project/freetype/freetype2/${FREETYPE2V}/${FREETYPE2}.tar.xz -o ${FREETYPE2}.tar.xz
      if [ $? != 0 ] ; then
        echo failed to fetch ${FREETYPE2}.tar.gz
      else
        tar -xJf ${FREETYPE2}.tar.xz
        tar -czf ${FREETYPE2}.tar.gz ${FREETYPE2}
	/bin/rm ${FREETYPE2}.tar.xz
	if [ "$UNPACK" != "true" ] ; then
          /bin/rm -rf ${FREETYPE2}
	fi
      fi
   elif [ "$UNPACK" = "true" ] ; then
      tar -xzf ${FREETYPE2}.tar.gz
   fi
fi

if [ ! -f ${JPEG}.tar.gz ] ; then
   echo fetching ${JPEG}.tar.gz
   curl ${MINUS_K} http://www.ijg.org/files/${JPEG}.tar.gz -o ${JPEG}.tar.gz
   if [ $? != 0 ] ; then
      echo failed to fetch ${JPEG}.tar.gz
   elif [ "$UNPACK" = "true" ] ; then
      tar -xzf ${JPEG}.tar.gz
   fi
fi

if [ ! -f ${LIBPNG}.tar.gz ] ; then
   echo fetching ${LIBPNG}.tar.gz
   curl ${MINUS_K} -L http://prdownloads.sourceforge.net/libpng/${LIBPNG}.tar.gz -o ${LIBPNG}.tar.gz
   if [ $? != 0 ] ; then
      echo failed to fetch ${LIBPNG}.tar.gz
   elif [ "$UNPACK" = "true" ] ; then
      tar xzf ${LIBPNG}.tar.gz
   fi
fi

if [ ! -f ${LIBGD}.tar.gz ] ; then
   echo fetching ${LIBGD}.tar.gz
   curl ${MINUS_K} -L https://github.com/libgd/libgd/releases/download/${GD}/${LIBGD}.tar.gz -o ${LIBGD}.tar.gz
   if [ $? != 0 ] ; then
      echo failed to fetch ${LIBGD}.tar.gz
   elif [ "$UNPACK" = "true" ] ; then
      tar xzf ${LIBGD}.tar.gz
   fi
fi

exit 0
