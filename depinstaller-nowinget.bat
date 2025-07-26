@echo off
setlocal enabledelayedexpansion

set "QUIETMODE=0"
if /i "%~1"=="--quiet" set "QUIETMODE=1"

REM Ensure admin rights
net session >nul 2>&1
if !errorlevel! NEQ 0 (
    powershell -Command "Start-Process '%~f0' -Verb runAs"
    exit /b
)

REM Use TEMP\batch_installer for temp files and logs
set "TEMPDIR=%TEMP%\batch_installer"
if not exist "%TEMPDIR%" mkdir "%TEMPDIR%"

REM Set up logging
for /f %%A in ('powershell -NoProfile -Command "[datetime]::Now.ToString(\"yyyyMMdd_HHmmss\")"') do set "LOGSTAMP=%%A"
set "LOGFILE=%TEMPDIR%\depinstaller_%LOGSTAMP%.log"
echo Logging to "%LOGFILE%"
call :main >> "%LOGFILE%" 2>&1
exit /b

:main

echo.
echo ==============================
echo   Bunni Dependency Installer
echo ==============================
echo.

REM Generate GUID without braces
for /f %%A in ('powershell -NoProfile -Command "[guid]::NewGuid().ToString('N')"') do set "UUID=%%A"
set "VCREDIST_X64=%TEMPDIR%\vc_redist_x64_%UUID%.exe"
set "VCREDIST_X86=%TEMPDIR%\vc_redist_x86_%UUID%.exe"
set "WEBVIEW2=%TEMPDIR%\webview2_%UUID%.exe"
set "DXREDIST=%TEMPDIR%\directx_redist_%UUID%.exe"
set "NDP481=%TEMPDIR%\ndp481_%UUID%.exe"

echo.
echo ==============================
echo Installing required components
echo ==============================
echo.

REM 1. .NET Desktop Runtime 8.0
echo [STEP 1/6] Checking .NET Desktop Runtime 8.0...
reg query "HKLM\SOFTWARE\dotnet\Setup\InstalledVersions\x64\sharedfx\WindowsDesktop" | find "8.0" >nul
if %errorlevel%==0 (
    echo [1/6] .NET Desktop Runtime 8.0 is already installed. Skipping.
    set "DOTNET_STATUS=SKIPPED"
) else (
    set "DOTNET_EXE=%TEMPDIR%\windowsdesktop-runtime-8.0-latest-win-x64.exe"
    if exist "%DOTNET_EXE%" (
        echo [1/6] Found existing .NET Desktop Runtime 8.0 installer: "%DOTNET_EXE%"
    ) else (
        echo [1/6] Downloading .NET Desktop Runtime 8.0...
        set "DOTNET_URL="
        for /f "usebackq delims=" %%A in (`powershell -NoProfile -Command ^
            "$json = Invoke-RestMethod 'https://dotnetcli.blob.core.windows.net/dotnet/release-metadata/8.0/releases.json';" ^
            "$latest = $json.releases | Where-Object { $_.release.version -match '^8\.' } | Sort-Object { [version]$_.release.version } -Descending | Select-Object -First 1;" ^
            "$url = $latest.windowsdesktop.runtime.files | Where-Object { $_.rid -eq 'win-x64' -and $_.name -like '*.exe' } | Select-Object -First 1 -ExpandProperty url;" ^
            "if (-not [string]::IsNullOrWhiteSpace($url)) { Write-Output $url }"` ) do (
            set "DOTNET_URL=%%A"
        )

        setlocal enabledelayedexpansion
        echo(!DOTNET_URL!> "%TEMPDIR%\dotnet_url.txt"
        endlocal

        set /p DOTNET_URL=<"%TEMPDIR%\dotnet_url.txt"
        del "%TEMPDIR%\dotnet_url.txt"
    )

    if "%DOTNET_URL%"=="" (
        echo [WARN] Could not determine latest .NET 8.0 Desktop Runtime from metadata.
        echo [INFO] Using fallback URL...
        set "DOTNET_URL=https://download.visualstudio.microsoft.com/download/pr/5b383ad8-c06a-49ff-949a-3165c51cc67e/e36f20ebfc380b29d4fa39d624013a58/windowsdesktop-runtime-8.0.0-win-x64.exe"
    )

    echo [INFO] Latest .NET Desktop Runtime 8.0 x64 URL: %DOTNET_URL%
    if not exist "%DOTNET_EXE%" (
        powershell -Command "Invoke-WebRequest -Uri '%DOTNET_URL%' -OutFile '%DOTNET_EXE%' -TimeoutSec 60"
        if not exist "%DOTNET_EXE%" (
            echo [ERROR] .NET Desktop Runtime 8.0 installer not downloaded.
            set "DOTNET_STATUS=FAILED"
            goto :continue_installs
        )
    )
    "%DOTNET_EXE%" /install /quiet /norestart
    if errorlevel 1 (
        echo [ERROR] Failed to install .NET Desktop Runtime 8.0.
        set "DOTNET_STATUS=FAILED"
        goto :continue_installs
    )
    del /f /q "%DOTNET_EXE%"
    set "DOTNET_STATUS=INSTALLED"
    echo [OK] .NET Desktop Runtime 8.0 installed.
)

:continue_installs

REM 2. VC++ Redist x64
echo [STEP 2/6] Checking VC++ Redist x64...
reg query "HKLM\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64" >nul 2>&1
if %errorlevel%==0 (
    echo [2/6] VC++ Redist x64 already installed. Skipping.
) else (
    echo [2/6] Downloading VC++ Redist x64...
    powershell -Command "Invoke-WebRequest -Uri 'https://aka.ms/vs/17/release/vc_redist.x64.exe' -OutFile '%VCREDIST_X64%' -TimeoutSec 30"
    echo [2/6] Installing VC++ Redist x64...
    "%VCREDIST_X64%" /install /quiet /norestart
    if errorlevel 1 (
        echo [ERROR] Failed to install VC++ Redist x64.
        exit /b 1
    )
    call :cleanup "%VCREDIST_X64%"
    echo [OK] VC++ Redist x64 installed.
)

REM 3. VC++ Redist x86
echo [STEP 3/6] Checking VC++ Redist x86...
reg query "HKLM\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x86" >nul 2>&1
if %errorlevel%==0 (
    echo [3/6] VC++ Redist x86 already installed. Skipping.
) else (
    echo [3/6] Downloading VC++ Redist x86...
    powershell -Command "Invoke-WebRequest -Uri 'https://aka.ms/vs/17/release/vc_redist.x86.exe' -OutFile '%VCREDIST_X86%' -TimeoutSec 30"
    echo [3/6] Installing VC++ Redist x86...
    "%VCREDIST_X86%" /install /quiet /norestart > "%TEMPDIR%\vcredist_x86_install.log" 2>&1
    echo [DEBUG] VC++ Redist x86 installer exit code: !errorlevel!
    if "!errorlevel!"=="3010" (
        echo [WARN] VC++ Redist x86 installed, but a reboot is required to complete installation.
    ) else if not "!errorlevel!"=="0" (
        echo [ERROR] Failed to install VC++ Redist x86. See "%TEMPDIR%\vcredist_x86_install.log" for details.
        exit /b 1
    )
    call :cleanup "%VCREDIST_X86%"
    echo [OK] VC++ Redist x86 installed.
)

REM 4. WebView2 Runtime
echo [STEP 4/6] Checking WebView2 Runtime...
reg query "HKLM\SOFTWARE\Microsoft\EdgeUpdate\Clients\{F4A5B3DC-0E5D-4C0A-836E-4AD7EA73D1B2}" >nul 2>&1
if %errorlevel%==0 (
    echo [4/6] WebView2 Runtime already installed. Skipping.
) else (
    echo [4/6] Downloading WebView2 Runtime...
    powershell -Command "Invoke-WebRequest -Uri 'https://go.microsoft.com/fwlink/p/?LinkId=2124703' -OutFile '%WEBVIEW2%' -TimeoutSec 60"
    if not exist "%WEBVIEW2%" (
        echo [ERROR] WebView2 installer not downloaded.
        set "WEBVIEW2_STATUS=FAILED"
        goto :continue_installs2
    )
    REM ...rest of your checks and install...
    echo [4/6] Installing WebView2 Runtime...
    "%WEBVIEW2%" /install /quiet /norestart /log:"%TEMPDIR%\webview2_setup.log"
    if errorlevel 1 (
        echo [ERROR] Failed to install WebView2 Runtime.
        set "WEBVIEW2_STATUS=FAILED"
        goto :continue_installs2
    )
    del /f /q "%WEBVIEW2%"
    echo [OK] WebView2 Runtime installed.
)
:continue_installs2

REM 5. DirectX Runtime
echo [STEP 5/6] Checking DirectX Runtime...
if exist "%WINDIR%\System32\D3DX9_43.dll" (
    echo [5/6] DirectX Runtime already present. Skipping.
) else (
    echo [5/6] Downloading DirectX Runtime...
    powershell -Command "Invoke-WebRequest -Uri 'https://download.microsoft.com/download/1/6/1/161a7e5d-9d07-4f31-9276-c44a69c6f0e3/directx_Jun2010_redist.exe' -OutFile '%DXREDIST%' -TimeoutSec 60"
    echo [5/6] Installing DirectX Runtime...
    "%DXREDIST%" /Q /T "%TEMPDIR%\directx_temp"
    if exist "%TEMPDIR%\directx_temp\DXSETUP.exe" (
        "%TEMPDIR%\directx_temp\DXSETUP.exe" /silent
    )
    del /f /q "%DXREDIST%"
    rmdir /s /q "%TEMPDIR%\directx_temp"
    echo [OK] DirectX Runtime installed.
)

REM 6. .NET Framework 4.8.1 (Win10/11)
echo [STEP 6/6] Checking .NET Framework 4.8.1...
reg query "HKLM\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" /v Release | findstr /r /c:"53332[0-9]" >nul
if %errorlevel%==0 (
    echo [6/6] .NET Framework 4.8.1 already installed. Skipping.
) else (
    echo [6/6] Downloading .NET Framework 4.8.1...
    powershell -Command "Invoke-WebRequest -Uri 'https://go.microsoft.com/fwlink/?linkid=2088631' -OutFile '%NDP481%' -TimeoutSec 60"
    if exist "%NDP481%" (
        echo [6/6] Installing .NET Framework 4.8.1...
        "%NDP481%" /q /norestart
        if errorlevel 1 (
            echo [ERROR] Failed to install .NET Framework 4.8.1.
            exit /b 1
        )
        del /f /q "%NDP481%"
        echo [OK] .NET Framework 4.8.1 installed.
    ) else (
        echo [ERROR] Failed to download %NDP481%. Please check your internet connection or download manually from:
        echo https://dotnet.microsoft.com/en-us/download/dotnet-framework/net481
        pause
        exit /b 2
    )
)

echo.
echo ==============================
echo Installation Summary
echo ==============================
echo .NET Desktop Runtime 8.0 ....... %DOTNET_STATUS%
echo.
echo ✅ Depinstaller ran successfully! (made by sysdriver but heavily modified and optimized by nerfine)
echo Log file: "%LOGFILE%"
if not "%QUIETMODE%"=="1" pause
exit

:cleanup
if exist "%~1" del /f /q "%~1"
exit /b 0