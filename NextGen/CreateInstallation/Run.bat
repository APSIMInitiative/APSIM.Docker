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
echo.
echo ########### Creating documentation
cd \ApsimX\Documentation
call GenerateDocumentation.bat
IF ERRORLEVEL 1 GOTO END

echo.
echo ########### Creating Windows installation
cd \ApsimX\Setup
"C:\Program Files (x86)\Inno Setup 5\ISCC.exe" apsimx.iss
IF ERRORLEVEL 1 GOTO END

echo ########### Creating Debian package
if exist \ApsimX\Setup\Linux\BuildDeb.bat (
    cd \ApsimX\Setup\Linux
    call BuildDeb.bat
)
IF ERRORLEVEL 1 GOTO END

echo ########### Creating Mac OS X installation
if exist "\ApsimX\Setup\OS X\BuildMacDist.bat" (
cd "\ApsimX\Setup\OS X"
call BuildMacDist.bat
cd ..
)
IF ERRORLEVEL 1 GOTO END

rem echo ########### Uploading installations
rem cd "C:\Jenkins\workspace\1. GitHub pull request\ApsimX\Setup"
rem call C:\Jenkins\ftpcommand.bat %Issue_Number%
rem echo.
rem 
rem echo ########### Add a green build to DB
rem set /p PASSWORD=<C:\Jenkins\ChangeDBPassword.txt
rem curl -k https://www.apsim.info/APSIM.Builds.Service/Builds.svc/AddGreenBuild?pullRequestNumber=%ghprbPullId%^&buildTimeStamp=%DATETIMESTAMP%^&changeDBPassword=%PASSWORD%
