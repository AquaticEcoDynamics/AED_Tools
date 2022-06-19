set Configuration=%1%
set Platform=%2%
set DestDir="..\..\%Platform%-%Configuration%"
echo DestDir is %DestDir%
if not EXIST "%DestDir%" ( mkdir %DestDir% )
if not EXIST "%DestDir%\include" ( mkdir %DestDir%\include )

copy ..\jpeg-9e\jpeglib.h %DestDir%\include
copy ..\jpeg-9e\jerror.h %DestDir%\include
copy ..\jpeg-9e\jconfig.h %DestDir%\include
copy ..\jpeg-9e\jmorecfg.h %DestDir%\include
