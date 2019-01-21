@echo off
rem This should never happen - APSIM is cloned when the docker image is built.
if not exist C:\APSIM (
	echo Error: C:\APSIM not found. This should be cloned as part of the docker build step.
	exit 1
)

rem Certain files involved in the build process have been modified to facilitate
rem compilation in docker. These will eventually be merged into the main branch,
rem but until then, we need to copy them manually.
echo Copying modified files.
if exist C:\ModifiedFiles\ (
	echo Copying modified build files
	copy /y C:\ModifiedFiles\Build\* C:\APSIM\Model\Build\
	copy /y C:\ModifiedFiles\Makefile C:\APSIM\Model\Cotton\
)
reg add "HKCU\Control Panel\International" /V sShortDate /T REG_SZ /D dd/MM/yyyy /F
cd C:\APSIM
git fetch origin +refs/pull/*:refs/remotes/origin/pr/*
git checkout %sha1%
cd Model\Build
call BuildAll
if errorlevel 1 (
	echo Compilation failed. Exiting...
	exit /b 1
)

