@echo off
setlocal enableDelayedExpansion

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
mkdir cert
move "%APSIM_CERT%" cert\apsim.p12
docker run -m 12g -e PatchFileNameShort -e "sha=%sha1%" -v "%cd%\cert":C:\cert -e MERGE_COMMIT -e REVISION_NUMBER -e TARGET -e APSIM_CERT_PWD -e APSIM_CREDS -e DB_CONN_PSW -e JOB_ID -e BUILDS_JWT --cpu-count %NUMBER_OF_PROCESSORS% buildapsim
