@echo off

rem This script runs inside docker. It compiles the jobscheduler
rem and runs the job specified by the TARGET environment variable.

rem Change DateTime format inside the docker container, otherwise unit tests will fail.
reg add "HKCU\Control Panel\International" /V sShortDate /T REG_SZ /D dd/MM/yyyy /F

set APSIM=C:\APSIM
cd %APSIM%

git fetch origin +refs/pull/*:refs/remotes/origin/pr/*
if not defined sha (
	if defined MERGE_COMMIT (
		git show-ref -s %MERGE_COMMIT%>C:\sha1.txt
		set /p sha1=<C:\sha1.txt
		del C:\sha1.txt
	) else (
		echo No sha or merge commit provided. Aborting...
		exit 1
	)
) else set sha1=%sha%

echo sha1=%sha1%
git checkout %sha1%

rem ----- Display patch file name.
echo PatchFileNameShort=%PatchFileNameShort%

rem ----- This will prevent the git hash from being inserted into the output files.
set IncludeBuildNumberInOutSumFile=No

rem ----- Change to Build directory.
cd %APSIM%\Model\Build

rem ----- This will tell the versionstamper not to increment the revision number.
%APSIM%\Model\cscs.exe %APSIM%\Model\Build\VersionStamper.cs Directory=%APSIM% Increment=no RevisionNumber=%REVISION_NUMBER%

rem ----- Set up the Visual Studio compiler tools
call "C:\BuildTools\Common7\Tools\VsDevCmd.bat"

rem ----- Compile the job scheduler.
echo Compiling the JobScheduler
msbuild "%APSIM%\Model\JobScheduler\JobScheduler.sln" /v:m

rem ----- Run the job scheduler.
cd %APSIM%\Model
JobScheduler Build\BuildAll.xml Target=%TARGET%

set err=%errorlevel%

rem ----- Upload output xml and diff zip even if we ran into an error.
cd %APSIM%\Model\Build
rename BuildAllOutput.xml %PatchFileNameShort%.xml
echo Uploading %PatchFileNameShort%.xml...
@curl -s -u %APSIM_CREDS% -T %PatchFileNameShort%.xml ftp://apsimdev.apsim.info/APSIM/APSIMClassicFiles/

cd %APSIM%
if exist %PatchFileNameShort%.diffs.zip (
	echo Uploading %PatchFileNameShort%.diffs.zip...
	@curl -s -u %APSIM_CREDS% -T %PatchFileNameShort%.diffs.zip ftp://apsimdev.apsim.info/APSIM/APSIMClassicFiles/
)

if %err% geq 1 exit /b %err%

cd %APSIM%\Release

rem ----- Upload installers to Bob.
set err=0
call :upload %PatchFileNameShort%.binaries.WINDOWS.INTEL.exe
if errorlevel 1 set err=1

call :upload %PatchFileNameShort%.binaries.WINDOWS.X86_64.exe
if errorlevel 1 set err=1

pushd ApsimSetup
call :upload %PatchFileNameShort%.ApsimSetup.exe
if errorlevel 1 set err=1
popd

if %err% geq 1 echo Error: 1 or more errors round while uploading installers.
exit %err%

:upload
setlocal

set "FILENAME=%1"
if exist %FILENAME% (
	echo Uploading %FILENAME%...
	@curl -s -u %APSIM_CREDS% -T %FILENAME% ftp://apsimdev.apsim.info/APSIM/APSIMClassicFiles/
) else (
	echo %FILENAME% does not exist. Skipping...
)

endlocal
exit /b