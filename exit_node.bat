@echo off 
setlocal

:: === SETTINGS ===
:: Set your reusable auth key here
tailscale up --advertise-exit-node --auth-key tskey-... --accept-dns=true
exit /b 0