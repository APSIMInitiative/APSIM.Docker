@echo off

set "usage=Usage: %0 URL [path/to/bin]"
rem First, make sure that an argument has been passed in.
if "%1" == "" (
	echo Error: no SVN URL provided.
	echo %usage%
	exit /b 1
)

rem We need to mount a directory containing the binaries.
rem First we check if the second argument (if it exists)
rem is a directory. If it is not, we check the current 
rem directory for a directory called bin. If that fails,
rem we error out.
if "%2" neq "" and exist %2 (
	set "bin=%2"
) else (
	if exist %~dp0bin (
		set bin=%~dp0bin
	) else (
		echo .\bin\ does not exist and no bin directory was provided.
		echo %usage%
		exit /b 1
	)
)

rem Next, check if the runtests image already exists
FOR /F "tokens=*" %%a in ('docker images -q runtests:latest') do SET imageid=%%a
if "%imageid%"=="" (
	if not exist .\runtests\ (
		echo runtests image does not exist, and nor does .\runtests\
		echo %usage%
		exit /b 1
	)
	echo runtests image does not exist. It will be created now...
	docker build -m 8gb .\runtests\ -t runtests
	if not errorlevel 0 (
		echo Error building runtests image.
		exit /b %errorlevel%
	)
)
@echo on
docker run -m 20gb --cpu-count %NUMBER_OF_PROCESSORS% -v %bin%:C:\bin runtests %1 > .\runtests.log
@echo off
if %errorlevel% equ 0 (
	echo Ran tests successfully. See %~dp0runtests.log for details.
) else (
	echo Tests did not run successfully. See %~dp0runtests.log for details.
)