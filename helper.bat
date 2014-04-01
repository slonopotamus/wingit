@echo off

call "%VS120COMNTOOLS%\..\..\VC\vcvarsall.bat" %VC_ARCH%
if %errorlevel% neq 0 exit %errorlevel% exit %errorlevel%

%*
exit %errorlevel%
