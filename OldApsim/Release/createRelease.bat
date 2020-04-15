@echo off
setlocal enableDelayedExpansion

rem ----- Get revision number for this build.
echo Fetching latest revision number...
@curl -sk "http://apsimdev.apsim.info/APSIM.Builds.Service/BuildsClassic.svc/GetLatestRevisionNo" > temp.txt

if errorlevel 1 (
	echo Error: Unable to add build to Builds DB.
	exit /b 1
)

rem ----- Read response (Revision number) from server.
for /F "tokens=1-6 delims==><" %%I IN (temp.txt) DO SET REVISION_NUMBER=%%K
set RES=F
if errorlevel 1 set RES=T 					rem if errorlevel 1
if "!REVISION_NUMBER!"=="" set RES=T 		rem or "!REVISION_NUMBER!"==""
if "!RES!"=="T" (
	echo Error: Unable to read revision number from response. Response:
	type temp.txt
	del temp.txt
	exit 1
)

rem ----- Increment revision number.
set /a REVISION_NUMBER=%REVISION_NUMBER%+1 >nul

rem ----- Display Job ID and delete temp file.
set REVISION_NUMBER
del temp.txt

rem ----- Set some necessary environment variables.
set "PatchFileNameShort=Apsim7.10-r%REVISION_NUMBER%"
set "TARGET=JenkinsRelease"

call Docker\\OldApsim\\jenkins.bat
if errorlevel 1 exit /b 1

rem ----- Update revision number for this pull request.
echo Updating revision number for pull request #%PULL_ID% to %REVISION_NUMBER%
@curl -sk "http://apsimdev.apsim.info/APSIM.Builds.Service/BuildsClassic.svc/UpdateRevisionNumberForPR?pullRequestID=%PULL_ID%^&revisionNumber=%REVISION_NUMBER%^&DbConnectPassword=!DB_CONN_PSW!" > temp.txt
endlocal
