WinGit
======

Build dependencies
------------------

 * [MSVC Express 2013](http://www.microsoft.com/en-us/download/details.aspx?id=40787)
 * [MinGW](http://sourceforge.net/projects/mingw/files/Installer/mingw-get-setup.exe/download)
  * mingw-developer-toolkit

Building
--------
 * Enter MinGW: `C:\MinGW\msys\1.0\msys.bat`
 * `cd` to wingit directory
 * `./build.sh [x86|x86_amd64]`
 * Results go to `stage-[x86|amd64]`
