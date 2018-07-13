@echo off
rem We copy the compiled binaries to C:\Bin\ so that the host can access them.
rem If this directory does not exist, we throw an error and quit immediately.
echo %1

if not exist C:\bin (
	echo Error: C:\bin\ not found. You need to mount this directory via docker run -v switch.
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

rem Clone APSIM Model directory.
echo Checking out APSIM.
svn checkout %1 C:\APSIM --depth files
cd APSIM
echo Checking out APSIM\Model\ directory.
svn update --set-depth infinity Model

rem Certain files involved in the build process have been modified to facilitate
rem compilation in docker. These will eventually be merged into the main branch,
rem but until then, we need to copy them manually.
echo Copying modified files.
if exist C:\ModifiedFiles\ (
	echo Copying modified build files
	copy /y C:\ModifiedFiles\Build\* C:\APSIM\Model\Build\
	copy /y C:\ModifiedFiles\Makefile C:\APSIM\Model\Cotton\
)

cd C:\APSIM\Model\Build
call BuildAll

if errorlevel 0 (
	echo Build successful. Copying binaries to output directory.
	copy /y C:\APSIM\Model\*.dll C:\bin\
	copy /y C:\APSIM\Model\*.exe C:\bin\
	copy /y C:\APSIM\Model\*.xml C:\bin\	
)

rem exit %errorlevel%