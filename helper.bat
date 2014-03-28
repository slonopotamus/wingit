@echo off

if not "%VS120COMNTOOLS%" == "" (
	call "%VS120COMNTOOLS%\..\..\VC\vcvarsall.bat" %VC_ARCH%
	if %errorlevel% neq 0 exit %errorlevel%
	goto run
)

if not "%VS110COMNTOOLS%" == "" (
	call "%VS110COMNTOOLS%\..\..\VC\vcvarsall.bat" %VC_ARCH%
	if %errorlevel% neq 0 exit %errorlevel%
	goto :run
)

if not "%VS100COMNTOOLS%" == "" (
	call "%VS100COMNTOOLS%\..\..\VC\vcvarsall.bat" %VC_ARCH%
	if %errorlevel% neq 0 exit %errorlevel%
	goto :run
)

echo ERROR: No Visual Studio found
exit 1

:run
%*
exit %errorlevel%
