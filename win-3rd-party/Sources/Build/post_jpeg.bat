set Configuration=%1%
set Platform=%2%
set DestDir="..\..\%Platform%-%Configuration%"
echo DestDir is %DestDir%
if not EXIST "%DestDir%" ( mkdir %DestDir% )
if not EXIST "%DestDir%\include" ( mkdir %DestDir%\include )

copy ..\jpeg-9c\jpeglib.h %DestDir%\include
copy ..\jpeg-9c\jerror.h %DestDir%\include
copy ..\jpeg-9c\jconfig.h %DestDir%\include
copy ..\jpeg-9c\jmorecfg.h %DestDir%\include
