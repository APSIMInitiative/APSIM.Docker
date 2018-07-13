@echo off

rem Check if first argument was provided.
if "%1"=="" (
    echo Error: No commit SHA provided. Should be first argument
    exit 1
)

echo ########### Creating documentation
cd C:\Workspace\Documentation
call GenerateDocumentation.bat

echo.
echo ########### Creating Windows installation
cd ..\Setup
ISCC.exe apsimx.iss

echo ########### Creating Debian package
cd Linux
call BuildDeb.bat

echo ########### Creating Mac OS X installation
cd "..\OS X"
call BuildMacDist.bat



rem echo ########### Uploading installations
rem cd "C:\Jenkins\workspace\1. GitHub pull request\ApsimX\Setup"
rem call C:\Jenkins\ftpcommand.bat %Issue_Number%
rem echo.
rem 
rem echo ########### Add a green build to DB
rem set /p PASSWORD=<C:\Jenkins\ChangeDBPassword.txt
rem curl -k https://www.apsim.info/APSIM.Builds.Service/Builds.svc/AddGreenBuild?pullRequestNumber=%ghprbPullId%^&buildTimeStamp=%DATETIMESTAMP%^&changeDBPassword=%PASSWORD%
