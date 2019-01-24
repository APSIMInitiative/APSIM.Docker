@echo off

rem Certain files involved in the build process have been modified to facilitate
rem compilation in docker. These will eventually be merged into the main branch,
rem but until then, we need to copy them manually.
echo Copying modified files.
if exist C:\ModifiedFiles\ (
	echo Copying modified build files
	copy /y C:\ModifiedFiles\Build\* C:\APSIM\Model\Build\
	copy /y C:\ModifiedFiles\Makefile C:\APSIM\Model\Cotton\
)

rem Change DateTime format inside the docker container, otherwise unit tests will fail.
reg add "HKCU\Control Panel\International" /V sShortDate /T REG_SZ /D dd/MM/yyyy /F

set APSIM=C:\APSIM
cd %APSIM%

git fetch origin +refs/pull/*:refs/remotes/origin/pr/*
git checkout %sha1%

rem ----- Change to Build directory
cd %APSIM%\Model\Build

rem ----- This will tell the versionstamper not to increment the revision number.
%APSIM%\Model\cscs.exe %APSIM%\Model\Build\VersionStamper.cs Directory=%APSIM% Increment=no

rem ----- Set up the Visual Studio compiler tools
call "C:\BuildTools\Common7\Tools\VsDevCmd.bat"

rem ----- Compile the job scheduler.
echo Compiling the JobScheduler
msbuild "%APSIM%\Model\JobScheduler\JobScheduler.sln" /v:m

rem ----- Run the job scheduler.
JobScheduler Build\BuildAll.xml Target=Release

rem Upload installers to Bob.
@curl -s -u !BOB_CREDS! -T %PatchFileNameShort%.binaries.WINDOWS.INTEL.exe ftp://bob.apsim.info/Files/
@curl -s -u !BOB_CREDS! -T %PatchFileNameShort%.binaries.WINDOWS.X86_64.exe ftp://bob.apsim.info/Files/

rem Create diffs and binary archive.
%APSIM%/Model/CreateDiffZip.exe Directory=%APSIM% PatchFileName=%PatchFileName%
7z -xr!.svn a -mx=7 -mmt=on C:\%PatchFileNameShort%.buildtree.zip %APSIM%
7z a -mx=9 -mmt=on C:\%PatchFileNameShort%.binaries.zip %APSIM%\Model\*.exe %APSIM%\Model\*.dll

rem Upload diffs and binary archive to Bob.
@curl -s -u !BOB_CREDS! -T C:\%PatchFileNameShort%.buildtree.zip ftp://bob.apsim.info/Files/
@curl -s -u !BOB_CREDS! -T C:\%PatchFileNameShort%.binaries.zip ftp://bob.apsim.info/Files/

if errorlevel 1 (
	echo Compilation failed. Exiting...
	exit /b 1
)
