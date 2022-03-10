@echo off
setlocal enableDelayedExpansion

rem ----- Get revision number for this build.
echo Fetching latest revision number...
@curl -sX POST -H "Authorization: bearer !BUILDS_JWT!" "https://builds.apsim.info/api/oldapsim/getrevision" > temp.txt

if errorlevel 1 (
	echo Error: Unable to add build to Builds DB.
	exit /b 1
)

rem ----- Read response (Revision number) from server.
SET /p REVISION_NUMBER=<temp.txt

rem ----- Delete temp file.
del temp.txt

rem ----- Increment revision number.
set /a REVISION_NUMBER=%REVISION_NUMBER%+1 >nul

rem ----- Display Job ID.
set REVISION_NUMBER

rem ----- Set some necessary environment variables.
set "PatchFileNameShort=Apsim7.10-r%REVISION_NUMBER%"
set "TARGET=JenkinsRelease"

call Docker\\OldApsim\\jenkins.bat
if errorlevel 1 exit /b 1

rem ----- Update revision number for this pull request.
echo Updating revision number for pull request #%PULL_ID% to %REVISION_NUMBER%...
@curl -sX POST -H "Authorization: bearer !BUILDS_JWT!" "https://builds.apsim.info/api/oldapsim/setrevision?pullRequestId=%PULL_ID%^&revision=%REVISION_NUMBER%" > temp.txt
if errorlevel 1 (
	set err=%errorlevel%
	echo Error setting revision number:
	type temp.txt
)

endlocal
exit /b %err%
