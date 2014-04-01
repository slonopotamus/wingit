WinGit
======

WinGit is an effort to provide native x86 and x64 builds of [Git](http://git-scm.com) for Windows.

[**DOWNLOAD**](https://github.com/slonopotamus/wingit/releases)

Build dependencies
------------------

 * [MSVC Express 2013](http://www.microsoft.com/en-us/download/details.aspx?id=40787)
 * [MinGW](http://sourceforge.net/projects/mingw/files/Installer/mingw-get-setup.exe/download)
  * mingw-developer-toolkit
  * msys-libtool
  * msys-unzip
  * msys-wget
 * [WiX Toolset](http://wixtoolset.org)

Building
--------
 * Enter MinGW: `C:\MinGW\msys\1.0\msys.bat`
 * `cd` to wingit directory
 * `./build.sh [x86|x86_amd64]`
