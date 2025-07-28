@echo off
setlocal EnableDelayedExpansion

REM Define log function first
goto :main

:log
set "MSG=%~1"
if "%MSG%"=="" (
    echo.
    if exist "%LOGFILE%" (
        echo. >> "%LOGFILE%"
    ) else (
        echo. > "%LOGFILE%"
    )
) else (
    echo %MSG%
    if exist "%LOGFILE%" (
        echo %MSG% >> "%LOGFILE%"
    ) else (
        echo %MSG% > "%LOGFILE%"
    )
)
exit /b 0

:main
REM Set up logging
set "TEMPDIR=%TEMP%\webview2_fix"
if not exist "%TEMPDIR%" mkdir "%TEMPDIR%"

if exist "%TEMPDIR%\webview2_fix_*.log" (
    echo Cleaning up previous log files...
    del /f /q "%TEMPDIR%\webview2_fix_*.log" >nul 2>&1
)

for /f %%A in ('powershell -NoProfile -Command "[datetime]::Now.ToString(\"yyyyMMdd_HHmmss\")"') do set "LOGSTAMP=%%A"
set "LOGFILE=%TEMPDIR%\webview2_fix_%LOGSTAMP%.log"

echo Logging to "%LOGFILE%"

REM Check for administrator privileges and auto-elevate if needed
echo [INFO] Checking administrator privileges...
net session >nul 2>&1
if %errorlevel% NEQ 0 (
    echo.
    echo [ERROR] ADMINISTRATOR PRIVILEGES REQUIRED
    echo ════════════════════════════════════════════════════════
    echo This script requires administrator privileges to copy files to Program Files.
    echo.
    echo Please run this script as Administrator:
    echo 1. Right-click on the script file
    echo 2. Select "Run as administrator"
    echo 3. Click "Yes" in the UAC prompt
    echo.
    echo The script will now attempt to request elevation...
    echo ════════════════════════════════════════════════════════
    echo.
    
    call :log "Requesting administrator privileges..."
    echo [INFO] Attempting UAC elevation...
    echo [INFO] Please click "Yes" in the UAC prompt that appears...
    powershell -Command "Start-Process '%~f0' -Verb runAs -Wait" 2>nul
    echo [DEBUG] PowerShell elevation command completed with errorlevel: !errorlevel!
    call :log "[DEBUG] PowerShell elevation command completed with errorlevel: !errorlevel!"
    if !errorlevel! NEQ 0 (
        echo.
        echo [ERROR] UAC elevation failed ^(Error: !errorlevel!^)
        echo [INFO] This could be due to:
        echo   User declined UAC prompt
        echo   UAC is disabled or restricted
        echo   Group Policy restrictions
        echo.
        echo [ERROR] Cannot continue without administrator privileges.
        echo Please run this script as administrator and try again.
        call :log "[ERROR] Failed to elevate privileges. Exiting."
        pause
        exit /b 1
    )
    exit /b
)

set "ADMIN_MODE=1"

call :log "============================================"
call :log "Bunni WebView2 Workaround - Automated Script"
call :log "            Made by nerfine                  "
call :log "Running as Administrator"
call :log "============================================"
call :log ""

echo ============================================
echo Bunni WebView2 Workaround - Automated Script
echo             Made by nerfine
echo Running as Administrator
echo ============================================
echo.
echo 📖 SCRIPT PURPOSE:
echo This script fixes Bunni white screen issues by creating a WebView2
echo workaround using Microsoft Edge browser engine.
echo.
echo 🔍 WHAT IT DOES:
echo 1. Detects Microsoft Edge installation on your system
echo 2. Creates EdgeWebView folder as WebView2 replacement
echo 3. Copies Edge files to provide WebView2 functionality
echo 4. Enables Bunni to display web content properly
echo.
echo 🚀 Starting process...
echo ============================================

call :log "[INFO] Checking for Microsoft Edge installation..."
echo [INFO] Checking for Microsoft Edge installation...
call :log ""

REM Check all possible Edge locations one by one
set "SOURCE_FOUND="
set "SOURCE_PATH="

echo [DEBUG] Starting simplified Edge detection...
call :log "[DEBUG] Starting simplified Edge detection..."

REM Simplified Method: Use where command to find Edge
echo [DEBUG] Using where command to locate msedge.exe...
call :log "    Using where command to locate msedge.exe..."

where msedge.exe >nul 2>&1
if %errorlevel% EQU 0 (
    echo [DEBUG] msedge.exe found in PATH
    call :log "    [✔] msedge.exe found in PATH"
    for /f "tokens=*" %%i in ('where msedge.exe 2^>nul') do (
        echo [DEBUG] Edge location: %%i
        call :log "    Edge location: %%i"
        set "EDGE_EXE=%%i"
        goto extract_path
    )
) else (
    echo [DEBUG] msedge.exe not in PATH, checking standard locations...
    call :log "    msedge.exe not in PATH, checking standard locations..."
)

REM Fallback: Check standard locations with simple existence test
echo [DEBUG] Checking x86 location...
call :log "[DEBUG] About to check x86 location"
set "EDGE_X86=C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
echo [DEBUG] Path to check: %EDGE_X86%
call :log "[DEBUG] Path variable set successfully"

REM Use a more robust file existence check
echo [DEBUG] Testing file existence with dir command...
dir "%EDGE_X86%" >nul 2>&1
echo [DEBUG] Dir command returned errorlevel: %errorlevel%

if errorlevel 1 goto check_x86_root
echo [DEBUG] Found in x86 Application location
echo [SUCCESS] Found Microsoft Edge at: C:\Program Files (x86)\Microsoft\Edge\Application
call :log "Found Microsoft Edge in x86 Application location"
set "SOURCE_FOUND=1"
set "SOURCE_PATH=C:\Program Files (x86)\Microsoft\Edge\Application"
goto edge_found

:check_x86_root
echo [DEBUG] Not found in x86 Application, checking x86 root...
set "EDGE_X86_ROOT=C:\Program Files (x86)\Microsoft\Edge\msedge.exe"
dir "%EDGE_X86_ROOT%" >nul 2>&1
if errorlevel 1 goto check_pf_location
echo [DEBUG] Found in x86 root location
echo [SUCCESS] Found Microsoft Edge at: C:\Program Files (x86)\Microsoft\Edge
call :log "Found Microsoft Edge in x86 root location"
set "SOURCE_FOUND=1"
set "SOURCE_PATH=C:\Program Files (x86)\Microsoft\Edge"
goto edge_found

:check_pf_location
echo [DEBUG] Not found in x86 locations
call :log "Not found in x86 locations"

echo [DEBUG] Checking regular Program Files Application...
set "EDGE_PF=C:\Program Files\Microsoft\Edge\Application\msedge.exe"
echo [DEBUG] Path to check: %EDGE_PF%

REM Use a more robust file existence check
echo [DEBUG] Testing Program Files Application existence with dir command...
dir "%EDGE_PF%" >nul 2>&1
set "EXIST_RESULT2=%errorlevel%"
echo [DEBUG] Program Files Application dir command returned: %EXIST_RESULT2%

if %EXIST_RESULT2% EQU 0 (
    echo [DEBUG] Found in regular Program Files Application
    echo [SUCCESS] Found Microsoft Edge at: C:\Program Files\Microsoft\Edge\Application
    call :log "Found Microsoft Edge in regular Program Files Application"
    set "SOURCE_FOUND=1"
    set "SOURCE_PATH=C:\Program Files\Microsoft\Edge\Application"
    goto edge_found
) else (
    echo [DEBUG] Not found in regular Program Files Application
    call :log "Not found in regular Program Files Application"
)

echo [DEBUG] Checking regular Program Files root...
set "EDGE_PF_ROOT=C:\Program Files\Microsoft\Edge\msedge.exe"
dir "%EDGE_PF_ROOT%" >nul 2>&1
if %errorlevel% EQU 0 (
    echo [DEBUG] Found in regular Program Files root
    echo [SUCCESS] Found Microsoft Edge at: C:\Program Files\Microsoft\Edge
    call :log "Found Microsoft Edge in regular Program Files root"
    set "SOURCE_FOUND=1"
    set "SOURCE_PATH=C:\Program Files\Microsoft\Edge"
    goto edge_found
) else (
    echo [DEBUG] Not found in regular Program Files root
    call :log "Not found in regular Program Files root"
)

echo [DEBUG] Edge not found, proceeding to reinstall method
call :log "    [INFO] Edge not found in standard locations, proceeding to reinstall method"
echo [INFO] Edge not found in standard locations, proceeding to reinstall method
goto edge_not_found

:extract_path
echo [DEBUG] Extracting path from: %EDGE_EXE%
for %%F in ("%EDGE_EXE%") do set "SOURCE_PATH=%%~dpF"
set "SOURCE_PATH=%SOURCE_PATH:~0,-1%"
echo [DEBUG] Extracted path: %SOURCE_PATH%
call :log "    [✔] Found Microsoft Edge at: %SOURCE_PATH%"
echo [SUCCESS] Found Microsoft Edge at: %SOURCE_PATH%
set "SOURCE_FOUND=1"
goto edge_found

:edge_not_found
echo [DEBUG] All Edge detection methods completed - none found
call :log "[DEBUG] All Edge detection methods completed - none found"

:edge_found
if not defined SOURCE_FOUND (
    call :log "    [✖] Microsoft Edge not found in any expected location."
    call :log "[INFO] Attempting Edge reinstall method..."
    echo [ERROR] Microsoft Edge not found in any expected location.
    echo Attempting Edge reinstall method...
    goto edge_reinstall_fallback
)

call :log "[SUCCESS] Edge found. Proceeding with copy method."
call :log ""

REM Close Edge processes to prevent file locks during copy
echo [INFO] Checking for running Edge processes...
call :log "[INFO] Checking for running Edge processes..."
tasklist /fi "imagename eq msedge.exe" 2>nul | find /i "msedge.exe" >nul
if %errorlevel% EQU 0 (
    echo [WARN] Edge processes are running. Attempting to close them...
    call :log "[WARN] Edge processes are running. Attempting to close them..."
    taskkill /f /im msedge.exe >nul 2>&1
    timeout /t 3 /nobreak >nul
    echo [INFO] Edge processes closed. Waiting 3 seconds before copy...
    call :log "[INFO] Edge processes closed. Waiting 3 seconds before copy..."
) else (
    echo [INFO] No Edge processes running.
    call :log "[INFO] No Edge processes running."
)

REM Set source and destination paths
set "SOURCE=%SOURCE_PATH%"
set "DEST=C:\Program Files (x86)\Microsoft\EdgeWebView"

call :log "[INFO] Source path set"
call :log "[INFO] Destination path set"
echo [INFO] Source: %SOURCE%
echo [INFO] Destination: %DEST%

REM Create destination directory if it doesn't exist
echo [DEBUG] Checking if Microsoft directory exists...
call :log "[DEBUG] Checking if Microsoft directory exists..."
if not exist "C:\Program Files (x86)\Microsoft\" (
    call :log "[INFO] Creating Microsoft directory..."
    echo [INFO] Creating Microsoft directory...
    mkdir "C:\Program Files (x86)\Microsoft\"
    if exist "C:\Program Files (x86)\Microsoft\" (
        call :log "[SUCCESS] Microsoft directory created successfully."
        echo [SUCCESS] Microsoft directory created successfully.
    ) else (
        call :log "[ERROR] Failed to create Microsoft directory."
        echo [ERROR] Failed to create Microsoft directory.
    )
) else (
    call :log "[INFO] Microsoft directory already exists."
    echo [INFO] Microsoft directory already exists.
)

REM Check if EdgeWebView already exists and remove it
echo [DEBUG] Checking if EdgeWebView folder already exists...
call :log "[DEBUG] Checking if EdgeWebView folder already exists..."
IF EXIST "%DEST%" (
    call :log "[INFO] EdgeWebView folder already exists. Removing it..."
    echo [INFO] EdgeWebView folder already exists. Removing it...
    echo [DEBUG] Attempting to remove with rmdir /S /Q...
    call :log "[DEBUG] Attempting to remove with rmdir /S /Q..."
    rmdir /S /Q "%DEST%" >nul 2>&1
    if exist "%DEST%" (
        call :log "[WARN] Could not remove existing folder. Trying takeown..."
        echo [WARN] Could not remove existing folder. Trying takeown...
        takeown /f "%DEST%" /r /d y >nul 2>&1
        icacls "%DEST%" /grant administrators:F /t >nul 2>&1
        rmdir /S /Q "%DEST%" >nul 2>&1
        if exist "%DEST%" (
            call :log "[ERROR] Still could not remove existing folder after takeown."
            echo [ERROR] Still could not remove existing folder after takeown.
        ) else (
            call :log "[SUCCESS] Existing folder removed after takeown."
            echo [SUCCESS] Existing folder removed after takeown.
        )
    ) else (
        call :log "[SUCCESS] Existing folder removed successfully."
        echo [SUCCESS] Existing folder removed successfully.
    )
) else (
    call :log "[INFO] EdgeWebView folder does not exist yet."
    echo [INFO] EdgeWebView folder does not exist yet.
)

call :log "[INFO] Copying Edge folder to EdgeWebView..."
echo [INFO] Copying Edge folder to EdgeWebView...
echo [INFO] This may take several minutes depending on system speed...
echo [DEBUG] Starting copy operation using xcopy with verbose output...
call :log "[DEBUG] Starting copy operation using xcopy with verbose output..."
call :log "[DEBUG] Running xcopy command with full file listing..."

REM Use xcopy with verbose output and progress indication
echo [INFO] Starting copy operation (this may take a few minutes)...
echo [DEBUG] Source path set
echo [DEBUG] Destination path set
call :log "[DEBUG] Source path set"
call :log "[DEBUG] Destination path set"

REM Create destination parent directory first
if not exist "%DEST%" (
    echo [DEBUG] Creating destination directory...
    call :log "[DEBUG] Creating destination directory..."
    mkdir "%DEST%" 2>nul
)

echo [DEBUG] Starting xcopy with full verbose output...
call :log "[DEBUG] Starting xcopy with full verbose output..."
xcopy "%SOURCE%" "%DEST%\" /E /I /H /Y /V /F
set "COPY_RESULT=%ERRORLEVEL%"
echo.
echo [DEBUG] Copy operation completed with errorlevel: %COPY_RESULT%
call :log "[DEBUG] Copy operation completed with errorlevel: %COPY_RESULT%"
echo [DEBUG] Checking destination folder contents...
call :log "[DEBUG] Checking destination folder contents..."

REM Show what was actually copied
if exist "%DEST%" (
    echo [DEBUG] Destination folder exists - listing contents:
    call :log "[DEBUG] Destination folder exists - listing contents:"
    dir "%DEST%" /b 2>nul | findstr /r "." >nul && (
        echo [DEBUG] Files found in destination:
        call :log "[DEBUG] Files found in destination:"
        for /f %%f in ('dir "%DEST%" /b 2^>nul') do (
            echo [DEBUG]   - %%f
            call :log "[DEBUG]   - %%f"
        )
    ) || (
        echo [DEBUG] No files found in destination folder
        call :log "[DEBUG] No files found in destination folder"
    )
) else (
    echo [DEBUG] Destination folder does not exist
    call :log "[DEBUG] Destination folder does not exist"
)

IF %COPY_RESULT% NEQ 0 (
    call :log "    [✖] Failed to copy Edge folder with xcopy. Error level: %COPY_RESULT%"
    echo [ERROR] Failed to copy Edge folder with xcopy. Error level: %COPY_RESULT%
    echo [INFO] Trying alternative copy method...
    call :log "[INFO] Trying robocopy as fallback..."
    
    REM Fallback to robocopy with minimal options
    robocopy "%SOURCE%" "%DEST%" /E /R:1 /W:1
    set "ROBOCOPY_RESULT=%ERRORLEVEL%"
    echo [DEBUG] Robocopy fallback completed with errorlevel: %ROBOCOPY_RESULT%
    call :log "[DEBUG] Robocopy fallback completed with errorlevel: %ROBOCOPY_RESULT%"
    
    IF %ROBOCOPY_RESULT% GEQ 8 (
        call :log "    [✖] Both copy methods failed. Proceeding to Edge reinstall method..."
        echo [ERROR] Both copy methods failed. Proceeding to Edge reinstall method...
        goto edge_reinstall_fallback
    ) else (
        call :log "    [✔] EdgeWebView folder created successfully via robocopy fallback."
        echo [SUCCESS] EdgeWebView folder created successfully via robocopy fallback.
    )
) else (
    call :log "    [✔] EdgeWebView folder created successfully via xcopy."
    echo [SUCCESS] EdgeWebView folder created successfully via xcopy.
)

REM Verify the copy worked
echo [DEBUG] Starting copy verification...
call :log "[DEBUG] Starting copy verification..."
call :log "[INFO] Verifying EdgeWebView copy..."
echo [DEBUG] Checking if msedge.exe exists in destination...
call :log "[DEBUG] Checking if msedge.exe exists in: %DEST%\msedge.exe"
if exist "%DEST%\msedge.exe" (
    call :log "    [✔] Verification successful. msedge.exe found in EdgeWebView."
    call :log "[SUCCESS] WebView2 workaround completed successfully."
    call :log "[INFO] EdgeWebView created at: %DEST%"
    echo [SUCCESS] WebView2 workaround completed successfully.
    echo [INFO] EdgeWebView created at: %DEST%
    echo [DEBUG] Verification successful - proceeding to success exit.
    call :log "[DEBUG] Verification successful - proceeding to success exit."
    goto success_exit
) else (
    call :log "    [✖] Verification failed. msedge.exe not found in EdgeWebView."
    call :log "[WARN] Copy may not have worked properly. Trying Edge reinstall method..."
    echo [WARN] Copy may not have worked properly. Trying Edge reinstall method...
    echo [DEBUG] Verification failed - checking what files were copied...
    call :log "[DEBUG] Verification failed - proceeding to fallback method."
    goto edge_reinstall_fallback
)

:edge_reinstall_fallback
call :log ""
call :log "════════════════════════════════════════════════════════"
call :log "🔄 Edge Reinstall Method"
call :log "════════════════════════════════════════════════════════"
call :log "[INFO] Trying Edge reinstall method..."
call :log "[INFO] This will download and reinstall Microsoft Edge, then copy it to EdgeWebView folder."

echo [INFO] Trying Edge reinstall method...
echo [INFO] This will download and reinstall Microsoft Edge, then copy it to EdgeWebView folder.
set "TEMP_DIR=%TEMP%\webview2_fix"
if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

set /p "CONFIRM_EDGE=Do you want to reinstall Edge to fix WebView2? (Y/N): "
call :log "[USER INPUT] Edge reinstall confirmation: %CONFIRM_EDGE%"

if /i not "%CONFIRM_EDGE%"=="Y" if /i not "%CONFIRM_EDGE%"=="YES" (
    call :log "[INFO] Edge reinstall skipped by user."
    echo [INFO] Edge reinstall skipped by user.
    goto manual_instructions
)

call :log "[INFO] Downloading Microsoft Edge installer..."
echo [INFO] Downloading Microsoft Edge installer...
set "EDGE_URL=https://go.microsoft.com/fwlink/?linkid=2108834&Channel=Stable&language=en"
set "EDGE_INSTALLER=%TEMP_DIR%\MicrosoftEdgeSetup.exe"

call :log "    Download URL: %EDGE_URL%"
call :log "    Installer path: %EDGE_INSTALLER%"

echo [INFO] Starting PowerShell download command...
call :log "[INFO] Starting PowerShell download command..."
powershell -Command "try { Write-Host '[DEBUG] Starting download...'; Invoke-WebRequest -Uri '%EDGE_URL%' -OutFile '%EDGE_INSTALLER%' -UseBasicParsing -TimeoutSec 120; Write-Host '[DEBUG] Download completed successfully' } catch { Write-Host '[ERROR] Edge download failed:' $_.Exception.Message; exit 1 }"
set "DOWNLOAD_RESULT=%errorlevel%"
echo [DEBUG] PowerShell download returned errorlevel: %DOWNLOAD_RESULT%
call :log "[DEBUG] PowerShell download returned errorlevel: %DOWNLOAD_RESULT%"

if exist "%EDGE_INSTALLER%" (
    call :log "    [✔] Edge installer downloaded successfully."
    call :log "[INFO] Installing Microsoft Edge..."
    echo [INFO] Installing Microsoft Edge...
    "%EDGE_INSTALLER%" /silent /install
    if !errorlevel! equ 0 (
        call :log "    [✔] Microsoft Edge installed successfully."
        call :log "[INFO] Waiting for installation to complete..."
        echo [SUCCESS] Microsoft Edge installed successfully.
        echo [INFO] Waiting for installation to complete...
        timeout /t 10 /nobreak >nul 2>&1
        
        REM Now try to copy Edge to EdgeWebView again
        call :log "[INFO] Attempting Edge to EdgeWebView copy after reinstall..."
        echo [INFO] Attempting Edge to EdgeWebView copy after reinstall...
        
        REM Re-check Edge locations after reinstall
        set "NEW_SOURCE="
        call :log "    Re-scanning Edge installation locations..."
        
        call :log "        Checking: C:\Program Files (x86)\Microsoft\Edge"
        if exist "C:\Program Files (x86)\Microsoft\Edge\msedge.exe" (
            call :log "        [✔] Found Edge after reinstall at: C:\Program Files (x86)\Microsoft\Edge"
            echo [INFO] Found Edge after reinstall at: C:\Program Files (x86)\Microsoft\Edge
            set "NEW_SOURCE=C:\Program Files (x86)\Microsoft\Edge"
            goto found_new_edge
        )
        
        call :log "        Checking: C:\Program Files\Microsoft\Edge"
        if exist "C:\Program Files\Microsoft\Edge\msedge.exe" (
            call :log "        [✔] Found Edge after reinstall at: C:\Program Files\Microsoft\Edge"
            echo [INFO] Found Edge after reinstall at: C:\Program Files\Microsoft\Edge
            set "NEW_SOURCE=C:\Program Files\Microsoft\Edge"
            goto found_new_edge
        )
        
        call :log "        Checking: %PROGRAMFILES%\Microsoft\Edge"
        if exist "%PROGRAMFILES%\Microsoft\Edge\msedge.exe" (
            call :log "        [✔] Found Edge after reinstall at: %PROGRAMFILES%\Microsoft\Edge"
            echo [INFO] Found Edge after reinstall at: %PROGRAMFILES%\Microsoft\Edge
            set "NEW_SOURCE=%PROGRAMFILES%\Microsoft\Edge"
            goto found_new_edge
        )
        
        call :log "        Checking: %PROGRAMFILES(X86)%\Microsoft\Edge"
        if exist "%PROGRAMFILES(X86)%\Microsoft\Edge\msedge.exe" (
            call :log "        [✔] Found Edge after reinstall at: %PROGRAMFILES(X86)%\Microsoft\Edge"
            echo [INFO] Found Edge after reinstall at: %PROGRAMFILES(X86)%\Microsoft\Edge
            set "NEW_SOURCE=%PROGRAMFILES(X86)%\Microsoft\Edge"
            goto found_new_edge
        )
        
        call :log "        Checking: %LOCALAPPDATA%\Microsoft\Edge\Application"
        if exist "%LOCALAPPDATA%\Microsoft\Edge\Application\msedge.exe" (
            call :log "        [✔] Found Edge after reinstall at: %LOCALAPPDATA%\Microsoft\Edge\Application"
            echo [INFO] Found Edge after reinstall at: %LOCALAPPDATA%\Microsoft\Edge\Application
            set "NEW_SOURCE=%LOCALAPPDATA%\Microsoft\Edge\Application"
            goto found_new_edge
        )
        
        :found_new_edge
        if defined NEW_SOURCE (
            call :log "[SUCCESS] Edge found after reinstall."
            call :log "    Source: !NEW_SOURCE!"
            set "DEST=C:\Program Files (x86)\Microsoft\EdgeWebView"
            call :log "    Destination: %DEST%"
            
            REM Remove existing EdgeWebView if present
            if exist "%DEST%" (
                call :log "[INFO] Removing existing EdgeWebView folder..."
                echo [INFO] Removing existing EdgeWebView folder...
                rmdir /S /Q "%DEST%" >nul 2>&1
                if exist "%DEST%" (
                    call :log "    [WARN] Standard removal failed. Using takeown..."
                    takeown /f "%DEST%" /r /d y >nul 2>&1
                    icacls "%DEST%" /grant administrators:F /t >nul 2>&1
                    rmdir /S /Q "%DEST%" >nul 2>&1
                )
            )
            
            call :log "[INFO] Copying reinstalled Edge to EdgeWebView..."
            echo [INFO] Copying reinstalled Edge to EdgeWebView...
            robocopy "!NEW_SOURCE!" "%DEST%" /E /NFL /NDL /NJH /NJS /nc /ns /np
            
            if exist "%DEST%\msedge.exe" (
                call :log "    [✔] Copy verification successful."
                call :log "[SUCCESS] EdgeWebView created successfully from reinstalled Edge!"
                call :log "[INFO] EdgeWebView location: %DEST%"
                echo [SUCCESS] EdgeWebView created successfully from reinstalled Edge!
                echo [INFO] EdgeWebView location: %DEST%
                call :log "[INFO] Cleaning up temporary files..."
                del /f /q "%EDGE_INSTALLER%" >nul 2>&1
                rmdir /s /q "%TEMP_DIR%" >nul 2>&1
                goto success_exit
            ) else (
                call :log "    [✖] Copy verification failed. msedge.exe not found."
                call :log "[ERROR] Failed to copy Edge after reinstall."
                echo [ERROR] Failed to copy Edge after reinstall.
                goto manual_instructions
            )
        ) else (
            call :log "[ERROR] Could not find Edge even after reinstall."
            echo [ERROR] Could not find Edge even after reinstall.
            goto manual_instructions
        )
    ) else (
        call :log "    [✖] Edge installation failed with error code: !errorlevel!"
        call :log "[ERROR] Edge installation failed."
        echo [ERROR] Edge installation failed with error code: !errorlevel!
        goto manual_instructions
    )
) else (
    call :log "    [✖] Failed to download Edge installer."
    call :log "[ERROR] Failed to download Edge installer."
    echo [ERROR] Failed to download Edge installer.
    goto manual_instructions
)

:manual_instructions
call :log ""
call :log "════════════════════════════════════════════════════════"
call :log "📋 Manual Instructions"
call :log "════════════════════════════════════════════════════════"
call :log "[ERROR] All automated methods failed. Providing manual instructions."

echo ════════════════════════════════════════════════════════
echo ❌ AUTOMATED METHOD FAILED - Manual Instructions Required
echo ════════════════════════════════════════════════════════
echo.
echo 📋 SUMMARY OF WHAT HAPPENED:
echo • Attempted to detect Microsoft Edge installation
echo • Tried automated download and installation methods
echo • Copy operations failed or Edge installation was unsuccessful
echo • Manual intervention is now required
echo.


goto final_exit

:success_exit
call :log ""
call :log "════════════════════════════════════════════════════════"
call :log "✅ Success"
call :log "════════════════════════════════════════════════════════"
call :log "[SUCCESS] WebView2 is now properly configured for Bunni."
call :log "[INFO] You can now try launching Bunni again."
call :log ""
call :log "📋 SUMMARY OF ACTIONS PERFORMED:"
call :log "════════════════════════════════════════════════════════"
call :log "✅ Microsoft Edge detected at: %SOURCE_PATH%"
call :log "✅ EdgeWebView folder created at: %DEST%"
call :log "✅ Edge files successfully copied to EdgeWebView location"
call :log "✅ Copy verification completed - msedge.exe found in EdgeWebView"
call :log ""
call :log "🔧 WHAT THIS FIXES:"
call :log "• Resolves Bunni white screen/blank window issues"
call :log "• Provides WebView2 runtime when standard installers fail"
call :log "• Uses Edge browser engine as WebView2 replacement"
call :log "• Enables Bunni to display web content properly"
call :log ""
call :log "📁 FILES CREATED:"
call :log "• EdgeWebView folder: %DEST%"
call :log "• All Edge browser files copied for WebView2 compatibility"
call :log ""
call :log "🚀 NEXT STEPS:"
call :log "1. Launch Bunni application"
call :log "2. Check if white screen issue is resolved"
call :log "3. If issues persist, restart your computer and try again"
call :log ""
call :log "📁 Log saved at:"
call :log "    %LOGFILE%"

echo ════════════════════════════════════════════════════════
echo ✅ SUCCESS - WebView2 Workaround Complete!
echo ════════════════════════════════════════════════════════
echo.
echo 📋 SUMMARY OF ACTIONS PERFORMED:
echo ✅ Microsoft Edge detected at: %SOURCE_PATH%
echo ✅ EdgeWebView folder created at: %DEST%
echo ✅ Edge files successfully copied to EdgeWebView location
echo ✅ Copy verification completed - msedge.exe found in EdgeWebView
echo.
echo 🔧 WHAT THIS FIXES:
echo • Resolves Bunni white screen/blank window issues
echo • Provides WebView2 runtime when standard installers fail  
echo • Uses Edge browser engine as WebView2 replacement
echo • Enables Bunni to display web content properly
echo.
echo 📁 FILES CREATED:
echo • EdgeWebView folder: %DEST%
echo • All Edge browser files copied for WebView2 compatibility
echo.
echo 🚀 NEXT STEPS:
echo 1. Launch Bunni application
echo 2. Check if white screen issue is resolved
echo 3. If issues persist, restart your computer and try again
echo.
echo [INFO] Log saved at: %LOGFILE%
echo Made by nerfine
goto final_exit

:final_exit
call :log "[INFO] Script completed. Auto-closing in 5 seconds..."
echo [INFO] Script completed. Auto-closing in 5 seconds...
timeout /t 5 /nobreak >nul 2>&1
endlocal
exit /b 0
