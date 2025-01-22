@echo off
rem This script run inside a docker container by the Jenkins
rem infrastructure. It will build and upload the windows .NET Core
rem installer.
rem
rem Requires no command line arguments, but requires that a few
rem environment variables are set:
rem
rem APSIM_CERT_PWD: Password on the certificate file.
rem APSIM_CERT: Path to the certificate file on disk.
rem BUILDS_JWT: JWT for auth with builds API, required to upload the installer.

setlocal enableDelayedExpansion
setlocal

rem Ensure the necessary environment variables are set.
rem if not defined APSIM_CERT_PWD (echo APSIM_CERT_PWD not set && exit /b 1)
rem if not defined APSIM_CERT (echo APSIM_CERT not set && exit /b 1)
rem if not defined BUILDS_JWT (echo BUILDS_JWT not set && exit /b 1)

rem Without the -m:1 below, the order of builds can be incorrect sometimes resulting in this order:
rem     Models -> C:\container-scripts\ApsimX\bin\Release\net8.0\win-x64\Models.dll
rem     Models -> C:\container-scripts\ApsimX\bin\Release\net8.0\Models.dll
rem     Models -> C:\container-scripts\ApsimX\bin\Release\net8.0\win-x64\publish\Models.dll
rem This can lead to an incorrect  publish\models.deps.json. taken from net8.0 directory rather than from netcoreapp3.1\win-x64 directory
rem bug: https://github.com/APSIMInitiative/ApsimX/issues/7829
dotnet publish -c Release -f net8.0 -r win-x64 -m:1 --no-self-contained "%apsimx%\ApsimX.sln"
if errorlevel 1 exit /b 1

rem Generate the installer.
set "setup=%apsimx%\Setup\net8.0\windows"
inno/iscc.exe /Q "%setup%\apsimx.iss"
if errorlevel 1 exit /b 1
set "INSTALLER=apsim-%REVISION%.exe"
move "%setup%\Output\ApsimSetup.exe" "%INSTALLER%"
if errorlevel 1 exit /b 1

endlocal
