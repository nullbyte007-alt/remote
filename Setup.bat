@echo off
title MyVPN Setup Console
color 0A
:menu
cls
echo ===============================
echo      MyVPN Setup Console
echo ===============================
echo.
echo 1. Run Tailscale Setup
echo 2. Run Exit Node Configuration
echo 3. Self-Destruct (Delete All Files)
echo 4. Exit
echo.
set /p choice=Enter your choice (1-4): 

if "%choice%"=="1" goto setup
if "%choice%"=="2" goto exitnode
if "%choice%"=="3" goto selfdestruct
if "%choice%"=="4" exit
goto menu

:setup
echo.
echo Running setup_tailscale.bat...
call setup_tailscale.bat
echo Done.
pause
goto menu

:exitnode
echo.
echo Running exit_node.bat...
call exit_node.bat
echo Done.
pause
goto menu

:selfdestruct
echo.
echo WARNING: This will delete all setup files including this menu.
echo Press any key to continue or Ctrl+C to abort.
pause >nul

:: Create a temporary script that deletes everything including this menu
echo @echo off > "%TEMP%\selfdel.bat"
echo timeout /t 2 >nul >> "%TEMP%\selfdel.bat"
echo del /f /q "%~f0" >> "%TEMP%\selfdel.bat"
echo rmdir /s /q "%~dp0" >> "%TEMP%\selfdel.bat"

start "" "%TEMP%\selfdel.bat"
exit
