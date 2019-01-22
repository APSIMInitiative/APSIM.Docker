@echo off
set TIMESTAMP="http://timestamp.comodoca.com/?td=sha256"
set SIGNTOOL="C:\Program Files (x86)\Windows Kits\10\bin\10.0.17763.0\x64\signtool.exe"
set SERTIFICATE="C:\new-code-signer.pfx"
set p="c0d3rCSIR0"

%SIGNTOOL% sign /q /as /fd sha256 /tr %TIMESTAMP% /td sha256 /f %SERTIFICATE% /p %p% %1
%SIGNTOOL% verify /pa /v /d %1
