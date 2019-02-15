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
git show-ref -s %sha%>C:\sha1.txt
set /p sha1=<C:\sha1.txt
echo sha1=%sha1%
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
cd %APSIM%\Model
JobScheduler Build\BuildAll.xml Target=Release

rem Upload installers to Bob.
cd %APSIM%\Release
echo Uploading %sha1%.binaries.WINDOWS.INTEL.exe...
@curl -s -u %BOB_CREDS% -T %sha1%.binaries.WINDOWS.INTEL.exe ftp://bob.apsim.info/Files/
echo Uploading %sha1%.binaries.WINDOWS.X86_64.exe...
@curl -s -u %BOB_CREDS% -T %sha1%.binaries.WINDOWS.X86_64.exe ftp://bob.apsim.info/Files/

rem Create diffs and binary archive.
%APSIM%/Model/CreateDiffZip.exe Directory=%APSIM% PatchFileName=%sha1%
7z -xr!.svn a -mx=7 -mmt=on C:\%sha1%.buildtree.zip %APSIM%
7z a -mx=9 -mmt=on C:\%sha1%.binaries.zip %APSIM%\Model\*.exe %APSIM%\Model\*.dll

rem Upload diffs and binary archive to Bob.
echo Skipping C:\%sha1%.buildtree.zip...
rem @curl -s -u %BOB_CREDS% -T C:\%sha1%.buildtree.zip ftp://bob.apsim.info/Files/
echo Uploading C:\%sha1%.binaries.zip...
@curl -s -u %BOB_CREDS% -T C:\%sha1%.binaries.zip ftp://bob.apsim.info/Files/

cd %APSIM%\Model\Build
rename BuildAll.xml %sha1%.xml
echo Uploading %sha1%.xml...
@curl -s -u %BOB_CREDS% -T %sha1%.xml ftp://bob.apsim.info/Files/