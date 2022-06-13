@echo off
setlocal enableDelayedExpansion

rem ----- Add this build to the builds DB.
echo Adding build to builds DB...
@curl -sX POST -H "Authorization: bearer !BUILDS_JWT!" "https://builds.apsim.info/api/oldapsim/add?pullRequestId=!ghprbPullId!^&jenkinsId=!BUILD_NUMBER!" > temp.txt
type temp.txt
if errorlevel 1 (
	echo Error: Unable to add build to Builds DB.
	exit /b 1
)

rem ----- Read Job ID from the response.
set /p JOB_ID=<temp.txt

rem ----- Display Job ID and delete temp file.
set JOB_ID
del temp.txt

rem ----- Use pull request ID as patch file name.
set "PatchFileNameShort=%ghprbPullId%"
set TARGET=BobBuildAndRun
set REVISION_NUMBER=0
set MERGE_COMMIT=%sha1%
set sha1=

call Docker\\OldApsim\\jenkins.bat
set err=%errorlevel%

rem ----- Call webservice and flag build as passed or failed.
if errorlevel 1 (
	echo Flagging build as failed...
	set PASS=false

) else (
	echo Flagging build as passed... 
	set Pass=true
)
@curl -sX POST -H "Authorization: bearer !BUILDS_JWT!" "https://builds.apsim.info/api/oldapsim/update?jobID=!JOB_ID!^&pass=!PASS!"

rem ----- If we ran into a problem while updating pass/fail status, exit with non-zero code
if errorlevel 1 exit /b %errorlevel%

rem ----- If build did not run green, exit with docker container's exit code.
if !err! geq 1 exit /b !err!

rem ----- Otherwise, exit normally.
endlocal