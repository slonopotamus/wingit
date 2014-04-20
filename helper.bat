@echo off

if "%VS120COMNTOOLS%" == "" (
	echo VS120COMNTOOLS environment variable is not set
	echo This most likely means that MSVC is not installed
	echo Also, restart of msys or even logout/login cycle
	echo may be required after installing MSVC
	exit 1
)

call "%VS120COMNTOOLS%\..\..\VC\vcvarsall.bat" %VC_ARCH%
if %errorlevel% neq 0 exit %errorlevel%

%*
exit %errorlevel%
