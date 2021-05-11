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
	choco feature enable -n allowGlobalConfirmation; \

RUN choco install innosetup;

ENTRYPOINT ["powershell"]
