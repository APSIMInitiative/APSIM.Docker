@echo off
rem Make sure C:\bin\ exists
if not exist C:\bin (
	echo C:\bin\ not found. You need to mount this directory via docker run -v switch.
	exit 1
)

rem Check if an argument has been passed in.
if "%1"=="" (
	echo Error: No SVN URL given.
	exit 1
)

rem Check if given svn repo exists.
svn ls %1 > nul 2>&1
if errorlevel 1 (
	echo Error: Invalid SVN URL: %1.
	exit 1
)

rem Clone APSIM Tests directory.
svn checkout http://apsrunet.apsim.info/svn/apsim/trunk C:\APSIM --depth files
cd APSIM
svn update --set-depth infinity Tests
rem No idea why UserInterface directory is needed to run from the command line....
svn update --set-depth files UserInterface
rem We also need the met files under Examples\
svn update --set-depth infinity Examples

rem Delete .sum files. Ideally we wouldn't check these files out in the first place.
rem del /s *.sum

rem Copy in binaries
mkdir C:\APSIM\Model
copy /y C:\bin\* C:\APSIM\Model\

rem Store list of .apsim files in C:\apsimfiles.txt
for /r C:\APSIM\Tests\ %%i in (*.apsim) do echo "%%i" >> C:\APSIM\Model\apsimfiles.txt

rem Run the tests
cd C:\APSIM\Model\
apsim.exe @apsimfiles.txt
exit %errorlevel%