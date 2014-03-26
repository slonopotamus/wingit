@echo off

set VC_ARCH=x86
if not "%1" == "" set VC_ARCH=%1

set ARCH=%VC_ARCH%
if "%ARCH%" == "x86_amd64" set %ARCH=amd64

set DIR=%~dp0
set DIR=%dir:\=/%

set LIBS=%DIR%lib/
set ZLIB_PATH=%LIBS%zlib-1.2.8.1/%ARCH%
set OPENSSLDIR=%LIBS%openssl-1.0.1.24/%ARCH%
set CURLDIR=%LIBS%curl-7.30.0.2/%ARCH%

set DESTDIR=%DIR%stage-%ARCH%

call "%VS120COMNTOOLS%\..\..\VC\vcvarsall.bat" %VC_ARCH%
make -C %DIR%/git MSVC=1 INLINE=__inline prefix=/ NO_TCLTK=1 NO_PERL=1 install -j8
cp %OPENSSLDIR%/*.dll %ZLIB_PATH%/*.dll %CURLDIR%/*.dll %DESTDIR%/bin
