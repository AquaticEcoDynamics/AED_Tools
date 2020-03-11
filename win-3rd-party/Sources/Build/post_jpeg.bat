set Configuration=%1%
set Platform=%2%
set DestDir="..\..\%Platform%-%Configuration%"
echo DestDir is %DestDir%
if not EXIST "%DestDir%" ( mkdir %DestDir% )
if not EXIST "%DestDir%\include" ( mkdir %DestDir%\include )

copy ..\jpeg-9d\jpeglib.h %DestDir%\include
copy ..\jpeg-9d\jerror.h %DestDir%\include
copy ..\jpeg-9d\jconfig.h %DestDir%\include
copy ..\jpeg-9d\jmorecfg.h %DestDir%\include
