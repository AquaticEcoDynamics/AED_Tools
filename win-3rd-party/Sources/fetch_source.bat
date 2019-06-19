@REM The directory Build has project files to build the libraries using
@REM VisualStudio 2015/2017 ; use all_libs.sln. They are set up to access source 
@REM files from directories in this directory called :
@REM 
@REM zlib-1.2.11
@REM freetype-2.9.1
@REM jpeg-9c
@REM libpng-1.6.35
@REM libgd-2.2.5
@REM curl-7.61.1
@REM szip-2.1.1
@REM hdf5-1.10.3
@REM netcdf-4.6.1
@REM netcdf-fortran-4.4.4
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

curl  http://www.zlib.net/zlib-1.2.11.tar.gz -o zlib-1.2.11.tar.gz
tar -xzf zlib-1.2.11.tar.gz

curl  -L https://download.savannah.gnu.org/releases/freetype/freetype-2.9.1.tar.gz -o freetype-2.9.1.tar.gz
tar -xzf freetype-2.9.1.tar.gz

curl  http://www.ijg.org/files/jpegsrc.v9c.tar.gz -o jpegsrc.v9c.tar.gz
tar -xzf jpegsrc.v9c.tar.gz

curl  -L http://prdownloads.sourceforge.net/libpng/libpng-1.6.35.tar.gz -o libpng-1.6.35.tar.gz
tar -xzf libpng-1.6.35.tar.gz

curl  -L https://github.com/libgd/libgd/releases/download/gd-2.2.5/libgd-2.2.5.tar.gz -o libgd-2.2.5.tar.gz
tar -xzf libgd-2.2.5.tar.gz

curl  -L https://curl.haxx.se/download/curl-7.61.1.tar.gz -o curl-7.61.1.tar.gz
tar -xzf curl-7.61.1.tar.gz

curl  https://support.hdfgroup.org/ftp/lib-external/szip/2.1.1/src/szip-2.1.1.tar.gz -o szip-2.1.1.tar.gz
tar -xzf szip-2.1.1.tar.gz

curl  -L "https://www.hdfgroup.org/package/source-gzip-3/?wpdmdl=12596&refresh=5ba98754866d31537836884" -o hdf5-1.10.3.tar.gz
tar -xzf hdf5-1.10.3.tar.gz

curl  https://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-4.6.1.tar.gz -o netcdf-4.6.1.tar.gz
tar -xzf netcdf-4.6.1.tar.gz

curl  https://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-fortran-4.4.4.tar.gz -o netcdf-fortran-4.4.4.tar.gz
tar -xzf netcdf-fortran-4.4.4.tar.gz
