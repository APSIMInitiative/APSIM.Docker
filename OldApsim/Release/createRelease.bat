@echo off
setlocal enableDelayedExpansion

rem ----- Get revision number for this build.
echo Adding build to builds DB...
@curl -sk "http://apsimdev.apsim.info/APSIM.Builds.Service/BuildsClassic.svc/GetRevisionNumber?PullID=!PULL_ID!^&DbConnectPassword=!DB_CONN_PSW!" > temp.txt

if errorlevel 1 (
	echo Error: Unable to add build to Builds DB.
	exit /b 1
)

rem ----- Read response (Job ID) from server.
for /F "tokens=1-6 delims==><" %%I IN (temp.txt) DO SET REVISION_NUMBER=%%K
set RES=F
if errorlevel 1 set RES=T 			rem if errorlevel 1
if "!REVISION_NUMBER!"=="" set RES=T 		rem or "!REVISION_NUMBER!"==""
if "!RES!"=="T" (
	echo Error: Unable to read revision number from response. Response:
	type temp.txt
	del temp.txt
	exit 1
)

rem ----- Display Job ID and delete temp file.
set REVISION_NUMBER
del temp.txt

rem ----- Set some necessary environment variables.
set "PatchFileNameShort=Apsim710-r%REVISION_NUMBER%"
set "TARGET=JenkinsRelease"

call Docker\\OldApsim\\jenkins.bat
