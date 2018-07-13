@echo off
if not exist C:\bin (
    echo C:\bin does not exist. This directory must be mounted via the docker run -v switch.
    exit 1
)
rem Check if first argument was provided.
if "%1"=="" (
    echo Error: No URL provided.
    exit 1
)

rem Get all files from GitHub for specific commit SHA
git clone https://github.com/APSIMInitiative/ApsimX C:\APSIMx
cd \ApsimX
git reset --hard %1

rem Create installs
cd \ApsimX\Setup
call BuildInstalls.bat
