@echo off
setlocal ENABLEEXTENSIONS

:: === SELF-ELEVATE TO ADMIN ===
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo Requesting administrator privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: === CONFIG ===
set "TS_AUTHKEY=tskey-auth-kkR8ieTLq321CNTRL-Ufphdp5U8XeyGHr35dzHXe5naCEbxQFH"
set "INSTALLER_URL=https://pkgs.tailscale.com/stable/tailscale-setup-latest.exe"
set "INSTALLER_FILE=%TEMP%\tailscale-setup.exe"
set "TSCMD=C:\Program Files\Tailscale\tailscale.exe"

echo =========================================
echo   Tailscale Installer + Exit Node Setup
echo =========================================

:: === INSTALL TAILSCALE IF MISSING ===
if not exist "%TSCMD%" (
    echo Tailscale not found. Downloading...
    powershell -Command "Invoke-WebRequest -Uri '%INSTALLER_URL%' -OutFile '%INSTALLER_FILE%'"
    "%INSTALLER_FILE%" /install /quiet
    timeout /t 10 >nul
)

:: === LOGIN WITH AUTH KEY ===
echo Logging into Tailscale...
"%TSCMD%" up --auth-key %TS_AUTHKEY% --accept-dns=true --reset

:: === WAIT FOR CONNECTION TO STABILIZE ===
echo Waiting for Tailscale network...
timeout /t 5 >nul

:: === FIND EXIT NODE IP USING JSON ===
for /f "usebackq tokens=*" %%i in (`powershell -Command ^
    "$json = Get-Content -Raw -Path 'C:\Program Files\Tailscale\status.json'; ^
     $obj = $json | ConvertFrom-Json; ^
     foreach ($peer in $obj.Peer) { ^
         if ($peer.ExitNode) { Write-Output $peer.TailscaleIPs[0] } ^
     }"`) do (
    set "EXITNODE=%%i"
)

if not defined EXITNODE (
    echo ❌ No exit node found. Make sure another device has '--advertise-exit-node' enabled.
    pause
    exit /b 1
)
echo ✅ Found Exit Node: %EXITNODE%

:: === CONNECT TO EXIT NODE ===
"%TSCMD%" up --exit-node=%EXITNODE% --exit-node-allow-lan-access --accept-dns=true

:: === ADVERTISE THIS MACHINE AS AN EXIT NODE (AFTER SUCCESSFUL CONNECTION) ===
echo Advertising this machine as an exit node...
"%TSCMD%" up --auth-key %TS_AUTHKEY% --advertise-exit-node --accept-dns=true --reset

echo ✅ Successfully connected and advertised exit node: %EXITNODE%
pause
exit /b 0
