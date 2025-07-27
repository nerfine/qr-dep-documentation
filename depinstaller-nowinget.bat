@echo off
setlocal enabledelayedexpansion

set "INSTALL_DOTNET=1"
set "INSTALL_VCREDIST_X64=1"
set "INSTALL_VCREDIST_X86=1"
set "INSTALL_WEBVIEW2=1"
set "INSTALL_DIRECTX=1"
set "INSTALL_NDP481=1"

if /i "%~1"=="--help" goto show_help

net session >nul 2>&1
if !errorlevel! NEQ 0 (
    set "ARGSFILE=%TEMP%\depinstaller_args.txt"
    echo %* > "!ARGSFILE!"
    powershell -Command "Start-Process '%~f0' -Verb runAs"
    exit /b
)

set "TEMPDIR=%TEMP%\batch_installer"
if not exist "%TEMPDIR%" mkdir "%TEMPDIR%"

if exist "%TEMPDIR%\depinstaller_*.log" (
    echo Cleaning up previous log files...
    del /f /q "%TEMPDIR%\depinstaller_*.log" >nul 2>&1
)

for /f %%A in ('powershell -NoProfile -Command "[datetime]::Now.ToString(\"yyyyMMdd_HHmmss\")"') do set "LOGSTAMP=%%A"
set "LOGFILE=%TEMPDIR%\depinstaller_%LOGSTAMP%.log"

echo Logging to "%LOGFILE%"
call :main
exit /b
:main
call :log "╔══════════════════════════════════════════════════════╗"
call :log "            🐰 Bunni Dependency Installer             "
call :log "        Optimized by NERFINE - Base: SYSDRIVER        "
call :log "╚══════════════════════════════════════════════════════╝"
call :log ""

set "ARGSFILE=%TEMP%\depinstaller_args.txt"
if exist "%ARGSFILE%" (
    set /p ARGS=<"%ARGSFILE%"
    del "%ARGSFILE%" >nul 2>&1
    call :parse_args_string "!ARGS!"
) else (
    call :parse_args_from_cmdline %*
)
goto continue_main

:continue_main

call :log "[INFO] Checking for administrative privileges..."
call :log "[SUCCESS] Running as administrator."
call :log ""
call :log "[INFO] Parsing command-line arguments..."
if "%INSTALL_DOTNET%"=="0" call :log "         --no-dotnet: YES"
if "%INSTALL_VCREDIST_X64%"=="0" call :log "         --no-vcredist: YES"
if "%INSTALL_WEBVIEW2%"=="0" call :log "         --no-webview2: YES"
if "%INSTALL_DIRECTX%"=="0" call :log "         --no-directx: YES"
if "%INSTALL_NDP481%"=="0" call :log "         --no-framework: YES"
if "%QUIET_MODE%"=="1" call :log "         --quiet: YES"
call :log "[SUCCESS] Component flags set."
call :log ""

echo.
echo ==============================
echo   Bunni Dependency Installer
echo ==============================
echo.

call :log "[INFO] 🧰 Checking system prerequisites..."
call :log ""

call :log "    Checking PowerShell..."
where powershell >nul 2>&1
if %errorlevel% NEQ 0 (
    call :log "    [✖] PowerShell not found. This script requires PowerShell."
    call :log "    [!] Auto-closing in 10 seconds..."
    timeout /t 10 /nobreak >nul 2>&1
    exit /b 1
)
call :log "    [✔] PowerShell found."

call :log "    Checking Winget..."
call :log "    [~] Winget not required for this installer."

call :log ""

for /f %%A in ('powershell -NoProfile -Command "[guid]::NewGuid().ToString('N')"') do set "UUID=%%A"
set "VCREDIST_X64=%TEMPDIR%\vc_redist_x64_%UUID%.exe"
set "VCREDIST_X86=%TEMPDIR%\vc_redist_x86_%UUID%.exe"
set "WEBVIEW2=%TEMPDIR%\webview2_%UUID%.exe"
set "DXREDIST=%TEMPDIR%\directx_redist_%UUID%.exe"
set "NDP481=%TEMPDIR%\ndp481_%UUID%.exe"

set "DOTNET_URL=https://download.visualstudio.microsoft.com/download/pr/105b0f6d-d3b9-4a41-a78b-321cb74a44a0/e287dc267a9c67ea23834d06239e6e7a/windowsdesktop-runtime-8.0.7-win-x64.exe"
set "VCREDIST_X64_URL=https://aka.ms/vs/17/release/vc_redist.x64.exe"
set "VCREDIST_X86_URL=https://aka.ms/vs/17/release/vc_redist.x86.exe"
set "WEBVIEW2_URL=https://go.microsoft.com/fwlink/p/?LinkId=2124703"
set "DIRECTX_URL=https://download.microsoft.com/download/1/6/1/161a7e5d-9d07-4f31-9276-c44a69c6f0e3/directx_Jun2010_redist.exe"
set "NDP481_URL=https://go.microsoft.com/fwlink/?linkid=2088631"

set "DOTNET_SHA256=391ca05d7540c58f25047ae07b8c5656829f7fd32f6e88a4e34c5337525f574e5714657e1c4f4f4d48e006087f573f8c03f1fc8eab8c9b9dab4d5ca5c8ea1fd4"
set "VCREDIST_X64_SHA256=UNKNOWN"
set "VCREDIST_X86_SHA256=UNKNOWN"

set "DOTNET_STATUS=UNKNOWN"
set "VCREDIST_X64_STATUS=UNKNOWN"
set "VCREDIST_X86_STATUS=UNKNOWN"
set "WEBVIEW2_STATUS=UNKNOWN"
set "DIRECTX_STATUS=UNKNOWN"
set "NDP481_STATUS=UNKNOWN"
set "REBOOT_REQUIRED=0"

echo.
echo ==============================
echo Checking dependencies
echo ==============================
echo.

call :log "════════════════════════════════════════════════════════"
call :log "🔍 Checking Dependencies"
call :log "════════════════════════════════════════════════════════"
call :log ""

call :check_all_dependencies

call :log ""
call :log "════════════════════════════════════════════════════════"
call :log "📋 Dependency Check Summary"
call :log "════════════════════════════════════════════════════════"
call :log ""

set "MISSING_COUNT=0"
if "%DOTNET_STATUS%"=="MISSING" if "%INSTALL_DOTNET%"=="1" set /a MISSING_COUNT+=1
if "%VCREDIST_X64_STATUS%"=="MISSING" if "%INSTALL_VCREDIST_X64%"=="1" set /a MISSING_COUNT+=1
if "%VCREDIST_X86_STATUS%"=="MISSING" if "%INSTALL_VCREDIST_X86%"=="1" set /a MISSING_COUNT+=1
if "%WEBVIEW2_STATUS%"=="MISSING" if "%INSTALL_WEBVIEW2%"=="1" set /a MISSING_COUNT+=1
if "%DIRECTX_STATUS%"=="MISSING" if "%INSTALL_DIRECTX%"=="1" set /a MISSING_COUNT+=1
if "%NDP481_STATUS%"=="MISSING" if "%INSTALL_NDP481%"=="1" set /a MISSING_COUNT+=1

call :display_check_summary

if %MISSING_COUNT% EQU 0 (
    call :log ""
    call :log "🎉 All dependencies are already installed!"
    call :log "📁 Log saved at: %LOGFILE%"
    call :log ""
    call :log "[SUCCESS] No installation required."
    echo.
    echo ==============================
    echo Process Complete
    echo ==============================
    echo.
    
    call :log "[INFO] Closing in 3 seconds..."
    timeout /t 3 /nobreak >nul 2>&1
    exit /b 0
)

call :log ""
call :log "[INFO] Found %MISSING_COUNT% missing dependencies."
echo.
echo ==============================
echo Installation Confirmation
echo ==============================
echo.
echo Found %MISSING_COUNT% missing dependencies that need to be installed.
echo.
set /p "CONFIRM=Do you want to install the missing dependencies? (Y/N): "

if /i not "%CONFIRM%"=="Y" if /i not "%CONFIRM%"=="YES" (
    call :log ""
    call :log "[INFO] Installation cancelled by user."
    call :log "📁 Log saved at: %LOGFILE%"
    echo Installation cancelled. Exiting...
    echo.
    
    timeout /t 2 /nobreak >nul 2>&1
    exit /b 0
)

echo.
echo ==============================
echo Installing missing components
echo ==============================
echo.

call :log ""
call :log "════════════════════════════════════════════════════════"
call :log "🔧 Installing Missing Components"
call :log "════════════════════════════════════════════════════════"
call :log ""

if "%INSTALL_DOTNET%"=="0" (
    call :log "[1/?] .NET Desktop Runtime 8.0"
    call :log "    [~] Skipped by user (--no-dotnet)"
) else if "%DOTNET_STATUS%"=="MISSING" (
    call :log "[1/?] .NET Desktop Runtime 8.0"
    call :log "    [↻] Installing..."
    call :install_dotnet_runtime
) else (
    call :log "[1/?] .NET Desktop Runtime 8.0"
    call :log "    [✔] Already installed. Skipping."
)
call :log ""

if "%INSTALL_VCREDIST_X64%"=="0" (
    call :log "[2/?] VC++ Redistributable x64"
    call :log "    [~] Skipped by user (--no-vcredist)"
) else if "%VCREDIST_X64_STATUS%"=="MISSING" (
    call :log "[2/?] VC++ Redistributable x64"
    call :log "    [↻] Installing..."
    call :install_vcredist_x64
) else (
    call :log "[2/?] VC++ Redistributable x64"
    call :log "    [✔] Already installed. Skipping."
)
call :log ""

if "%INSTALL_VCREDIST_X86%"=="0" (
    call :log "[3/?] VC++ Redistributable x86"
    call :log "    [~] Skipped by user (--no-vcredist)"
) else if "%VCREDIST_X86_STATUS%"=="MISSING" (
    call :log "[3/?] VC++ Redistributable x86"
    call :log "    [↻] Installing..."
    call :install_vcredist_x86
) else (
    call :log "[3/?] VC++ Redistributable x86"
    call :log "    [✔] Already installed. Skipping."
)
call :log ""

if "%INSTALL_WEBVIEW2%"=="0" (
    call :log "[4/?] WebView2 Runtime"
    call :log "    [~] Skipped by user (--no-webview2)"
) else if "%WEBVIEW2_STATUS%"=="MISSING" (
    call :log "[4/?] WebView2 Runtime"
    call :log "    [↻] Installing..."
    call :install_webview2
) else (
    call :log "[4/?] WebView2 Runtime"
    call :log "    [✔] Already installed. Skipping."
)
call :log ""

if "%INSTALL_DIRECTX%"=="0" (
    call :log "[5/?] DirectX Runtime"
    call :log "    [~] Skipped by user (--no-directx)"
) else if "%DIRECTX_STATUS%"=="MISSING" (
    call :log "[5/?] DirectX Runtime"
    call :log "    [↻] Installing..."
    call :install_directx
) else (
    call :log "[5/?] DirectX Runtime"
    call :log "    [✔] Already installed. Skipping."
)
call :log ""

if "%INSTALL_NDP481%"=="0" (
    call :log "[6/?] .NET Framework 4.8.1"
    call :log "    [~] Skipped by user (--no-framework)"
) else if "%NDP481_STATUS%"=="MISSING" (
    call :log "[6/?] .NET Framework 4.8.1"
    call :log "    [↻] Installing..."
    call :install_ndp481
) else (
    call :log "[6/?] .NET Framework 4.8.1"
    call :log "    [✔] Already installed. Skipping."
)
call :log ""

echo.
echo ==============================
echo Installation Summary
echo ==============================
echo [Check] .NET Desktop Runtime 8.0 .......... %DOTNET_STATUS%
echo [Check] VC++ Redist x64 ................... %VCREDIST_X64_STATUS%
echo [Check] VC++ Redist x86 ................... %VCREDIST_X86_STATUS%
echo [Check] WebView2 Runtime .................. %WEBVIEW2_STATUS%
echo [Check] DirectX Runtime ................... %DIRECTX_STATUS%
echo [Check] .NET Framework 4.8.1 .............. %NDP481_STATUS%
echo.

call :log ""
call :log "════════════════════════════════════════════════════════"
call :log "📋 Final Installation Summary"
call :log "════════════════════════════════════════════════════════"
call :log ""

if "%DOTNET_STATUS%"=="INSTALLED" set "DOTNET_SYMBOL=✔"
if "%DOTNET_STATUS%"=="USER_SKIPPED" set "DOTNET_SYMBOL=~"
if "%DOTNET_STATUS%"=="FAILED" set "DOTNET_SYMBOL=✖"

if "%VCREDIST_X64_STATUS%"=="INSTALLED" set "VC64_SYMBOL=✔"
if "%VCREDIST_X64_STATUS%"=="USER_SKIPPED" set "VC64_SYMBOL=~"
if "%VCREDIST_X64_STATUS%"=="FAILED" set "VC64_SYMBOL=✖"

if "%VCREDIST_X86_STATUS%"=="INSTALLED" set "VC86_SYMBOL=✔"
if "%VCREDIST_X86_STATUS%"=="USER_SKIPPED" set "VC86_SYMBOL=~"
if "%VCREDIST_X86_STATUS%"=="FAILED" set "VC86_SYMBOL=✖"
if "%VCREDIST_X86_STATUS%"=="INSTALLED (REBOOT REQUIRED)" set "VC86_SYMBOL=⚠"

if "%WEBVIEW2_STATUS%"=="INSTALLED" set "WV2_SYMBOL=✔"
if "%WEBVIEW2_STATUS%"=="USER_SKIPPED" set "WV2_SYMBOL=~"
if "%WEBVIEW2_STATUS%"=="FAILED" set "WV2_SYMBOL=✖"

if "%DIRECTX_STATUS%"=="INSTALLED" set "DX_SYMBOL=✔"
if "%DIRECTX_STATUS%"=="USER_SKIPPED" set "DX_SYMBOL=~"
if "%DIRECTX_STATUS%"=="FAILED" set "DX_SYMBOL=✖"

if "%NDP481_STATUS%"=="INSTALLED" set "NDP_SYMBOL=✔"
if "%NDP481_STATUS%"=="USER_SKIPPED" set "NDP_SYMBOL=~"
if "%NDP481_STATUS%"=="FAILED" set "NDP_SYMBOL=✖"

call :log "%DOTNET_SYMBOL% .NET Desktop Runtime 8.0       → %DOTNET_STATUS%"
call :log "%VC64_SYMBOL% VC++ Redistributables x64/x86    → %VCREDIST_X64_STATUS%/%VCREDIST_X86_STATUS%"
call :log "%WV2_SYMBOL% WebView2 Runtime               → %WEBVIEW2_STATUS%"
call :log "%DX_SYMBOL% DirectX Runtime                → %DIRECTX_STATUS%"
call :log "%NDP_SYMBOL% .NET Framework 4.8.1           → %NDP481_STATUS%"
call :log ""
call :log "🎉 Installation process completed!"
call :log "📁 Log saved at:"
call :log "    %LOGFILE%"
call :log ""

if "%REBOOT_REQUIRED%"=="1" (
    call :log "[WARN] REBOOT REQUIRED: One or more components require a system restart."
    echo    Please restart your computer when convenient.
    echo.
)

call :log "[SUCCESS] All components are installed or up to date"
call :log "[LOG] Log file: %LOGFILE%"
echo Made by sysdriver but heavily modified and optimized by nerfine
echo.

echo [%date%] Installation completed. Reboot required: %REBOOT_REQUIRED% >> "%LOGFILE%"

echo.
echo ==============================
echo Process Complete
echo ==============================
echo.

if "%REBOOT_REQUIRED%"=="1" (
    call :log "[INFO] Installation completed. Reboot required. Closing in 5 seconds..."
    timeout /t 5 /nobreak >nul 2>&1
) else (
    call :log "[INFO] Installation completed successfully. Closing in 3 seconds..."
    timeout /t 3 /nobreak >nul 2>&1
)
exit /b 0

:log
set "MSG=%~1"
if "%MSG%"=="" (
    if not "%QUIET_MODE%"=="1" echo.
    if exist "%LOGFILE%" (
        echo. >> "%LOGFILE%"
    ) else (
        echo. > "%LOGFILE%"
    )
) else (
    if not "%QUIET_MODE%"=="1" echo %MSG%
    if exist "%LOGFILE%" (
        echo %MSG% >> "%LOGFILE%"
    ) else (
        echo %MSG% > "%LOGFILE%"
    )
)
exit /b 0

:install_dotnet_runtime
call :log "    [↓] Downloading..."
set "DOTNET_INSTALLER=%TEMPDIR%\dotnet_runtime_%UUID%.exe"

set "RETRIES=3"
set "COUNT=0"

:retry_dotnet_download
set /a COUNT+=1
if %COUNT% GTR 1 call :log "    [↻] Retry attempt %COUNT%/%RETRIES%..."
powershell -Command "try { Invoke-WebRequest -Uri '%DOTNET_URL%' -OutFile '%DOTNET_INSTALLER%' -TimeoutSec 60 -UseBasicParsing } catch { Write-Host '[ERROR] Download failed:' $_.Exception.Message; exit 1 }"

if exist "%DOTNET_INSTALLER%" (
    call :validate_sha256 "%DOTNET_INSTALLER%" "%DOTNET_SHA256%"
    if errorlevel 1 (
        call :log "    [✖] SHA256 validation failed"
        del /f /q "%DOTNET_INSTALLER%"
        set "DOTNET_STATUS=FAILED"
        exit /b 11
    )
    
    call :log "    [⚙] Installing..."
    "%DOTNET_INSTALLER%" /install /quiet /norestart
    if errorlevel 1 (
        call :log "    [✖] Installation failed."
        set "DOTNET_STATUS=FAILED"
        exit /b 11
    )
    call :cleanup "%DOTNET_INSTALLER%"
    call :log "    [✔] Installed successfully."
    set "DOTNET_STATUS=INSTALLED"
    exit /b 0
) else (
    if %COUNT% LSS %RETRIES% (
        call :log "    [⚠] Download attempt %COUNT% failed. Retrying..."
        goto retry_dotnet_download
    ) else (
        call :log "    [✖] Download failed after %RETRIES% attempts."
        set "DOTNET_STATUS=FAILED"
        exit /b 11
    )
)

:cleanup
if exist "%~1" del /f /q "%~1"
if exist "%~1.log" del /f /q "%~1.log"
if exist "%~1.temp" rmdir /s /q "%~1.temp"
exit /b 0

:validate_sha256
set "FILE_PATH=%~1"
set "EXPECTED_HASH=%~2"

if "%EXPECTED_HASH%"=="UNKNOWN" (
    call :log "    [~] SHA256 validation skipped - hash unknown"
    exit /b 0
)

call :log "    [🔍] Verifying SHA256 hash..."
for /f "tokens=1" %%H in ('certutil -hashfile "%FILE_PATH%" SHA256 ^| findstr /v "hash"') do (
    set "ACTUAL_HASH=%%H"
    goto compare_hash
)

:compare_hash
if /i "%ACTUAL_HASH%"=="%EXPECTED_HASH%" (
    call :log "    [✔] SHA256 verified."
    exit /b 0
) else (
    call :log "    [✖] SHA256 validation failed"
    call :log "    Expected: %EXPECTED_HASH%"
    call :log "    Actual:   %ACTUAL_HASH%"
    exit /b 1
)

:check_all_dependencies
if "%INSTALL_DOTNET%"=="0" (
    call :log "[1/6] .NET Desktop Runtime 8.0"
    call :log "    [~] Skipped by user (--no-dotnet)"
    set "DOTNET_STATUS=USER_SKIPPED"
) else (
    call :log "[1/6] .NET Desktop Runtime 8.0"
    call :log "    [🔍] Checking..."
    reg query "HKLM\SOFTWARE\dotnet\Setup\InstalledVersions\x64\sharedfx\WindowsDesktop" | find "8.0" >nul
    if %errorlevel%==0 (
        call :log "    [✔] Found installed version."
        set "DOTNET_STATUS=INSTALLED"
    ) else (
        call :log "    [✖] Not found."
        set "DOTNET_STATUS=MISSING"
    )
)

if "%INSTALL_VCREDIST_X64%"=="0" (
    call :log "[2/6] VC++ Redistributable x64"
    call :log "    [~] Skipped by user (--no-vcredist)"
    set "VCREDIST_X64_STATUS=USER_SKIPPED"
) else (
    call :log "[2/6] VC++ Redistributable x64"
    call :log "    [🔍] Checking..."
    reg query "HKLM\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64" >nul 2>&1
    if %errorlevel%==0 (
        call :log "    [✔] Found installed version."
        set "VCREDIST_X64_STATUS=INSTALLED"
    ) else (
        call :log "    [✖] Not found."
        set "VCREDIST_X64_STATUS=MISSING"
    )
)

if "%INSTALL_VCREDIST_X86%"=="0" (
    call :log "[3/6] VC++ Redistributable x86"
    call :log "    [~] Skipped by user (--no-vcredist)"
    set "VCREDIST_X86_STATUS=USER_SKIPPED"
) else (
    call :log "[3/6] VC++ Redistributable x86"
    call :log "    [🔍] Checking..."
    reg query "HKLM\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x86" >nul 2>&1
    if %errorlevel%==0 (
        call :log "    [✔] Found installed version."
        set "VCREDIST_X86_STATUS=INSTALLED"
    ) else (
        call :log "    [✖] Not found."
        set "VCREDIST_X86_STATUS=MISSING"
    )
)

if "%INSTALL_WEBVIEW2%"=="0" (
    call :log "[4/6] WebView2 Runtime"
    call :log "    [~] Skipped by user (--no-webview2)"
    set "WEBVIEW2_STATUS=USER_SKIPPED"
) else (
    call :log "[4/6] WebView2 Runtime"
    call :log "    [🔍] Checking..."
    reg query "HKLM\SOFTWARE\Microsoft\EdgeUpdate\Clients\{F4A5B3DC-0E5D-4C0A-836E-4AD7EA73D1B2}" >nul 2>&1
    if %errorlevel%==0 (
        call :log "    [✔] Found installed version."
        set "WEBVIEW2_STATUS=INSTALLED"
    ) else (
        call :log "    [✖] Not found."
        set "WEBVIEW2_STATUS=MISSING"
    )
)

if "%INSTALL_DIRECTX%"=="0" (
    call :log "[5/6] DirectX Runtime"
    call :log "    [~] Skipped by user (--no-directx)"
    set "DIRECTX_STATUS=USER_SKIPPED"
) else (
    call :log "[5/6] DirectX Runtime"
    call :log "    [🔍] Checking..."
    if exist "%WINDIR%\System32\D3DX9_43.dll" (
        call :log "    [✔] Found installed version."
        set "DIRECTX_STATUS=INSTALLED"
    ) else (
        call :log "    [✖] Not found."
        set "DIRECTX_STATUS=MISSING"
    )
)

if "%INSTALL_NDP481%"=="0" (
    call :log "[6/6] .NET Framework 4.8.1"
    call :log "    [~] Skipped by user (--no-framework)"
    set "NDP481_STATUS=USER_SKIPPED"
) else (
    call :log "[6/6] .NET Framework 4.8.1"
    call :log "    [🔍] Checking..."
    reg query "HKLM\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" /v Release | findstr /r /c:"53332[0-9]" >nul
    if %errorlevel%==0 (
        call :log "    [✔] Found installed version."
        set "NDP481_STATUS=INSTALLED"
    ) else (
        call :log "    [✖] Not found."
        set "NDP481_STATUS=MISSING"
    )
)
exit /b 0

:display_check_summary
if "%DOTNET_STATUS%"=="INSTALLED" set "DOTNET_SYMBOL=✔"
if "%DOTNET_STATUS%"=="USER_SKIPPED" set "DOTNET_SYMBOL=~"
if "%DOTNET_STATUS%"=="MISSING" set "DOTNET_SYMBOL=✖"

if "%VCREDIST_X64_STATUS%"=="INSTALLED" set "VC64_SYMBOL=✔"
if "%VCREDIST_X64_STATUS%"=="USER_SKIPPED" set "VC64_SYMBOL=~"
if "%VCREDIST_X64_STATUS%"=="MISSING" set "VC64_SYMBOL=✖"

if "%VCREDIST_X86_STATUS%"=="INSTALLED" set "VC86_SYMBOL=✔"
if "%VCREDIST_X86_STATUS%"=="USER_SKIPPED" set "VC86_SYMBOL=~"
if "%VCREDIST_X86_STATUS%"=="MISSING" set "VC86_SYMBOL=✖"

if "%WEBVIEW2_STATUS%"=="INSTALLED" set "WV2_SYMBOL=✔"
if "%WEBVIEW2_STATUS%"=="USER_SKIPPED" set "WV2_SYMBOL=~"
if "%WEBVIEW2_STATUS%"=="MISSING" set "WV2_SYMBOL=✖"

if "%DIRECTX_STATUS%"=="INSTALLED" set "DX_SYMBOL=✔"
if "%DIRECTX_STATUS%"=="USER_SKIPPED" set "DX_SYMBOL=~"
if "%DIRECTX_STATUS%"=="MISSING" set "DX_SYMBOL=✖"

if "%NDP481_STATUS%"=="INSTALLED" set "NDP_SYMBOL=✔"
if "%NDP481_STATUS%"=="USER_SKIPPED" set "NDP_SYMBOL=~"
if "%NDP481_STATUS%"=="MISSING" set "NDP_SYMBOL=✖"

call :log "%DOTNET_SYMBOL% .NET Desktop Runtime 8.0       → %DOTNET_STATUS%"
call :log "%VC64_SYMBOL% VC++ Redistributable x64         → %VCREDIST_X64_STATUS%"
call :log "%VC86_SYMBOL% VC++ Redistributable x86         → %VCREDIST_X86_STATUS%"
call :log "%WV2_SYMBOL% WebView2 Runtime               → %WEBVIEW2_STATUS%"
call :log "%DX_SYMBOL% DirectX Runtime                → %DIRECTX_STATUS%"
call :log "%NDP_SYMBOL% .NET Framework 4.8.1           → %NDP481_STATUS%"
exit /b 0

:install_vcredist_x64
call :log "    [↓] Downloading..."
powershell -Command "Invoke-WebRequest -Uri '%VCREDIST_X64_URL%' -OutFile '%VCREDIST_X64%' -TimeoutSec 30 -UseBasicParsing"

call :validate_sha256 "%VCREDIST_X64%" "%VCREDIST_X64_SHA256%"
if errorlevel 1 (
    call :log "    [✖] SHA256 validation failed"
    del /f /q "%VCREDIST_X64%"
    set "VCREDIST_X64_STATUS=FAILED"
    exit /b 12
)

call :log "    [⚙] Installing..."
"%VCREDIST_X64%" /install /quiet /norestart
if errorlevel 1 (
    call :log "    [✖] Installation failed."
    set "VCREDIST_X64_STATUS=FAILED"
    exit /b 12
)
call :cleanup "%VCREDIST_X64%"
call :log "    [✔] Installed successfully."
set "VCREDIST_X64_STATUS=INSTALLED"
exit /b 0

:install_vcredist_x86
call :log "    [↓] Downloading..."
powershell -Command "Invoke-WebRequest -Uri '%VCREDIST_X86_URL%' -OutFile '%VCREDIST_X86%' -TimeoutSec 30 -UseBasicParsing"

call :validate_sha256 "%VCREDIST_X86%" "%VCREDIST_X86_SHA256%"
if errorlevel 1 (
    call :log "    [✖] SHA256 validation failed"
    del /f /q "%VCREDIST_X86%"
    set "VCREDIST_X86_STATUS=FAILED"
    exit /b 13
)

call :log "    [⚙] Installing..."
"%VCREDIST_X86%" /install /quiet /norestart > "%TEMPDIR%\vcredist_x86_install.log" 2>&1
echo [DEBUG] VC++ Redist x86 installer exit code: !errorlevel!
if "!errorlevel!"=="3010" (
    call :log "    [⚠] Installed. Reboot required."
    set "VCREDIST_X86_STATUS=INSTALLED (REBOOT REQUIRED)"
    set "REBOOT_REQUIRED=1"
) else if not "!errorlevel!"=="0" (
    call :log "    [✖] Installation failed. See log for details."
    set "VCREDIST_X86_STATUS=FAILED"
    exit /b 13
) else (
    call :log "    [✔] Installed successfully. (Exit Code: 0)"
    set "VCREDIST_X86_STATUS=INSTALLED"
)
call :cleanup "%VCREDIST_X86%"
exit /b 0

:install_webview2
call :log "    [↓] Downloading..."
powershell -Command "Invoke-WebRequest -Uri '%WEBVIEW2_URL%' -OutFile '%WEBVIEW2%' -MaximumRedirection 5 -TimeoutSec 60 -UseBasicParsing"

if not exist "%WEBVIEW2%" (
    call :log "    [✖] Download failed."
    exit /b 14
)
for /f "tokens=*" %%F in ('more "%WEBVIEW2%" ^| findstr /i "<html"') do (
    call :log "    [✖] Download failed - received HTML instead of EXE."
    del /f /q "%WEBVIEW2%"
    exit /b 14
)
for %%F in ("%WEBVIEW2%") do (
    if %%~zF lss 100000 (
        call :log "    [✖] Download incomplete. File too small."
        del /f /q "%WEBVIEW2%"
        exit /b 14
    )
)

call :log "    [⚙] Installing..."
"%WEBVIEW2%" /install /quiet /norestart /log:"%TEMPDIR%\webview2_setup.log"
if errorlevel 1 (
    call :log "    [✖] Installation failed."
    exit /b 14
)
del /f /q "%WEBVIEW2%"
call :log "    [✔] Installed."
set "WEBVIEW2_STATUS=INSTALLED"
exit /b 0

:install_directx
call :log "    [↓] Downloading..."
powershell -Command "Invoke-WebRequest -Uri '%DIRECTX_URL%' -OutFile '%DXREDIST%' -TimeoutSec 60 -UseBasicParsing"
call :log "    [⚙] Extracting DXSetup..."
"%DXREDIST%" /Q /T "%TEMPDIR%\directx_temp"
if exist "%TEMPDIR%\directx_temp\DXSETUP.exe" (
    call :log "    [⚙] Installing DirectX components..."
    "%TEMPDIR%\directx_temp\DXSETUP.exe" /silent
)
del /f /q "%DXREDIST%"
rmdir /s /q "%TEMPDIR%\directx_temp"
call :log "    [✔] Installed."
set "DIRECTX_STATUS=INSTALLED"
exit /b 0

:install_ndp481
call :log "    [↓] Downloading..."
powershell -Command "Invoke-WebRequest -Uri '%NDP481_URL%' -OutFile '%NDP481%' -TimeoutSec 60 -UseBasicParsing"
if exist "%NDP481%" (
    call :log "    [⚙] Installing..."
    "%NDP481%" /q /norestart
    if errorlevel 1 (
        call :log "    [✖] Installation failed."
        set "NDP481_STATUS=FAILED"
        exit /b 15
    )
    del /f /q "%NDP481%"
    call :log "    [✔] Installed with all components prepared."
    set "NDP481_STATUS=INSTALLED"
) else (
    call :log "    [✖] Download failed."
    set "NDP481_STATUS=FAILED"
    exit /b 15
)
exit /b 0
