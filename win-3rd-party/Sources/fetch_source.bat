@REM The directory Build has project files to build the libraries using
@REM VisualStudio 2015/2017/2019 ; use all_libs.sln. They are set up to
@REM access source files from directories in this directory called :
@REM 
@REM zlib-1.2.12
@REM freetype-2.12.1
@REM jpeg-9d
@REM libpng-1.6.37
@REM libgd-2.3.3
@REM curl-7.68.0
@REM szip-2.1.1
@REM hdf5-1.10.6
@REM netcdf-c-4.8.1
@REM netcdf-fortran-4.5.2
@REM 
@REM This is obviously the versions of the source files used.
@REM 
@REM They are available from :
@REM 
@REM zlib           : http://www.zlib.net/
@REM freetype       : http://www.freetype.org/download.html
@REM jpeg           : http://www.ijg.org/
@REM libpng         : http://www.libpng.org/pub/png/libpng.html
@REM libgd          : http://libgd.github.io/
@REM curl           : https://curl.haxx.se/download.html
@REM szip           : https://support.hdfgroup.org/doc_resource/SZIP/
@REM hdf5           : https://www.hdfgroup.org/downloads/hdf5/source-code/
@REM netcdf &
@REM netcdf-fortran : https://www.unidata.ucar.edu/downloads/netcdf/index.jsp
@REM 

curl  http://www.zlib.net/zlib-1.2.12.tar.gz -o zlib-1.2.12.tar.gz
tar -xzf zlib-1.2.12.tar.gz

curl  -L https://download.savannah.gnu.org/releases/freetype/freetype-2.10.1.tar.gz -o freetype-2.10.1.tar.gz
tar -xzf freetype-2.12.1.tar.gz

curl  http://www.ijg.org/files/jpegsrc.v9e.tar.gz -o jpegsrc.v9e.tar.gz
tar -xzf jpegsrc.v9e.tar.gz

curl  -L http://prdownloads.sourceforge.net/libpng/libpng-1.6.37.tar.gz -o libpng-1.6.37.tar.gz
tar -xzf libpng-1.6.37.tar.gz

curl  -L https://github.com/libgd/libgd/releases/download/gd-2.3.3/libgd-2.3.3.tar.gz -o libgd-2.3.3.tar.gz
tar -xzf libgd-2.3.3.tar.gz

curl  -L https://curl.haxx.se/download/curl-7.83.1.tar.gz -o curl-7.83.1.tar.gz
tar -xzf curl-7.83.1.tar.gz

curl  https://support.hdfgroup.org/ftp/lib-external/szip/2.1.1/src/szip-2.1.1.tar.gz -o szip-2.1.1.tar.gz
tar -xzf szip-2.1.1.tar.gz

curl  -L "https://www.hdfgroup.org/package/hdf5-1-12-0-tar-gz/?wpdmdl=14135&refresh=5e5f47f69f23f1583302646" -o hdf5-1.12.0.tar.gz
tar -xzf hdf5-1.12.0.tar.gz

curl  https://downloads.unidata.ucar.edu/netcdf-c/4.8.1/netcdf-c-4.8.1.tar.gz -o netcdf-c-4.8.1.tar.gz
tar -xzf netcdf-c-4.8.1.tar.gz

curl  https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v4.5.4.tar.gz -o netcdf-fortran-4.5.4.tar.gz
tar -xzf netcdf-fortran-4.5.4.tar.gz

