WinGit
======

Build dependencies
------------------

 * [MSVC Express 2013](http://www.microsoft.com/en-us/download/details.aspx?id=40787)
 * [Cygwin](http://cygwin.com/install.html)
  * make
  * perl
  * gettext-devel
  * git

Building
--------
 * Enter Cygwin
 * `git clone --recurse git@github.com:slonopotamus/wingit.git`
 * `cd wingit`
 * `./build.bat [x86|x86_amd64]`
 * Results go to `stage-[x86|x86_amd64]`
