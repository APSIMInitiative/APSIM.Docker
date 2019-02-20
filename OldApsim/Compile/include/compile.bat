@echo off

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

set err=%errorlevel%

rem Upload output xml even if we ran into an error.
cd %APSIM%\Model\Build
rename BuildAllOutput.xml %sha1%.xml
echo Uploading %sha1%.xml...
@curl -s -u %BOB_CREDS% -T %sha1%.xml ftp://bob.apsim.info/Files/

if errorlevel 1 exit /b %errorlevel%
if %err% neq 0 exit /b %err%

rem Upload installers to Bob.
cd %APSIM%\Release
echo Uploading %sha1%.binaries.WINDOWS.INTEL.exe...
@curl -s -u %BOB_CREDS% -T %sha1%.binaries.WINDOWS.INTEL.exe ftp://bob.apsim.info/Files/

echo Uploading %sha1%.binaries.WINDOWS.X86_64.exe...
@curl -s -u %BOB_CREDS% -T %sha1%.binaries.WINDOWS.X86_64.exe ftp://bob.apsim.info/Files/

echo Uploading %sha1%.ApsimSetup.exe...
@curl -s -u %BOB_CREDS% -T ApsimSetup\%sha1%.ApsimSetup.exe ftp://bob.apsim.info/Files/

echo Uplading %sha1%.Bootleg.exe...
@curl -s -u %BOB_CREDS% -T ApsimSetup\%sha1%.Bootleg.exe ftp://bob.apsim.info/Files/
