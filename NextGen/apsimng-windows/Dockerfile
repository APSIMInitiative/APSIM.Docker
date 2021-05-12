# APSIM Next Generation
#
# A container for building and running APSIM Next Generation on Windows.
#
# To build this container:
#    docker build -t apsiminitiative/apsimng-windows .

FROM mcr.microsoft.com/dotnet/sdk:5.0-windowsservercore-ltsc2019

SHELL ["powershell", "-Command"]

# Install chocolatey.
RUN Set-ExecutionPolicy Bypass -Scope Process -Force; \
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; \
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')); \
    choco feature disable –name showDownloadProgress; \
	choco feature enable -n allowGlobalConfirmation;

RUN choco install innosetup;
RUN choco install git;

RUN Invoke-WebRequest -Uri 'https://aka.ms/vs/16/release/vs_buildtools.exe' -OutFile C:/vs_buildtools.exe;
#RUN wget -q --no-check-certificate https://aka.ms/vs/16/release/vs_buildtools.exe -O vs_buildtools.exe
SHELL ["cmd /c"]
RUN start /wait C:/vs_BuildTools.exe -q --wait --norestart --nocache --installPath C:\BuildTools --add Microsoft.VisualStudio.Workload.ManagedDesktopBuildTools

ENTRYPOINT ["C:/BuildTools/Common7/Tools/VsDevCmd.bat"]
