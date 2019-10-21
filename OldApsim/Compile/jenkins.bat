@echo off
setlocal enableDelayedExpansion

rem ----- Add this build to the builds DB.
echo Adding build to builds DB...
@curl -sk "http://apsimdev.apsim.info/APSIM.Builds.Service/BuildsClassic.svc/AddPullRequest?PullID=!ghprbPullId!^&JenkinsID=!BUILD_NUMBER!^&Password=!BUILD_PSW!^&DbConnectPassword=!DB_CONN_PSW!" > temp.txt

if errorlevel 1 (
	echo Error: Unable to add build to Builds DB.
	exit /b 1
)

rem ----- Read response from server.
for /F "tokens=1-6 delims==><" %%I IN (temp.txt) DO SET JOB_ID=%%K
set RES=F
if errorlevel 1 set RES=T 			rem if errorlevel 1
if "!JOB_ID!"=="" set RES=T 		rem or "!JOB_ID!"==""
if "!RES!"=="T" (
	echo Error: Unable to read Job ID from response. Response:
	type temp.txt
	exit 1
)

rem ----- Display Job ID and delete temp file.
set JOB_ID
del temp.txt

rem ----- Use pull request ID as patch file name.
set "PatchFileNameShort=%ghprbPullId%"

rem ----- Copy signing files
copy /y C:\\new-code-signer.pfx Docker\\OldApsim\\Compile\\include\\>nul
copy /y C:\\dbConnect.txt Docker\\OldApsim\\Compile\\include\\>nul
if errorlevel 1 (
	echo Error: Unable to copy signing files.
	exit /b 1
)

rem ----- Build docker image
docker build -m 12g -t buildapsim %cd%\\Docker\\OldApsim\\Compile
if errorlevel 1 (
	echo Error: Unable to build docker image.
	exit /b 1
)

rem ----- Run docker container.
docker run -m 12g -e PatchFileNameShort -e "sha=%sha1%" -e BOB_CREDS -e DB_CONN_PSW -e JOB_ID --cpu-count %NUMBER_OF_PROCESSORS% buildapsim
set err=%errorlevel%

rem ----- Call webservice and flag build as passed or failed.
if errorlevel 1 (
	echo Flagging build as failed...
	set STATUS=Fail

) else (
	echo Flagging build as passed... 
	set STATUS=Pass
)
@curl -sk "http://apsimdev.apsim.info/APSIM.Builds.Service/BuildsClassic.svc/UpdateStatus?JobID=!JOB_ID!^&NewStatus=!STATUS!^&DbConnectPassword=!DB_CONN_PSW!"
@curl -sk "http://apsimdev.apsim.info/APSIM.Builds.Service/BuildsClassic.svc/UpdateEndDateToNow?JobID=!JOB_ID!^&DbConnectPassword=!DB_CONN_PSW!"

rem ----- If we ran into a problem while updating pass/fail status, exit with non-zero code
if errorlevel 1 exit /b %errorlevel%

rem ----- If build did not run green, exit with docker container's exit code.
if !err! geq 1 exit /b !err!

rem ----- Otherwise, exit normally.
endlocal