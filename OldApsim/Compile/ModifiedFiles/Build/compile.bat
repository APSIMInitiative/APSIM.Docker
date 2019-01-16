@echo off
rem We copy the compiled binaries to C:\Bin\ so that the outside world can accessed them.
rem If this directory does not exist, we throw an error and quit immediately.
if not exist C:\bin (
	echo C:\bin\ not found. You need to mount this directory via docker run -v switch.
	exit 1
)

rem Clone APSIM Model directory.
svn checkout http://apsrunet.apsim.info/svn/apsim/trunk C:\APSIM --depth files
cd APSIM
svn update --set-depth infinity Model

if exist C:\ModifiedFiles\ (
	copy /y C:\ModifiedFiles\BuildAll.bat C:\APSIM\Model\Build\
	copy /y C:\ModifiedFiles\BuildAll.xml C:\APSIM\Model\Build\
	copy /y C:\ModifiedFiles\Win32VSCPP.make C:\APSIM\Model\Build\
	copy /y C:\ModifiedFiles\Win32VSDOTNET.make C:\APSIM\Model\Build\
	copy /y C:\ModifiedFiles\Win32VSFOR.make C:\APSIM\Model\Build\
	copy /y C:\ModifiedFiles\Makefile C:\APSIM\Model\Cotton\
)

cd C:\APSIM\Model\Build
call BuildAll

copy /y C:\APSIM\Model\*.dll C:\bin\
copy /y C:\APSIM\Model\*.exe C:\bin\

exit