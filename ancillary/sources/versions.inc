
# https://www.unidata.ucar.edu/software/netcdf

# this for building older tuflow
#export NETCDFFV=4.4.5

# These if we need both
#export NETCDFV=4.9.3
export NETCDFV=4.9.2
#export NETCDFFV=4.6.2
export NETCDFFV=4.6.1

#-----------------------------------------------------------

export NETCDF=netcdf-c-${NETCDFV}
export NETCDFF=netcdf-fortran-${NETCDFFV}

#-----------------------------------------------------------

# http://www.zlib.net
export ZLIBV=1.3.2

#-----------------------------------------------------------

# https://curl.haxx.se/download/
#export CURLV=8.18.0
export CURLV=8.5.0

# The link is provided for historical reasons - szip seems to be included in the aed package
# https://support.hdfgroup.org/ftp/lib-external/szip/2.1.1/src/szip-2.1.1.tar.gz
export SZIPV=2.1.1

# https://gitlab.dkrz.de/k202009/libaec/
export LIBAECV=v1.1.4

# https://support.hdfgroup.org/downloads/index.html
#export HDF5V=2.0.0
export HDF5V=1.14.6

#-----------------------------------------------------------

export CURL=curl-${CURLV}
export LIBAEC=libaec-${LIBAECV}
export HDF5=hdf5-${HDF5V}

#-----------------------------------------------------------
#-----------------------------------------------------------

# https://download.savannah.gnu.org/releases/freetype
export FREETYPE2V=2.14.1

# http://www.ijg.org/files
export JPEGV=10

# http://prdownloads.sourceforge.net/libpng
export LIBPNGV=1.6.55

# https://github.com/libgd / https://github.com/libgd/libgd/releases
export GD=gd-2.3.3

#-----------------------------------------------------------

export ZLIB=zlib-${ZLIBV}
export FREETYPE2=freetype-${FREETYPE2V}
export JPEG=jpegsrc.v${JPEGV}
export LIBPNG=libpng-${LIBPNGV}
export LIBGD=lib${GD}

#-----------------------------------------------------------

# https://www.mpich.org/static/downloads/
export MPICHV=5.0.0

# https://www.open-mpi.org/
export OMPIMAJ=5.0
export OMPIV=5.0.9
#export OMPIV=5.0.6

#-----------------------------------------------------------

export MPICH=mpich-${MPICHV}
export OMPI=openmpi-${OMPIV}

#-----------------------------------------------------------

# https://sqlite.org/download.html

export SQLTV=3510200
export SQLITE=sqlite-src-${SQLTV}

#-----------------------------------------------------------
