set Configuration=%1%
set Platform=%2%
set DestDir="..\..\%Platform%-%Configuration%"
echo DestDir is %DestDir%
if not EXIST "%DestDir%" ( mkdir %DestDir% )
if not EXIST "%DestDir%\include" ( mkdir %DestDir%\include )

echo #ifndef BGDWIN32 > %DestDir%\include\gd.h
echo #define BGDWIN32 >> %DestDir%\include\gd.h
echo #endif >> %DestDir%\include\gd.h
echo #ifndef NONDLL >> %DestDir%\include\gd.h
echo #define NONDLL >> %DestDir%\include\gd.h
echo #endif >> %DestDir%\include\gd.h
type ..\libgd-2.3.3\src\gd.h >> %DestDir%\include\gd.h
@rem copy ..\libgd-2.3.3\src\gd.h %DestDir%\include
copy ..\libgd-2.3.3\src\gd_io.h %DestDir%\include
copy ..\libgd-2.3.3\src\gdfonts.h %DestDir%\include
copy ..\libgd-2.3.3\src\gdfontmb.h %DestDir%\include
copy ..\libgd-2.3.3\src\gdfontl.h %DestDir%\include
copy ..\libgd-2.3.3\src\gdfx.h %DestDir%\include
