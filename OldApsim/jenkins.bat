@echo off
setlocal enableDelayedExpansion

rem ----- Copy signing files
copy /y C:\\new-code-signer.pfx Docker\\OldApsim\\include\\>nul
copy /y C:\\dbConnect.txt Docker\\OldApsim\\include\\>nul
if errorlevel 1 (
	echo Error: Unable to copy signing files.
	exit /b 1
)

rem ----- Get the target job to be run by the job scheduler
if "%TARGET%"=="" (
	echo Error: no target job for job scheduler specified
	echo Usage: %0 TARGET
	exit /b 1
)

rem ----- Display target job
set TARGET

rem ----- Build docker image
docker build -m 12g -t buildapsim %cd%\\Docker\\OldApsim
if errorlevel 1 (
	echo Error: Unable to build docker image.
	exit /b 1
)

rem ----- Run docker container.
docker run -m 12g -e PatchFileNameShort -e "sha=%sha1%" -e MERGE_COMMIT -e REVISION_NUMBER -e TARGET -e APSIM_CREDS -e DB_CONN_PSW -e JOB_ID --cpu-count %NUMBER_OF_PROCESSORS% buildapsim
