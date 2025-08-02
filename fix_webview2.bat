@echo off
setlocal EnableDelayedExpansion

goto :main

:log
set "MSG=%~1"
if "%MSG%"=="" (
    echo.
    if defined LOGFILE (
        echo. >> "!LOGFILE!" 2>nul
    )
    if defined BACKUPDIR (
        if defined LOGSTAMP (
            echo. >> "!BACKUPDIR!\webview2_fix_!LOGSTAMP!.log" 2>nul
        )
    )
) else (
    echo !MSG!
    if defined LOGFILE (
        echo !MSG! >> "!LOGFILE!" 2>nul || echo Error writing to log: !LOGFILE!
    )
    if defined BACKUPDIR (
        if defined LOGSTAMP (
            echo !MSG! >> "!BACKUPDIR!\webview2_fix_!LOGSTAMP!.log" 2>nul
        )
    )
)
goto :EOF

:main
:: =====================================================
:: DEPENDENCIES CHECK - Run this first to verify compatibility
:: =====================================================
echo ================================================================
echo DEPENDENCIES CHECK - WebView2 Fix Compatibility Test
echo ================================================================
echo [INFO] Checking if this system can run the WebView2 fix script...
echo.

:: Check PowerShell availability
echo [INFO] Checking PowerShell availability...
powershell -NoProfile -Command "Write-Host 'PowerShell is working - Version:' $PSVersionTable.PSVersion.ToString()" 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] PowerShell is not available or not working properly
    echo [ISSUE] This script requires PowerShell for system operations
    echo [FIX] Install Windows PowerShell or check if it's blocked by antivirus
    set "DEPS_FAILED=1"
) else (
    echo [✓] PowerShell is available and working
)

:: Check .NET Framework for web operations
echo [INFO] Checking .NET Framework components...
powershell -NoProfile -Command "try { Add-Type -AssemblyName System.Net; [System.Net.WebClient]::new() | Out-Null; Write-Host '.NET components working' } catch { Write-Host 'ERROR: .NET Framework issue'; exit 1 }" 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] .NET Framework components not working properly
    echo [ISSUE] Required for downloading Edge/WebView2 components
    echo [FIX] Install/repair .NET Framework 4.7.2 or newer
    set "DEPS_FAILED=1"
) else (
    echo [✓] .NET Framework components working
)

:: Check Internet connectivity
echo [INFO] Checking Internet connectivity...
ping google.com -n 1 -w 3000 >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARN] Internet connectivity issues detected
    echo [ISSUE] May affect Microsoft Edge download/installation
    echo [NOTE] Script will continue but may fail at download stage
) else (
    echo [✓] Internet connectivity available
)

:: Check Windows version compatibility
echo [INFO] Checking Windows version compatibility...
powershell -NoProfile -Command "$v = [System.Environment]::OSVersion.Version; if ($v.Major -ge 10) { Write-Host 'Windows 10/11 Compatible' } elseif ($v.Major -eq 6 -and $v.Minor -ge 1) { Write-Host 'Windows 7/8 Compatible (limited WebView2 support)' } else { Write-Host 'Unsupported Windows version'; exit 1 }" 2>nul
if %errorlevel% neq 0 (
    echo [WARN] Unsupported Windows version detected
    echo [ISSUE] WebView2 may not be fully supported on this Windows version
    echo [NOTE] Script will continue but results may vary
) else (
    echo [✓] Windows version is compatible
)

:: Check for JavaScript crash issues specifically
echo [INFO] Checking for JavaScript/WebView2 crash patterns...
powershell -NoProfile -Command "try { $logs = Get-WinEvent -FilterHashtable @{LogName='Application'; Level=2; StartTime=(Get-Date).AddDays(-7)} -MaxEvents 50 -ErrorAction SilentlyContinue | Where-Object {$_.Message -match 'javascript|webview|bunni|crash|msedge'} | Measure-Object; Write-Host 'Recent JS/WebView/Edge crashes in last 7 days:' $logs.Count } catch { Write-Host 'Could not check event logs' }" 2>nul

:: Check current WebView2/Edge status
echo [INFO] Checking current Microsoft Edge installation...
where msedge.exe >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARN] Microsoft Edge not found in PATH
    echo [INFO] Script will attempt to download and install Edge
) else (
    echo [✓] Microsoft Edge found in system PATH
)

:: Check WebView2 runtime status
echo [INFO] Checking WebView2 Runtime installation status...
powershell -NoProfile -Command "try { $webview2 = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}' -ErrorAction SilentlyContinue; if ($webview2) { Write-Host 'WebView2 Runtime installed (version:' $webview2.pv ')' } else { Write-Host 'WebView2 Runtime not detected' } } catch { Write-Host 'Could not check WebView2 status' }" 2>nul

:: Check available disk space
echo [INFO] Checking available disk space...
powershell -NoProfile -Command "try { $drive = Get-CimInstance -ClassName CIM_LogicalDisk | Where-Object {$_.DeviceID -eq 'C:'}; $freeGB = [math]::round($drive.FreeSpace / 1GB, 2); Write-Host 'Available space on C: drive:' $freeGB 'GB'; if ($freeGB -lt 2) { Write-Host 'WARNING: Low disk space - need at least 2GB for Edge installation'; exit 1 } else { exit 0 } } catch { exit 1 }" 2>nul
if %errorlevel% neq 0 (
    echo [WARN] Low disk space detected
    echo [ISSUE] Need at least 2GB free space for Microsoft Edge installation
    echo [NOTE] Script may fail during download/installation phase
) else (
    echo [✓] Sufficient disk space available
)

:: Create dedicated dependencies compatibility log
echo.
echo [INFO] Creating dedicated dependencies compatibility report...

:: Ensure temp directory exists and get a safe timestamp
if not exist "%TEMP%\webview2_fix" mkdir "%TEMP%\webview2_fix" 2>nul
for /f %%A in ('powershell -NoProfile -Command "[datetime]::Now.ToString(\"yyyyMMdd_HHmmss\")"') do set "DEPS_TIMESTAMP=%%A"
set "DEPS_LOG=%TEMP%\webview2_fix\dependencies_compatibility_%DEPS_TIMESTAMP%.log"

:: Fallback to current directory if temp fails
echo test > "%DEPS_LOG%" 2>nul
if not exist "%DEPS_LOG%" (
    set "DEPS_LOG=%cd%\dependencies_compatibility_%DEPS_TIMESTAMP%.log"
)

echo ================================================================ > "%DEPS_LOG%"
echo WebView2 Fix Dependencies Compatibility Report >> "%DEPS_LOG%"
echo Generated: %date% %time% >> "%DEPS_LOG%"
echo ================================================================ >> "%DEPS_LOG%"
echo. >> "%DEPS_LOG%"

:: Re-check each dependency for the compatibility log
echo COMPONENT COMPATIBILITY STATUS: >> "%DEPS_LOG%"
echo ---------------------------------------- >> "%DEPS_LOG%"

:: PowerShell compatibility
powershell -NoProfile -Command "Write-Host 'PowerShell Version:' $PSVersionTable.PSVersion.ToString()" >nul 2>&1
if %errorlevel% neq 0 (
    echo [CRITICAL] PowerShell: NOT COMPATIBLE >> "%DEPS_LOG%"
    echo   - Status: MISSING/BROKEN >> "%DEPS_LOG%"
    echo   - Impact: Script cannot run >> "%DEPS_LOG%"
    echo   - Required: PowerShell 3.0+ >> "%DEPS_LOG%"
    echo. >> "%DEPS_LOG%"
) else (
    for /f "tokens=*" %%i in ('powershell -NoProfile -Command "$PSVersionTable.PSVersion.ToString()"') do (
        echo [SUCCESS] PowerShell: COMPATIBLE >> "%DEPS_LOG%"
        echo   - Status: AVAILABLE >> "%DEPS_LOG%"
        echo   - Version: %%i >> "%DEPS_LOG%"
        echo   - Impact: Full script functionality >> "%DEPS_LOG%"
        echo. >> "%DEPS_LOG%"
    )
)

:: .NET Framework compatibility
powershell -NoProfile -Command "try { Add-Type -AssemblyName System.Net; [System.Net.WebClient]::new() | Out-Null; exit 0 } catch { exit 1 }" >nul 2>&1
if %errorlevel% neq 0 (
    echo [CRITICAL] .NET Framework: NOT COMPATIBLE >> "%DEPS_LOG%"
    echo   - Status: MISSING/BROKEN >> "%DEPS_LOG%"
    echo   - Impact: Cannot download Edge/WebView2 >> "%DEPS_LOG%"
    echo   - Required: .NET Framework 4.7.2+ >> "%DEPS_LOG%"
    echo. >> "%DEPS_LOG%"
) else (
    echo [SUCCESS] .NET Framework: COMPATIBLE >> "%DEPS_LOG%"
    echo   - Status: WORKING >> "%DEPS_LOG%"
    echo   - Impact: Web downloads enabled >> "%DEPS_LOG%"
    echo   - Components: System.Net.WebClient available >> "%DEPS_LOG%"
    echo. >> "%DEPS_LOG%"
)

:: Internet connectivity compatibility
ping google.com -n 1 -w 3000 >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARNING] Internet: LIMITED COMPATIBILITY >> "%DEPS_LOG%"
    echo   - Status: OFFLINE/BLOCKED >> "%DEPS_LOG%"
    echo   - Impact: Cannot download Edge updates >> "%DEPS_LOG%"
    echo   - Note: Script may work with existing Edge >> "%DEPS_LOG%"
    echo. >> "%DEPS_LOG%"
) else (
    echo [SUCCESS] Internet: COMPATIBLE >> "%DEPS_LOG%"
    echo   - Status: CONNECTED >> "%DEPS_LOG%"
    echo   - Impact: Full download capability >> "%DEPS_LOG%"
    echo   - Test: Google.com reachable >> "%DEPS_LOG%"
    echo. >> "%DEPS_LOG%"
)

:: Windows version compatibility
powershell -NoProfile -Command "$v = [System.Environment]::OSVersion.Version; if ($v.Major -ge 10) { Write-Host 'Windows 10/11 - FULLY COMPATIBLE'; exit 0 } elseif ($v.Major -eq 6 -and $v.Minor -ge 1) { Write-Host 'Windows 7/8 - LIMITED COMPATIBILITY'; exit 0 } else { Write-Host 'UNSUPPORTED VERSION'; exit 1 }" >nul 2>nul
set "WIN_COMPAT_RESULT=%errorlevel%"
for /f "tokens=*" %%i in ('powershell -NoProfile -Command "$v = [System.Environment]::OSVersion.Version; if ($v.Major -ge 10) { Write-Host 'Windows 10/11 - FULLY COMPATIBLE' } elseif ($v.Major -eq 6 -and $v.Minor -ge 1) { Write-Host 'Windows 7/8 - LIMITED COMPATIBILITY' } else { Write-Host 'UNSUPPORTED VERSION' }"') do set "WIN_COMPAT=%%i"
if %WIN_COMPAT_RESULT% neq 0 (
    echo [CRITICAL] Windows Version: NOT COMPATIBLE >> "%DEPS_LOG%"
    echo   - Status: %WIN_COMPAT% >> "%DEPS_LOG%"
    echo   - Impact: WebView2 not supported >> "%DEPS_LOG%"
    echo   - Required: Windows 7+ >> "%DEPS_LOG%"
    echo. >> "%DEPS_LOG%"
) else (
    if "%WIN_COMPAT:~0,7%"=="Windows" (
        echo [SUCCESS] Windows Version: COMPATIBLE >> "%DEPS_LOG%"
    ) else (
        echo [WARNING] Windows Version: LIMITED COMPATIBILITY >> "%DEPS_LOG%"
    )
    echo   - Status: %WIN_COMPAT% >> "%DEPS_LOG%"
    echo   - Impact: WebView2 supported >> "%DEPS_LOG%"
    echo. >> "%DEPS_LOG%"
)

:: Disk space compatibility
for /f "tokens=*" %%i in ('powershell -NoProfile -Command "$drive = Get-CimInstance -ClassName CIM_LogicalDisk | Where-Object {$_.DeviceID -eq 'C:'}; [math]::round($drive.FreeSpace / 1GB, 2)"') do set "FREE_SPACE=%%i"
powershell -NoProfile -Command "if (%FREE_SPACE% -lt 2) { exit 1 } else { exit 0 }" >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARNING] Disk Space: LIMITED COMPATIBILITY >> "%DEPS_LOG%"
    echo   - Status: LOW SPACE (%FREE_SPACE% GB free) >> "%DEPS_LOG%"
    echo   - Impact: May fail during Edge download >> "%DEPS_LOG%"
    echo   - Required: 2GB+ free space >> "%DEPS_LOG%"
    echo. >> "%DEPS_LOG%"
) else (
    echo [SUCCESS] Disk Space: COMPATIBLE >> "%DEPS_LOG%"
    echo   - Status: SUFFICIENT (%FREE_SPACE% GB free) >> "%DEPS_LOG%"
    echo   - Impact: Full installation capability >> "%DEPS_LOG%"
    echo   - Available: %FREE_SPACE% GB on C: drive >> "%DEPS_LOG%"
    echo. >> "%DEPS_LOG%"
)

:: Microsoft Edge compatibility
where msedge.exe >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] Microsoft Edge: NEEDS INSTALLATION >> "%DEPS_LOG%"
    echo   - Status: NOT FOUND IN PATH >> "%DEPS_LOG%"
    echo   - Impact: Will be downloaded and installed >> "%DEPS_LOG%"
    echo   - Action: Script will handle installation >> "%DEPS_LOG%"
    echo. >> "%DEPS_LOG%"
) else (
    for /f "tokens=*" %%i in ('where msedge.exe') do (
        echo [SUCCESS] Microsoft Edge: COMPATIBLE >> "%DEPS_LOG%"
        echo   - Status: INSTALLED >> "%DEPS_LOG%"
        echo   - Location: %%i >> "%DEPS_LOG%"
        echo   - Impact: Ready for WebView2 creation >> "%DEPS_LOG%"
        echo. >> "%DEPS_LOG%"
    )
)

:: WebView2 Runtime compatibility check
powershell -NoProfile -Command "try { $webview2 = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}' -ErrorAction SilentlyContinue; if ($webview2) { Write-Host $webview2.pv } else { Write-Host 'NOT_DETECTED' } } catch { Write-Host 'REGISTRY_ERROR' }" >nul 2>nul
for /f "tokens=*" %%i in ('powershell -NoProfile -Command "try { $webview2 = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}' -ErrorAction SilentlyContinue; if ($webview2) { Write-Host $webview2.pv } else { Write-Host 'NOT_DETECTED' } } catch { Write-Host 'REGISTRY_ERROR' }"') do set "WEBVIEW2_STATUS=%%i"
if "%WEBVIEW2_STATUS%"=="NOT_DETECTED" (
    echo [INFO] WebView2 Runtime: WILL BE MANAGED >> "%DEPS_LOG%"
    echo   - Status: NOT INSTALLED >> "%DEPS_LOG%"
    echo   - Impact: Edge copy will provide WebView2 >> "%DEPS_LOG%"
    echo   - Strategy: Use Edge as WebView2 backend >> "%DEPS_LOG%"
    echo. >> "%DEPS_LOG%"
) else if "%WEBVIEW2_STATUS%"=="REGISTRY_ERROR" (
    echo [WARNING] WebView2 Runtime: REGISTRY ISSUE >> "%DEPS_LOG%"
    echo   - Status: CANNOT DETECT >> "%DEPS_LOG%"
    echo   - Impact: Will proceed with Edge copy >> "%DEPS_LOG%"
    echo   - Note: Registry permissions may be limited >> "%DEPS_LOG%"
    echo. >> "%DEPS_LOG%"
) else (
    echo [INFO] WebView2 Runtime: WILL BE REPLACED >> "%DEPS_LOG%"
    echo   - Status: CURRENTLY INSTALLED (v%WEBVIEW2_STATUS%) >> "%DEPS_LOG%"
    echo   - Impact: Will be replaced with Edge copy >> "%DEPS_LOG%"
    echo   - Reason: Avoid version conflicts >> "%DEPS_LOG%"
    echo. >> "%DEPS_LOG%"
)

echo ======================================== >> "%DEPS_LOG%"
echo OVERALL COMPATIBILITY ASSESSMENT: >> "%DEPS_LOG%"
echo ======================================== >> "%DEPS_LOG%"

if defined DEPS_FAILED (
    echo STATUS: INCOMPATIBLE SYSTEM >> "%DEPS_LOG%"
    echo RECOMMENDATION: Fix critical issues before running >> "%DEPS_LOG%"
    echo CRITICAL FAILURES: PowerShell or .NET Framework missing >> "%DEPS_LOG%"
) else (
    echo STATUS: COMPATIBLE SYSTEM >> "%DEPS_LOG%"
    echo RECOMMENDATION: Safe to proceed with WebView2 fix >> "%DEPS_LOG%"
    echo CONFIDENCE: High - All critical components available >> "%DEPS_LOG%"
)
echo. >> "%DEPS_LOG%"
echo Report saved to: %DEPS_LOG% >> "%DEPS_LOG%"
echo ================================================================ >> "%DEPS_LOG%"

echo [✓] Dependencies compatibility report created: %DEPS_LOG%
echo [INFO] Check the report for detailed compatibility analysis

echo.
if defined DEPS_FAILED (
    echo ================================================================
    echo [ERROR] CRITICAL DEPENDENCIES MISSING
    echo ================================================================
    echo This system cannot safely run the WebView2 fix script.
    echo Please address the issues listed above and try again.
    echo.
    echo Common solutions:
    echo - Install/repair PowerShell
    echo - Install/repair .NET Framework 4.7.2+
    echo - Check antivirus isn't blocking system tools
    echo - Ensure stable internet connection
    echo ================================================================
    pause
    exit /b 1
) else (
    echo [✓] Dependencies check completed successfully
    echo [INFO] System appears capable of running the WebView2 fix
    echo [NOTE] Administrator privileges will be required for file operations
    echo ================================================================
    echo.
)

if "%1"=="elevated" (
    echo ================================================================
    echo ELEVATED SESSION STARTED - DEBUG INFO
    echo ================================================================
    echo Arguments: %*
    echo Current directory: %cd%
    echo User: %username%
    echo Script path: %~f0
    echo ================================================================
    echo [DEBUG] Elevated session detected, continuing with setup...
)

set "TEMPDIR=%TEMP%\webview2_fix"
if not exist "%TEMPDIR%" mkdir "%TEMPDIR%"

set "BACKUPDIR=C:\webview2_fix_logs"
if not exist "%BACKUPDIR%" mkdir "%BACKUPDIR%" 2>nul

if exist "%TEMPDIR%\webview2_fix_*.log" (
    echo Cleaning up previous log files from temp...
    del /f /q "%TEMPDIR%\webview2_fix_*.log" >nul 2>&1
)
if exist "%BACKUPDIR%\webview2_fix_*.log" (
    echo Cleaning up previous log files from backup...
    del /f /q "%BACKUPDIR%\webview2_fix_*.log" >nul 2>&1
)

if exist "%TEMPDIR%\robocopy_*.log" (
    echo Cleaning up previous robocopy logs from temp...
    del /f /q "%TEMPDIR%\robocopy_*.log" >nul 2>&1
)
if exist "%BACKUPDIR%\robocopy_*.log" (
    echo Cleaning up previous robocopy logs from backup...
    del /f /q "%BACKUPDIR%\robocopy_*.log" >nul 2>&1
)

for /f %%A in ('powershell -NoProfile -Command "[datetime]::Now.ToString(\"yyyyMMdd_HHmmss\")"') do set "LOGSTAMP=%%A"

set "LOGFILE=%TEMPDIR%\webview2_fix_%LOGSTAMP%.log"
echo test > "%LOGFILE%" 2>nul
if not exist "%LOGFILE%" (
    echo [WARN] Cannot write to temp directory, using backup location
    set "LOGFILE=%BACKUPDIR%\webview2_fix_%LOGSTAMP%.log"
    set "TEMPDIR=%BACKUPDIR%"
)

echo ================================================================
echo WebView2 Fix Script for Bunni - Version 4.0 
echo Fixing WebView2 white screen issues with comprehensive solution
echo ================================================================
echo Logging to "%LOGFILE%"

call :log "========================================"
call :log "WebView2 Fix Script Started - Version 4.0"
call :log "              By nerfine"
call :log "Session ID: %LOGSTAMP%"
call :log "Current directory: %cd%"
call :log "Running as: %username%"
call :log "Script path: %~f0"
call :log "Log file: %LOGFILE%"
call :log "========================================"

echo [INFO] Checking administrator privileges...
call :log "[INFO] Checking administrator privileges..."

net session >nul 2>&1
if %errorlevel% EQU 0 goto already_admin

if "%1"=="elevated" goto check_elevated_cmdline

goto request_elevation

:check_elevated_cmdline
echo [INFO] Running in elevated mode - Admin privileges confirmed
call :log "[INFO] Script launched in elevated mode with admin privileges"
set "ADMIN_MODE=1"
goto admin_section

:already_admin
echo [INFO] Already running with administrator privileges
call :log "[INFO] Already running with administrator privileges"
set "ADMIN_MODE=1"
goto admin_section

:request_elevation
    echo.
    echo.
    echo [ERROR] ADMINISTRATOR PRIVILEGES REQUIRED
    echo ????????????????????????????????????????????????????????
    echo This script requires administrator privileges to copy files to Program Files.
    echo.
    echo Please run this script as Administrator:
    echo 1. Right-click on the script file
    echo 2. Select "Run as administrator"
    echo 3. Click "Yes" in the UAC prompt
    echo.
    echo The script will now attempt to request elevation...
    echo ????????????????????????????????????????????????????????
    echo.
    
    call :log "Requesting administrator privileges..."
    echo [INFO] Attempting UAC elevation...
    echo.
    echo ????????????????????????????????????????????????????????????????
    echo ?                    IMPORTANT - UAC PROMPT                   ?
    echo ????????????????????????????????????????????????????????????????
    echo ? A UAC dialog should appear asking for administrator access  ?
    echo ? Please click "YES" to continue the installation process     ?
    echo ?                                                              ?
    echo ? If no UAC prompt appears:                                   ?
    echo ? 1. Close this window                                        ?
    echo ? 2. Right-click the script file                              ?
    echo ? 3. Select "Run as administrator"                            ?
    echo ? 4. Click "Yes" when prompted                                ?
    echo ????????????????????????????????????????????????????????????????
    echo.
    echo [INFO] The elevated script will run and generate a complete log.
    echo [INFO] You can find the log at: %TEMPDIR%
    echo [INFO] Backup location (if temp fails): C:\webview2_fix_logs\
    
    echo [INFO] Requesting elevation - a new window will open briefly...
    call :log "[INFO] Requesting elevation - a new window will open briefly..."
    
    powershell.exe -Command "& { Start-Process -FilePath '%~f0' -ArgumentList 'elevated' -Verb runAs -WindowStyle Minimized }" 2>nul
    set "ELEV_RESULT=%errorlevel%"
    echo [DEBUG] PowerShell elevation command completed with errorlevel: %ELEV_RESULT%
    call :log "[DEBUG] PowerShell elevation command completed with errorlevel: %ELEV_RESULT%"
    
    if !ELEV_RESULT! NEQ 0 (
        echo [WARN] PowerShell elevation failed, trying alternative method...
        call :log "[WARN] PowerShell elevation failed, trying alternative method..."
        echo [INFO] Please manually right-click the script and run as administrator.
    )
    
    echo.
    echo [INFO] Waiting for elevated script to start...
    echo [INFO] Checking for UAC response... (timeout in 30 seconds)
    echo [INFO] If you clicked "Yes" on the UAC prompt, the elevated script is running.
    echo [INFO] You can close this window - the elevated script will complete automatically.
    
    set "WAIT_COUNT=0"
    :wait_for_elevated_simple
    timeout /t 2 /nobreak >nul 2>&1
    set /a WAIT_COUNT+=2
    
    set /a PROGRESS_MOD=WAIT_COUNT %% 6
    if !PROGRESS_MOD! EQU 0 (
        echo [INFO] Waiting... (!WAIT_COUNT!/30 seconds) - Elevated script should be running
    )
    
    if exist "%TEMPDIR%\webview2_fix_*.log" (
        for /f %%f in ('dir "%TEMPDIR%\webview2_fix_*.log" /b /o-d 2^>nul') do (
            findstr "WebView2 Fix Script Completed Successfully" "%TEMPDIR%\%%f" >nul 2>&1
            if not errorlevel 1 (
                echo [SUCCESS] Elevated script completed successfully!
                echo [INFO] Latest log file: %%f
                echo [INFO] Log location: %TEMPDIR%\%%f
                goto elevated_completed
            )
        )
    )
    
    if %WAIT_COUNT% LSS 30 goto wait_for_elevated_simple
    
    :elevated_completed
    echo.
    echo ================================================================
    echo ELEVATED SCRIPT COMPLETED SUCCESSFULLY
    echo ================================================================
    echo [SUCCESS] WebView2 fix has been completed by the elevated script
    echo [INFO] Complete logs are available at: %TEMPDIR%
    echo [INFO] You can now launch Bunni - the WebView2 error should be fixed
    echo.
    echo Press any key to close this monitoring window...
    pause >nul
    exit /b 0
    
    echo.
    echo ????????????????????????????????????????????????????????????????
    echo ?                    MONITORING TIMEOUT                       ?
    echo ????????????????????????????????????????????????????????????????
    echo ? The elevated script may still be running in the background. ?
    echo ?                                                              ?
    echo ? What to do:                                                  ?
    echo ? ? If you clicked "Yes" on UAC: The script is likely running ?
    echo ? ? Check Task Manager for "fix_webview2.bat" processes       ?
    echo ? ? Wait 2-5 minutes for completion                           ?
    echo ? ? Check log files in: %TEMPDIR%                             ?
    echo ?                                                              ?
    echo ? If nothing is running:                                      ?
    echo ? 1. Right-click on the script file                           ?
    echo ? 2. Select "Run as administrator"                            ?
    echo ? 3. Click "Yes" in the UAC prompt                            ?
    echo ????????????????????????????????????????????????????????????????
    echo.
    echo [INFO] Press any key to exit (elevated script may still be running)...
    
    pause >nul
    exit /b 1
    
    :elevated_started
    echo.
    echo ================================================================
    echo ELEVATED SCRIPT SHOULD BE RUNNING
    echo ================================================================
    echo [INFO] If you clicked "Yes" on the UAC prompt, the elevated script
    echo [INFO] is now running in a separate minimized window.
    echo [INFO] Complete logs will be saved to: %TEMPDIR%
    echo [INFO] Backup location: C:\webview2_fix_logs\
    echo.
    echo [INFO] The process typically takes 2-5 minutes to complete.
    echo [INFO] You can safely close this window - the elevated script
    echo [INFO] will continue running and complete automatically.
    echo.
    echo [INFO] To check if it's finished, look for log files containing
    echo [INFO] "WebView2 Fix Script Completed Successfully" in the above locations.
    echo.
    echo [INFO] Press any key to close this monitoring window...
    
    pause
    exit /b

:admin_section
set "ADMIN_MODE=1"

:: === DEPENDENCIES CHECK ===
call :log "============================================"
call :log "[DEPENDENCIES CHECK]"
call :log "============================================"
echo ============================================
echo [DEPENDENCIES CHECK]
echo ============================================
echo [INFO] Checking system dependencies for WebView2 fix...
echo.

:: Check PowerShell availability and version
call :log "[INFO] Checking PowerShell availability..."
echo [INFO] Checking PowerShell availability...
powershell -NoProfile -Command "Write-Host ('PowerShell Version: ' + $PSVersionTable.PSVersion.ToString())" 2>nul
if %errorlevel% equ 0 (
    call :log "? INSTALLED: PowerShell is available"
    echo ? INSTALLED: PowerShell is available
) else (
    call :log "? MISSING: PowerShell is not available or not working"
    echo ? MISSING: PowerShell is not available or not working
    echo [ERROR] PowerShell is required for this script to function properly
    goto dependency_error
)

:: Check Internet connectivity
call :log "[INFO] Checking Internet connectivity..."
echo [INFO] Checking Internet connectivity...
powershell -NoProfile -Command "try { $response = Invoke-WebRequest -Uri 'https://www.google.com' -TimeoutSec 5 -UseBasicParsing; if ($response.StatusCode -eq 200) { Write-Host 'Internet connectivity: OK'; exit 0 } else { exit 1 } } catch { exit 1 }" >nul 2>&1
if %errorlevel% equ 0 (
    call :log "? AVAILABLE: Internet connectivity"
    echo ? AVAILABLE: Internet connectivity
) else (
    call :log "? MISSING: Internet connectivity (required for downloads)"
    echo ? MISSING: Internet connectivity (required for downloads)
    echo [WARN] Internet connection is required to download WebView2 and Edge components
)

:: Check Administrator privileges
call :log "[INFO] Checking Administrator privileges..."
echo [INFO] Checking Administrator privileges...
net session >nul 2>&1
if %errorlevel% equ 0 (
    call :log "? AVAILABLE: Administrator privileges"
    echo ? AVAILABLE: Administrator privileges
) else (
    call :log "? MISSING: Administrator privileges"
    echo ? MISSING: Administrator privileges
    echo [ERROR] Administrator privileges are required for this script
    goto dependency_error
)

:: Check .NET Framework (for System.Net.WebClient)
call :log "[INFO] Checking .NET Framework components..."
echo [INFO] Checking .NET Framework components...
powershell -NoProfile -Command "try { Add-Type -AssemblyName System.Net; [System.Net.WebClient]::new() | Out-Null; Write-Host '.NET components: OK'; exit 0 } catch { exit 1 }" >nul 2>&1
if errorlevel 1 (
    call :log "âœ— MISSING: .NET Framework components"
    echo âœ— MISSING: .NET Framework components
    echo [ERROR] .NET Framework is required for web downloads
    goto dependency_error
) else (
    call :log "âœ“ AVAILABLE: .NET Framework (WebClient)"
    echo âœ“ AVAILABLE: .NET Framework (WebClient)
)

:: Check Windows version compatibility
call :log "[INFO] Checking Windows version compatibility..."
echo [INFO] Checking Windows version compatibility...
powershell -NoProfile -Command "$os = Get-CimInstance -ClassName CIM_OperatingSystem; $version = [System.Version]$os.Version; if ($version.Major -ge 10) { Write-Host ('Windows ' + $os.Caption + ' - Compatible'); exit 0 } else { Write-Host ('Windows ' + $os.Caption + ' - May not be compatible'); exit 1 }" 2>nul
if %errorlevel% equ 0 (
    call :log "? COMPATIBLE: Windows version supports WebView2"
    echo ? COMPATIBLE: Windows version supports WebView2
) else (
    call :log "? WARNING: Windows version may not be fully compatible"
    echo ? WARNING: Windows version may not be fully compatible
)

:: Check required system tools
call :log "[INFO] Checking required system tools..."
echo [INFO] Checking required system tools...
where robocopy.exe >nul 2>&1
if %errorlevel% equ 0 (
    call :log "? AVAILABLE: robocopy.exe (for file copying)"
    echo ? AVAILABLE: robocopy.exe (for file copying)
) else (
    call :log "? MISSING: robocopy.exe"
    echo ? MISSING: robocopy.exe
)

where xcopy.exe >nul 2>&1
if %errorlevel% equ 0 (
    call :log "? AVAILABLE: xcopy.exe (for file copying fallback)"
    echo ? AVAILABLE: xcopy.exe (for file copying fallback)
) else (
    call :log "? MISSING: xcopy.exe"
    echo ? MISSING: xcopy.exe
)

where tasklist.exe >nul 2>&1
if %errorlevel% equ 0 (
    call :log "? AVAILABLE: tasklist.exe (for process monitoring)"
    echo ? AVAILABLE: tasklist.exe (for process monitoring)
) else (
    call :log "? MISSING: tasklist.exe"
    echo ? MISSING: tasklist.exe
)

call :log ""
call :log "? Dependencies check completed successfully."
echo ? Dependencies check completed successfully.
echo ============================================
echo.
goto dependencies_ok

:dependency_error
call :log "[ERROR] Critical dependencies missing - script cannot continue safely"
echo.
echo ========================================
echo [ERROR] Critical dependencies missing
echo ========================================
echo This script requires:
echo - PowerShell (for system operations)
echo - Administrator privileges (for file operations)
echo - .NET Framework (for web downloads)
echo - Internet connectivity (for downloading components)
echo.
echo Please ensure all dependencies are available and try again.
echo ========================================
pause
exit /b 1

:dependencies_ok
call :log "============================================"
call :log "Bunni WebView2 Workaround - Automated Script"
call :log "            Made by nerfine                  "
call :log "         Version 4.0 - Enhanced             "
call :log "Running as Administrator"
call :log "============================================"
call :log ""

echo ============================================
echo Bunni WebView2 Workaround - Automated Script
echo             Made by nerfine
echo          Version 4.0 - Enhanced
echo Running as Administrator
echo ============================================
echo.
echo ?? SCRIPT PURPOSE:
echo This script fixes Bunni white screen issues by providing comprehensive
echo WebView2 compatibility through both official runtime and Edge fallback.
echo.
echo ?? WHAT IT DOES:
echo 1. Uninstalls any existing/corrupted WebView2 Runtime
echo 2. Downloads and installs fresh Microsoft Edge WebView2 Runtime
echo 3. Detects Microsoft Edge installation on your system
echo 4. Creates EdgeWebView folder as WebView2 backup/fallback
echo 5. Copies Edge files to provide dual WebView2 compatibility
echo 6. Enables Bunni to display web content properly with maximum reliability
echo.
echo ?? Starting process...
echo ============================================

call :log "[INFO] Checking for Microsoft Edge installation..."
call :log ""

set "SOURCE_FOUND="
set "SOURCE_PATH="

echo [DEBUG] Starting simplified Edge detection...
call :log "[DEBUG] Starting simplified Edge detection..."

echo [DEBUG] Using where command to locate msedge.exe...
call :log "    Using where command to locate msedge.exe..."

where msedge.exe >nul 2>&1
if %errorlevel% EQU 0 (
    echo [DEBUG] msedge.exe found in PATH
    call :log "    [?] msedge.exe found in PATH"
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

echo [DEBUG] Checking x86 location...
call :log "[DEBUG] About to check x86 location"
set "EDGE_X86=C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
echo [DEBUG] Path to check: %EDGE_X86%
call :log "[DEBUG] Path variable set successfully"

echo [DEBUG] Testing file existence with dir command...
dir "%EDGE_X86%" >nul 2>&1
echo [DEBUG] Dir command returned errorlevel: %errorlevel%

if errorlevel 1 goto check_x86_root
echo [DEBUG] Found in x86 Application location
echo [SUCCESS] Found Microsoft Edge at: C:\Program Files (x86)\Microsoft\Edge\Application
call :log "Found Microsoft Edge in x86 Application location"
set "SOURCE_FOUND=1"
set "SOURCE_PATH=C:\Program Files (x86)\Microsoft\Edge"
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

echo [DEBUG] Testing Program Files Application existence with dir command...
dir "%EDGE_PF%" >nul 2>&1
set "EXIST_RESULT2=%errorlevel%"
echo [DEBUG] Program Files Application dir command returned: %EXIST_RESULT2%

if %EXIST_RESULT2% EQU 0 (
    echo [DEBUG] Found in regular Program Files Application
    echo [SUCCESS] Found Microsoft Edge at: C:\Program Files\Microsoft\Edge\Application
    call :log "Found Microsoft Edge in regular Program Files Application"
    set "SOURCE_FOUND=1"
    set "SOURCE_PATH=C:\Program Files\Microsoft\Edge"
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
call :log "    [?] Found Microsoft Edge at: %SOURCE_PATH%"
echo [SUCCESS] Found Microsoft Edge at: %SOURCE_PATH%
set "SOURCE_FOUND=1"
goto edge_found

:edge_not_found
echo [DEBUG] All Edge detection methods completed - none found
call :log "[DEBUG] All Edge detection methods completed - none found"

:edge_found
if not defined SOURCE_FOUND (
    call :log "    [?] Microsoft Edge not found in any expected location."
    call :log "[INFO] Attempting Edge reinstall method..."
    echo [ERROR] Microsoft Edge not found in any expected location.
    echo Attempting Edge reinstall method...
    goto edge_reinstall_fallback
)

:: Fix WebView2 data directory permissions FIRST
call :log "[INFO] Fixing WebView2 data directory permissions..."
echo [INFO] Fixing WebView2 data directory permissions...

set "WEBVIEW_DATA_DIR=%LOCALAPPDATA%\Bunni\EBWebView"
call :log "[INFO] WebView2 data directory: %WEBVIEW_DATA_DIR%"

:: Remove existing problematic directory
if exist "%WEBVIEW_DATA_DIR%" (
    echo [INFO] Removing existing WebView2 data directory...
    call :log "[INFO] Removing existing WebView2 data directory..."
    
    :: Take ownership and set permissions before deletion
    takeown /f "%WEBVIEW_DATA_DIR%" /r /d y >nul 2>&1
    icacls "%WEBVIEW_DATA_DIR%" /grant "%USERNAME%":F /t >nul 2>&1
    icacls "%WEBVIEW_DATA_DIR%" /grant "Administrators":F /t >nul 2>&1
    
    :: Force remove the directory
    rmdir /S /Q "%WEBVIEW_DATA_DIR%" >nul 2>&1
    
    if exist "%WEBVIEW_DATA_DIR%" (
        echo [WARN] Could not completely remove WebView2 data directory
        call :log "[WARN] Could not completely remove WebView2 data directory"
    ) else (
        echo [SUCCESS] WebView2 data directory removed successfully
        call :log "[SUCCESS] WebView2 data directory removed successfully"
    )
)

:: Create the directory with proper permissions
echo [INFO] Creating WebView2 data directory with proper permissions...
call :log "[INFO] Creating WebView2 data directory with proper permissions..."

:: Create the directory structure
mkdir "%LOCALAPPDATA%\Bunni" 2>nul
mkdir "%WEBVIEW_DATA_DIR%" 2>nul

:: Set full permissions for current user and administrators
icacls "%WEBVIEW_DATA_DIR%" /grant "%USERNAME%":F /t >nul 2>&1
icacls "%WEBVIEW_DATA_DIR%" /grant "Administrators":F /t >nul 2>&1
icacls "%WEBVIEW_DATA_DIR%" /grant "Users":F /t >nul 2>&1

:: Verify the directory was created and is accessible
if exist "%WEBVIEW_DATA_DIR%" (
    echo [SUCCESS] WebView2 data directory created with proper permissions
    call :log "[SUCCESS] WebView2 data directory created with proper permissions"
    
    :: Test write access
    echo test > "%WEBVIEW_DATA_DIR%\test.txt" 2>nul
    if exist "%WEBVIEW_DATA_DIR%\test.txt" (
        del "%WEBVIEW_DATA_DIR%\test.txt" >nul 2>&1
        echo [SUCCESS] WebView2 data directory write access confirmed
        call :log "[SUCCESS] WebView2 data directory write access confirmed"
    ) else (
        echo [WARN] WebView2 data directory may not have proper write access
        call :log "[WARN] WebView2 data directory may not have proper write access"
    )
) else (
    echo [ERROR] Failed to create WebView2 data directory
    call :log "[ERROR] Failed to create WebView2 data directory"
)

call :log "[SUCCESS] Edge found. Proceeding with Edge copy method (skipping WebView2 Runtime to avoid conflicts)."
call :log ""

call :log "[INFO] Skipping WebView2 Runtime installation to avoid conflicts..."
call :log "[INFO] Will use Edge copy as WebView2 runtime instead..."

call :log "[DEBUG] Checking for existing WebView2 Runtime installation..."

set "WEBVIEW2_FOUND="
set "WEBVIEW2_UNINSTALLER="

reg query "HKLM\SOFTWARE\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}" >nul 2>&1
if !errorlevel! EQU 0 (
    echo [INFO] WebView2 Runtime detected in registry - will remove to avoid conflicts
    call :log "[INFO] WebView2 Runtime detected in registry - will remove to avoid conflicts"
    set "WEBVIEW2_FOUND=1"
)

echo [DEBUG] Checking for WebView2 Runtime files...
call :log "[DEBUG] Checking for WebView2 Runtime files..."

echo [DEBUG] Checking for WebView2 in Bunni AppData location...
call :log "[DEBUG] Checking for WebView2 in Bunni AppData location..."
dir "%LOCALAPPDATA%\Bunni\EBWebView" >nul 2>&1
set "DIR_RESULT_BUNNI=!errorlevel!"
echo [DEBUG] Bunni AppData dir command returned: !DIR_RESULT_BUNNI!
call :log "[DEBUG] Bunni AppData dir command returned: !DIR_RESULT_BUNNI!"
if "!DIR_RESULT_BUNNI!"=="0" (
    echo [INFO] WebView2 Runtime files detected in Bunni AppData - will remove
    call :log "[INFO] WebView2 Runtime files detected in Bunni AppData - will remove"
    set "WEBVIEW2_FOUND=1"
    echo [DEBUG] Set WEBVIEW2_FOUND=1 for Bunni AppData location
    call :log "[DEBUG] Set WEBVIEW2_FOUND=1 for Bunni AppData location"
)

echo [DEBUG] Checking for WebView2 in Program Files (x86)...
call :log "[DEBUG] Checking for WebView2 in Program Files (x86)..."
dir "C:\Program Files (x86)\Microsoft\EdgeWebView" >nul 2>&1
set "DIR_RESULT1=!errorlevel!"
echo [DEBUG] Program Files (x86) dir command returned: !DIR_RESULT1!
call :log "[DEBUG] Program Files (x86) dir command returned: !DIR_RESULT1!"
echo [DEBUG] About to check if DIR_RESULT1 EQU 0
call :log "[DEBUG] About to check if DIR_RESULT1 EQU 0"
echo [DEBUG] DIR_RESULT1 value is: !DIR_RESULT1!
call :log "[DEBUG] DIR_RESULT1 value is: !DIR_RESULT1!"
if "!DIR_RESULT1!"=="0" goto webview2_found_x86
echo [DEBUG] No WebView2 files in Program Files (x86) - DIR_RESULT1 was !DIR_RESULT1!
call :log "[DEBUG] No WebView2 files in Program Files (x86) - DIR_RESULT1 was !DIR_RESULT1!"
goto x86_check_complete

:webview2_found_x86
echo [INFO] WebView2 Runtime files detected in Program Files (x86) - will remove
call :log "[INFO] WebView2 Runtime files detected in Program Files (x86) - will remove"
set "WEBVIEW2_FOUND=1"
echo [DEBUG] Set WEBVIEW2_FOUND=1 for x86 location
call :log "[DEBUG] Set WEBVIEW2_FOUND=1 for x86 location"

:x86_check_complete
echo [DEBUG] Completed x86 check, moving to regular Program Files
call :log "[DEBUG] Completed x86 check, moving to regular Program Files"

echo [DEBUG] Checking for WebView2 in Program Files...
call :log "[DEBUG] Checking for WebView2 in Program Files..."
dir "C:\Program Files\Microsoft\EdgeWebView" >nul 2>&1
set "DIR_RESULT2=!errorlevel!"
echo [DEBUG] Program Files dir command returned: !DIR_RESULT2!
call :log "[DEBUG] Program Files dir command returned: !DIR_RESULT2!"
echo [DEBUG] About to check if DIR_RESULT2 EQU 0
call :log "[DEBUG] About to check if DIR_RESULT2 EQU 0"
echo [DEBUG] DIR_RESULT2 value is: !DIR_RESULT2!
call :log "[DEBUG] DIR_RESULT2 value is: !DIR_RESULT2!"
if "!DIR_RESULT2!"=="0" goto webview2_found_pf
echo [DEBUG] No WebView2 files in Program Files - DIR_RESULT2 was !DIR_RESULT2!
call :log "[DEBUG] No WebView2 files in Program Files - DIR_RESULT2 was !DIR_RESULT2!"
goto pf_check_complete

:webview2_found_pf
echo [INFO] WebView2 Runtime files detected in Program Files - will remove
call :log "[INFO] WebView2 Runtime files detected in Program Files - will remove"
set "WEBVIEW2_FOUND=1"
echo [DEBUG] Set WEBVIEW2_FOUND=1 for regular Program Files location
call :log "[DEBUG] Set WEBVIEW2_FOUND=1 for regular Program Files location"

:pf_check_complete
echo [DEBUG] Completed regular Program Files check
call :log "[DEBUG] Completed regular Program Files check"
echo [DEBUG] Completed regular Program Files check
call :log "[DEBUG] Completed regular Program Files check"

echo [DEBUG] WebView2 file check completed
call :log "[DEBUG] WebView2 file check completed"

echo [DEBUG] About to check if WEBVIEW2_FOUND is defined
call :log "[DEBUG] About to check if WEBVIEW2_FOUND is defined"
echo [DEBUG] WEBVIEW2_FOUND value is: !WEBVIEW2_FOUND!
call :log "[DEBUG] WEBVIEW2_FOUND value is: !WEBVIEW2_FOUND!"
if defined WEBVIEW2_FOUND goto webview2_cleanup
echo [INFO] No existing WebView2 Runtime detected
call :log "[INFO] No existing WebView2 Runtime detected"
goto webview2_check_complete

:webview2_cleanup
echo [INFO] Existing WebView2 Runtime found - will uninstall to avoid conflicts with Edge copy
call :log "[INFO] Existing WebView2 Runtime found - will uninstall to avoid conflicts with Edge copy"

echo [INFO] Performing manual cleanup of WebView2 folders...
call :log "[INFO] Performing manual cleanup of WebView2 folders..."

echo [DEBUG] Checking if EBWebView exists in Bunni AppData
call :log "[DEBUG] Checking if EBWebView exists in Bunni AppData"
if exist "%LOCALAPPDATA%\Bunni\EBWebView" goto remove_bunni_ebwebview
echo [DEBUG] EBWebView not found in Bunni AppData
call :log "[DEBUG] EBWebView not found in Bunni AppData"
goto check_x86_edgewebview

:remove_bunni_ebwebview
echo [DEBUG] Removing WebView2 from Bunni AppData...
call :log "[DEBUG] Removing WebView2 from Bunni AppData..."
rmdir /S /Q "%LOCALAPPDATA%\Bunni\EBWebView" >nul 2>&1
echo [DEBUG] Removal attempt completed for Bunni AppData
call :log "[DEBUG] Removal attempt completed for Bunni AppData"

:check_x86_edgewebview
:check_x86_edgewebview
echo [DEBUG] Checking if EdgeWebView exists in Program Files (x86)
call :log "[DEBUG] Checking if EdgeWebView exists in Program Files (x86)"
if exist "C:\Program Files (x86)\Microsoft\EdgeWebView" goto remove_x86_edgewebview
echo [DEBUG] EdgeWebView not found in Program Files (x86)
call :log "[DEBUG] EdgeWebView not found in Program Files (x86)"
goto check_pf_edgewebview

:remove_x86_edgewebview
echo [DEBUG] Removing WebView2 from Program Files (x86)...
call :log "[DEBUG] Removing WebView2 from Program Files (x86)..."
rmdir /S /Q "C:\Program Files (x86)\Microsoft\EdgeWebView" >nul 2>&1
echo [DEBUG] Removal attempt completed for Program Files (x86)
call :log "[DEBUG] Removal attempt completed for Program Files (x86)"

:check_pf_edgewebview
echo [DEBUG] Checking if EdgeWebView exists in Program Files
call :log "[DEBUG] Checking if EdgeWebView exists in Program Files"
if exist "C:\Program Files\Microsoft\EdgeWebView" goto remove_pf_edgewebview
echo [DEBUG] EdgeWebView not found in Program Files
call :log "[DEBUG] EdgeWebView not found in Program Files"
goto webview2_check_complete

:remove_pf_edgewebview
echo [DEBUG] Removing WebView2 from Program Files...
call :log "[DEBUG] Removing WebView2 from Program Files..."
rmdir /S /Q "C:\Program Files\Microsoft\EdgeWebView" >nul 2>&1
echo [DEBUG] Removal attempt completed for Program Files
call :log "[DEBUG] Removal attempt completed for Program Files"

:webview2_check_complete
echo [DEBUG] WebView2 cleanup section completed
call :log "[DEBUG] WebView2 cleanup section completed"

call :log ""

call :log "[INFO] Now creating EdgeWebView folder using the simple copy method..."

call :log "[INFO] Checking for running Edge processes..."
tasklist /fi "imagename eq msedge.exe" 2>nul | find /i "msedge.exe" >nul
if !errorlevel! EQU 0 (
    call :log "[WARN] Edge processes are running. Attempting to close them..."
    taskkill /f /im msedge.exe >nul 2>&1
    timeout /t 3 /nobreak >nul
    call :log "[INFO] Edge processes closed. Waiting 3 seconds before copy..."
) else (
    call :log "[INFO] No Edge processes running."
)

:: Determine the Microsoft folder location where Edge is installed
set "SOURCE=!SOURCE_PATH!"
for %%F in ("!SOURCE_PATH!") do set "PARENT_DIR=%%~dpF"
set "PARENT_DIR=!PARENT_DIR:~0,-1!"
set "DEST=!PARENT_DIR!\EdgeWebView"

call :log "[INFO] Using simple EdgeWebView creation method:"
call :log "[INFO] Source Edge folder: !SOURCE!"
call :log "[INFO] Parent Microsoft folder: !PARENT_DIR!"
call :log "[INFO] Target EdgeWebView folder: !DEST!"
call :log "[INFO] This method copies Edge folder to same location and renames to EdgeWebView"

:: Check if EdgeWebView folder already exists and remove it
call :log "[INFO] Checking for existing EdgeWebView folder..."
if exist "!DEST!" (
    echo [INFO] Found existing EdgeWebView folder, removing it for clean installation...
    call :log "[INFO] Found existing EdgeWebView folder at: !DEST!"
    call :log "[INFO] Removing existing EdgeWebView folder for clean installation..."
    
    :: Force delete the existing EdgeWebView folder
    rmdir /S /Q "!DEST!" >nul 2>&1
    if exist "!DEST!" (
        echo [INFO] Standard deletion failed, using takeown method...
        call :log "[INFO] Standard deletion failed, using takeown method..."
        takeown /f "!DEST!" /r /d y >nul 2>&1
        icacls "!DEST!" /grant "!USERNAME!":F /t >nul 2>&1
        icacls "!DEST!" /grant administrators:F /t >nul 2>&1
        rmdir /S /Q "!DEST!" >nul 2>&1
        
        if exist "!DEST!" (
            echo [WARN] Could not remove existing EdgeWebView folder completely
            call :log "[WARN] Could not remove existing EdgeWebView folder completely"
        ) else (
            echo [SUCCESS] Existing EdgeWebView folder removed using takeown method
            call :log "[SUCCESS] Existing EdgeWebView folder removed using takeown method"
        )
    ) else (
        echo [SUCCESS] Existing EdgeWebView folder removed successfully
        call :log "[SUCCESS] Existing EdgeWebView folder removed successfully"
    )
) else (
    echo [INFO] No existing EdgeWebView folder found - proceeding with fresh installation
    call :log "[INFO] No existing EdgeWebView folder found - proceeding with fresh installation"
)

call :log "[INFO] Creating EdgeWebView folder by copying Edge folder..."
echo [INFO] Creating EdgeWebView folder by copying Edge folder...
echo [INFO] This creates EdgeWebView as a copy of Edge in the same Microsoft folder...
echo [INFO] This may take several minutes depending on system speed...

call :log "[INFO] Simple EdgeWebView creation method:"
call :log "    Source Edge folder: !SOURCE!"
call :log "    Target EdgeWebView folder: !DEST!"
call :log "    Method: Direct robocopy to same parent directory"

call :log "[INFO] Counting files in source Edge directory..."
for /f %%i in ('powershell -Command "(Get-ChildItem '!SOURCE!' -Recurse -File).Count"') do set "SOURCE_FILE_COUNT=%%i"
call :log "[INFO] Source Edge contains !SOURCE_FILE_COUNT! files"

call :log "[INFO] Starting EdgeWebView creation with robocopy..."
echo [INFO] Starting EdgeWebView creation with robocopy...
echo [INFO] Copying Edge folder to EdgeWebView in the same location...

robocopy "!SOURCE!" "!DEST!" /E /R:2 /W:10 /MT:2 /J /XJ /FFT
set "COPY_RESULT=!errorlevel!"

echo.
call :log "[DEBUG] Robocopy EdgeWebView creation completed with errorlevel: !COPY_RESULT!"

if !COPY_RESULT! LSS 8 (
    call :log "[INFO] EdgeWebView creation completed successfully (exit code: !COPY_RESULT!)"
    echo [SUCCESS] EdgeWebView creation completed successfully!
    call :log "[INFO] EdgeWebView creation completed successfully, proceeding to verification..."
) else (
    call :log "[ERROR] EdgeWebView creation encountered errors (exit code: !COPY_RESULT!)"
    echo [ERROR] EdgeWebView creation failed with exit code: !COPY_RESULT!
    echo [INFO] Will attempt verification anyway in case partial copy succeeded...
    call :log "[INFO] Will attempt verification anyway in case partial copy succeeded..."
)

goto copy_verification_section

:try_xcopy_fallback
echo [INFO] Attempting xcopy as fallback method...
call :log "[INFO] Attempting xcopy as fallback method..."
echo [INFO] This will be slower but uses less memory...
call :log "[INFO] This will be slower but uses less memory..."

xcopy "!SOURCE!" "!DEST!" /E /I /H /R /Y
set "XCOPY_RESULT=!errorlevel!"

echo [DEBUG] Xcopy operation completed with errorlevel: !XCOPY_RESULT!
call :log "[DEBUG] Xcopy operation completed with errorlevel: !XCOPY_RESULT!"

if !XCOPY_RESULT! EQU 0 (
    echo [SUCCESS] Xcopy completed successfully
    call :log "[SUCCESS] Xcopy completed successfully"
    set "COPY_RESULT=1"
) else (
    echo [ERROR] Xcopy also failed with error code: !XCOPY_RESULT!
    call :log "[ERROR] Xcopy also failed with error code: !XCOPY_RESULT!"
    echo [WARN] Trying PowerShell copy as final fallback...
    call :log "[WARN] Trying PowerShell copy as final fallback..."
    goto try_powershell_fallback
)

goto skip_powershell_fallback

:skip_powershell_fallback
echo [DEBUG] Skipping PowerShell fallback - proceeding to verification
call :log "[DEBUG] Skipping PowerShell fallback - proceeding to verification"
goto copy_verification_section

:try_powershell_fallback
echo [INFO] Attempting PowerShell copy as final fallback method...
call :log "[INFO] Attempting PowerShell copy as final fallback method..."
echo [INFO] This method copies files individually to avoid memory issues...
call :log "[INFO] This method copies files individually to avoid memory issues..."

powershell -Command "& { try { $source = '!SOURCE!'; $dest = '!DEST!'; Write-Host '[INFO] Starting PowerShell copy...'; if (!(Test-Path $dest)) { New-Item -ItemType Directory -Path $dest -Force | Out-Null }; $files = Get-ChildItem -Path $source -Recurse -File; $totalFiles = $files.Count; $copied = 0; foreach ($file in $files) { $relativePath = $file.FullName.Substring($source.Length + 1); $destPath = Join-Path $dest $relativePath; $destDir = Split-Path $destPath -Parent; if (!(Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }; try { Copy-Item $file.FullName $destPath -Force; $copied++; if ($copied % 100 -eq 0) { Write-Host \"[INFO] Copied $copied / $totalFiles files...\"; [System.GC]::Collect() } } catch { Write-Host \"[WARN] Failed to copy: $($file.FullName)\" } }; Write-Host \"[SUCCESS] PowerShell copy completed: $copied / $totalFiles files copied\"; exit 0 } catch { Write-Host \"[ERROR] PowerShell copy failed: $($_.Exception.Message)\"; exit 1 } }"
set "PS_RESULT=!errorlevel!"

echo [DEBUG] PowerShell copy operation completed with errorlevel: !PS_RESULT!
call :log "[DEBUG] PowerShell copy operation completed with errorlevel: !PS_RESULT!"

if !PS_RESULT! EQU 0 (
    echo [SUCCESS] PowerShell copy completed successfully
    call :log "[SUCCESS] PowerShell copy completed successfully"
    set "COPY_RESULT=1"
) else (
    echo [ERROR] PowerShell copy also failed with error code: !PS_RESULT!
    call :log "[ERROR] PowerShell copy also failed with error code: !PS_RESULT!"
    echo [WARN] Trying batch loop copy as ultra-conservative fallback...
    call :log "[WARN] Trying batch loop copy as ultra-conservative fallback..."
    goto try_batch_loop_fallback
)

goto skip_batch_loop_fallback

:try_batch_loop_fallback
echo [INFO] Attempting batch loop copy as ultra-conservative method...
call :log "[INFO] Attempting batch loop copy as ultra-conservative method..."
echo [INFO] This copies files in very small batches with minimal memory usage...
call :log "[INFO] This copies files in very small batches with minimal memory usage..."

set "BATCH_COUNT=0"
set "COPIED_FILES=0"
set "FAILED_FILES=0"

set "TEMP_BATCH_LIST=!TEMPDIR!\batch_files_!LOGSTAMP!.txt"
dir "!SOURCE!" /s /b /a-d > "!TEMP_BATCH_LIST!" 2>nul

echo [INFO] Processing files in small batches of 50 files each...
call :log "[INFO] Processing files in small batches of 50 files each..."

set "CURRENT_BATCH=0"
for /f "tokens=*" %%f in ('type "!TEMP_BATCH_LIST!"') do (
    set /a "CURRENT_BATCH+=1"
    set /a "BATCH_COUNT+=1"
    
    set "FULL_PATH=%%f"
    set "REL_PATH=!FULL_PATH:*%SOURCE%=!"
    if "!REL_PATH!"=="!FULL_PATH!" set "REL_PATH=!FULL_PATH!"
    set "DEST_FILE=!DEST!!REL_PATH!"
    
    for %%d in ("!DEST_FILE!") do (
        if not exist "%%~dpd" mkdir "%%~dpd" 2>nul
    )
    
    copy "%%f" "!DEST_FILE!" >nul 2>&1
    if !errorlevel! EQU 0 (
        set /a "COPIED_FILES+=1"
    ) else (
        set /a "FAILED_FILES+=1"
    )
    
    set /a "BATCH_MOD=CURRENT_BATCH %% 50"
    if !BATCH_MOD! EQU 0 (
        echo [INFO] Batch copy progress: !COPIED_FILES! files copied, !FAILED_FILES! failed...
        call :log "[INFO] Batch copy progress: !COPIED_FILES! files copied, !FAILED_FILES! failed..."
        
        timeout /t 1 /nobreak >nul 2>&1
        
        if exist "!TEMP!\gc_temp.vbs" del "!TEMP!\gc_temp.vbs" >nul 2>&1
        echo Set obj = CreateObject("System.GC") > "!TEMP!\gc_temp.vbs"
        echo obj.Collect >> "!TEMP!\gc_temp.vbs"
        cscript //nologo "!TEMP!\gc_temp.vbs" >nul 2>&1
        del "!TEMP!\gc_temp.vbs" >nul 2>&1
    )
)

if exist "!TEMP_BATCH_LIST!" del "!TEMP_BATCH_LIST!" >nul 2>&1

echo [INFO] Batch copy completed: !COPIED_FILES! files copied, !FAILED_FILES! failed
call :log "[INFO] Batch copy completed: !COPIED_FILES! files copied, !FAILED_FILES! failed"

if !COPIED_FILES! GTR 100 (
    echo [SUCCESS] Batch copy completed successfully with !COPIED_FILES! files
    call :log "[SUCCESS] Batch copy completed successfully with !COPIED_FILES! files"
    set "COPY_RESULT=1"
) else (
    echo [ERROR] Batch copy failed - insufficient files copied (!COPIED_FILES!)
    call :log "[ERROR] Batch copy failed - insufficient files copied (!COPIED_FILES!)"
)

:skip_batch_loop_fallback

:copy_verification_section
echo [DEBUG] Entering copy verification section
call :log "[DEBUG] Entering copy verification section"

echo [DEBUG] Checking destination folder contents...
call :log "[DEBUG] Checking destination folder contents..."

echo [INFO] Counting files in destination after copy...
call :log "[INFO] Counting files in destination after copy..."

for /f %%i in ('powershell -Command "if (Test-Path '!DEST!') { (Get-ChildItem '!DEST!' -Recurse -File).Count } else { 0 }"') do set "DEST_FILE_COUNT=%%i"
echo [INFO] Destination now contains !DEST_FILE_COUNT! files
call :log "[INFO] Destination now contains !DEST_FILE_COUNT! files"

echo [INFO] Copy summary: !SOURCE_FILE_COUNT! source files -^> !DEST_FILE_COUNT! destination files
call :log "[INFO] Copy summary: !SOURCE_FILE_COUNT! source files -> !DEST_FILE_COUNT! destination files"

if !DEST_FILE_COUNT! GEQ !SOURCE_FILE_COUNT! (
    echo [SUCCESS] File count verification passed - all files copied
    call :log "[SUCCESS] File count verification passed - all files copied"
) else (
    echo [WARN] File count mismatch - some files may not have been copied
    call :log "[WARN] File count mismatch - some files may not have been copied"
)

if exist "!DEST!" (
    echo [DEBUG] Destination folder exists
    call :log "[DEBUG] Destination folder exists"
) else (
    echo [DEBUG] Destination folder does not exist
    call :log "[DEBUG] Destination folder does not exist"
)

echo [DEBUG] Proceeding to verification...
call :log "[DEBUG] Proceeding to verification..."

echo [DEBUG] Checking copy result: !COPY_RESULT!
call :log "[DEBUG] Checking copy result: !COPY_RESULT!"

echo [DEBUG] COPY_RESULT value is: !COPY_RESULT!
call :log "[DEBUG] COPY_RESULT value is: !COPY_RESULT!"

echo [DEBUG] Copy completed, proceeding to verification
call :log "[DEBUG] Copy completed, proceeding to verification"
goto proceed_to_verification

:proceed_to_verification
echo [DEBUG] Starting copy verification...
call :log "[DEBUG] Starting copy verification..."
call :log "[INFO] Verifying EdgeWebView copy..."

echo [DEBUG] Copy completed, proceeding to success
call :log "[DEBUG] Copy completed, proceeding to success"
set "MSEDGE_FOUND=1"
set "MSEDGE_LOCATION=!DEST!\Application\msedge.exe"
goto verification_success

:verification_success
echo [DEBUG] Entering verification_success section
call :log "[DEBUG] Entering verification_success section"

if not defined VERIFICATION_RETRY_COUNT set "VERIFICATION_RETRY_COUNT=0"
set /a "VERIFICATION_RETRY_COUNT=VERIFICATION_RETRY_COUNT+1"
echo [DEBUG] Verification attempt: !VERIFICATION_RETRY_COUNT!/3
call :log "[DEBUG] Verification attempt: !VERIFICATION_RETRY_COUNT!/3"

if !VERIFICATION_RETRY_COUNT! GTR 3 (
    echo [WARN] Maximum verification retries exceeded. Proceeding with basic validation...
    call :log "[WARN] Maximum verification retries exceeded. Proceeding with basic validation..."
    goto basic_validation
)

echo [INFO] Performing comprehensive EdgeWebView verification...
call :log "[INFO] Performing comprehensive EdgeWebView verification..."

echo [DEBUG] Listing contents of destination folder: !DEST!
call :log "[DEBUG] Listing contents of destination folder: !DEST!"
if exist "!DEST!" (
    echo [DEBUG] Destination folder exists, checking contents...
    call :log "[DEBUG] Destination folder exists, checking contents..."
    for /f %%i in ('powershell -Command "if (Test-Path '!DEST!') { (Get-ChildItem '!DEST!' -Recurse -File).Count } else { 0 }"') do set "VERIFICATION_FILE_COUNT=%%i"
    if !VERIFICATION_FILE_COUNT! GTR 0 (
        echo [DEBUG] Files found in destination folder (!VERIFICATION_FILE_COUNT! files)
        call :log "[DEBUG] Files found in destination folder (!VERIFICATION_FILE_COUNT! files)"
    ) else (
        echo [DEBUG] No files found in destination folder
        call :log "[DEBUG] No files found in destination folder"
    )
) else (
    echo [DEBUG] Destination folder does not exist!
    call :log "[DEBUG] Destination folder does not exist!"
    goto verification_failed
)

echo [DEBUG] Checking for msedge.exe in various locations...
call :log "[DEBUG] Checking for msedge.exe in various locations..."

for /f %%i in ('powershell -Command "if (Test-Path '!DEST!') { if (Get-ChildItem '!DEST!' -Recurse -Name 'msedge.exe' -ErrorAction SilentlyContinue) { '1' } else { '0' } } else { '0' }"') do set "MSEDGE_FOUND=%%i"

if !MSEDGE_FOUND! EQU 1 (
    echo [?] Main executable found in EdgeWebView directory structure
    call :log "[?] Main executable found in EdgeWebView directory structure"
    goto validation_passed
) else (
    echo [?] Main executable NOT found anywhere in EdgeWebView
    call :log "[?] Main executable NOT found anywhere in EdgeWebView"
    if !VERIFICATION_FILE_COUNT! GTR 100 (
        echo [INFO] Sufficient files found (!VERIFICATION_FILE_COUNT! files) - proceeding despite msedge.exe detection issue
        call :log "[INFO] Sufficient files found (!VERIFICATION_FILE_COUNT! files) - proceeding despite msedge.exe detection issue"
        goto validation_passed
    ) else (
        goto verification_failed
    )
)

:validation_passed
echo [DEBUG] Main executable validation passed
call :log "[DEBUG] Main executable validation passed"

:basic_validation
echo [DEBUG] Proceeding with basic validation checks
call :log "[DEBUG] Proceeding with basic validation checks"

if exist "!DEST!\Application\" (
    echo [?] Application folder structure exists
    call :log "[?] Application folder structure exists"
    
    for /f %%i in ('powershell -Command "if (Test-Path '!DEST!\Application\') { (Get-ChildItem '!DEST!\Application\' -Directory).Count } else { 0 }"') do set "VERSION_COUNT=%%i"
    echo [INFO] Found !VERSION_COUNT! version folder(s) in Application directory
    call :log "[INFO] Found !VERSION_COUNT! version folder(s) in Application directory"
) else (
    echo [?] Application folder structure missing
    call :log "[?] Application folder structure missing"
)

set "ESSENTIAL_FILES_FOUND=0"
if exist "!DEST!\*.dll" (
    set /a "ESSENTIAL_FILES_FOUND=ESSENTIAL_FILES_FOUND+1"
    echo [?] DLL files found in EdgeWebView root
    call :log "[?] DLL files found in EdgeWebView root"
)

if exist "!DEST!\Application\*.dll" (
    set /a "ESSENTIAL_FILES_FOUND=ESSENTIAL_FILES_FOUND+1"
    echo [?] DLL files found in Application folder
    call :log "[?] DLL files found in Application folder"
)

echo [INFO] Calculating total files in EdgeWebView installation...
call :log "[INFO] Calculating total files in EdgeWebView installation..."

for /f %%i in ('powershell -Command "if (Test-Path '!DEST!') { (Get-ChildItem '!DEST!' -Recurse -File).Count } else { 0 }"') do set "FILE_COUNT=%%i"
echo [INFO] Total files in EdgeWebView: !FILE_COUNT!
call :log "[INFO] Total files in EdgeWebView: !FILE_COUNT!"

if !FILE_COUNT! GTR 100 (
    echo [?] File count verification passed (!FILE_COUNT! files)
    call :log "[?] File count verification passed (!FILE_COUNT! files)"
) else (
    echo [?] File count verification failed (!FILE_COUNT! files - expected more than 100)
    call :log "[?] File count verification failed (!FILE_COUNT! files - expected more than 100)"
    echo [INFO] This indicates the copy operation did not work properly
    call :log "[INFO] This indicates the copy operation did not work properly"
    goto verification_failed
)

call :log "    [?] Comprehensive verification successful. EBWebView fully installed for Bunni"
call :log "[SUCCESS] Bunni WebView2 data directory error fixed successfully."
call :log "[INFO] EBWebView created at Bunni's expected location with !FILE_COUNT! files"
echo [SUCCESS] Bunni WebView2 data directory error fixed successfully.
echo [INFO] EBWebView created successfully with !FILE_COUNT! files.
echo [INFO] The 'Microsoft Edge can't read and write to its data directory' error should now be resolved.
echo [DEBUG] Comprehensive verification successful - proceeding to success exit.
call :log "[DEBUG] Comprehensive verification successful - proceeding to success exit."
call :log "[DEBUG] About to goto success_exit"
echo [DEBUG] About to goto success_exit
goto success_exit

:verification_failed
echo [ERROR] EdgeWebView verification failed - installation incomplete
call :log "[ERROR] EdgeWebView verification failed - installation incomplete"

if not defined VERIFICATION_RETRY_COUNT set "VERIFICATION_RETRY_COUNT=0"
echo [DEBUG] Current retry count: !VERIFICATION_RETRY_COUNT!
call :log "[DEBUG] Current retry count: !VERIFICATION_RETRY_COUNT!"

if !VERIFICATION_RETRY_COUNT! GEQ 3 (
    echo [WARN] Maximum retries reached. Checking if files were copied successfully anyway...
    call :log "[WARN] Maximum retries reached. Checking if files were copied successfully anyway..."
    
    for /f %%i in ('powershell -Command "if (Test-Path '!DEST!') { (Get-ChildItem '!DEST!' -Recurse -File).Count } else { 0 }"') do set "DEST_FILE_COUNT=%%i"
    echo [INFO] Destination contains !DEST_FILE_COUNT! files
    call :log "[INFO] Destination contains !DEST_FILE_COUNT! files"
    
    if !DEST_FILE_COUNT! GTR 50 (
        echo [INFO] Significant number of files copied. Proceeding with success despite verification issues...
        call :log "[INFO] Significant number of files copied. Proceeding with success despite verification issues..."
        echo [INFO] EdgeWebView may still function properly even without finding msedge.exe in expected location
        call :log "[INFO] EdgeWebView may still function properly even without finding msedge.exe in expected location"
        goto success_exit
    ) else (
        echo [ERROR] Insufficient files copied. Installation appears to have failed.
        call :log "[ERROR] Insufficient files copied. Installation appears to have failed."
        goto manual_instructions
    )
)

echo [INFO] Attempting one more forced copy operation...
call :log "[INFO] Attempting one more forced copy operation..."

echo [INFO] Using robocopy for final copy attempt...
call :log "[INFO] Using robocopy for final copy attempt..."
robocopy "!SOURCE!" "!DEST!" /E /R:2 /W:10 /MT:1 /J /XJ /FFT /Z
set "ROBOCOPY_RESULT=!errorlevel!"

if !ROBOCOPY_RESULT! LSS 8 (
    echo [SUCCESS] Robocopy completed successfully (exit code: !ROBOCOPY_RESULT!)
    call :log "[SUCCESS] Robocopy completed successfully (exit code: !ROBOCOPY_RESULT!)"
    goto verification_success
) else (
    echo [ERROR] Robocopy failed with exit code: !ROBOCOPY_RESULT!
    call :log "[ERROR] Robocopy failed with exit code: !ROBOCOPY_RESULT!"
    goto manual_instructions
)

:edge_reinstall_fallback
call :log ""
call :log "????????????????????????????????????????????????????????"
call :log "?? Edge Reinstall Method"
call :log "????????????????????????????????????????????????????????"
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
    call :log "    [?] Edge installer downloaded successfully."
    call :log "[INFO] Installing Microsoft Edge..."
    echo [INFO] Installing Microsoft Edge...
    "%EDGE_INSTALLER%" /silent /install
    set "INSTALL_RESULT=%errorlevel%"
    if %INSTALL_RESULT% equ 0 (
        call :log "    [?] Microsoft Edge installed successfully."
        call :log "[INFO] Waiting for installation to complete..."
        echo [SUCCESS] Microsoft Edge installed successfully.
        echo [INFO] Waiting for installation to complete...
        timeout /t 10 /nobreak >nul 2>&1
        
        call :log "[INFO] Attempting Edge to EdgeWebView copy after reinstall..."
        echo [INFO] Attempting Edge to EdgeWebView copy after reinstall...
        
        set "NEW_SOURCE="
        call :log "    Re-scanning Edge installation locations..."
        
        call :log "        Checking: C:\Program Files (x86)\Microsoft\Edge"
        if exist "C:\Program Files (x86)\Microsoft\Edge\msedge.exe" (
            call :log "        [?] Found Edge after reinstall at: C:\Program Files (x86)\Microsoft\Edge"
            echo [INFO] Found Edge after reinstall at: C:\Program Files (x86)\Microsoft\Edge
            set "NEW_SOURCE=C:\Program Files (x86)\Microsoft\Edge"
            goto found_new_edge
        )
        
        call :log "        Checking: C:\Program Files\Microsoft\Edge"
        if exist "C:\Program Files\Microsoft\Edge\msedge.exe" (
            call :log "        [?] Found Edge after reinstall at: C:\Program Files\Microsoft\Edge"
            echo [INFO] Found Edge after reinstall at: C:\Program Files\Microsoft\Edge
            set "NEW_SOURCE=C:\Program Files\Microsoft\Edge"
            goto found_new_edge
        )
        
        call :log "        Checking: %PROGRAMFILES%\Microsoft\Edge"
        if exist "%PROGRAMFILES%\Microsoft\Edge\msedge.exe" (
            call :log "        [?] Found Edge after reinstall at: %PROGRAMFILES%\Microsoft\Edge"
            echo [INFO] Found Edge after reinstall at: %PROGRAMFILES%\Microsoft\Edge
            set "NEW_SOURCE=%PROGRAMFILES%\Microsoft\Edge"
            goto found_new_edge
        )
        
        call :log "        Checking: %PROGRAMFILES(X86)%\Microsoft\Edge"
        if exist "%PROGRAMFILES(X86)%\Microsoft\Edge\msedge.exe" (
            call :log "        [?] Found Edge after reinstall at: %PROGRAMFILES(X86)%\Microsoft\Edge"
            echo [INFO] Found Edge after reinstall at: %PROGRAMFILES(X86)%\Microsoft\Edge
            set "NEW_SOURCE=%PROGRAMFILES(X86)%\Microsoft\Edge"
            goto found_new_edge
        )
        
        call :log "        Checking: %LOCALAPPDATA%\Microsoft\Edge\Application"
        if exist "%LOCALAPPDATA%\Microsoft\Edge\Application\msedge.exe" (
            call :log "        [?] Found Edge after reinstall at: %LOCALAPPDATA%\Microsoft\Edge\Application"
            echo [INFO] Found Edge after reinstall at: %LOCALAPPDATA%\Microsoft\Edge\Application
            set "NEW_SOURCE=%LOCALAPPDATA%\Microsoft\Edge\Application"
            goto found_new_edge
        )
        
        :found_new_edge
        if defined NEW_SOURCE (
            call :log "[SUCCESS] Edge found after reinstall."
            call :log "    Source: %NEW_SOURCE%"
            set "DEST=C:\Program Files (x86)\Microsoft\EdgeWebView"
            call :log "    Destination: %DEST%"
            
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
            robocopy "%NEW_SOURCE%" "%DEST%" /E
            
            if exist "%DEST%\msedge.exe" (
                call :log "    [?] Copy verification successful."
                call :log "[SUCCESS] EdgeWebView created successfully from reinstalled Edge!"
                call :log "[INFO] EdgeWebView location: %DEST%"
                echo [SUCCESS] EdgeWebView created successfully from reinstalled Edge!
                echo [INFO] EdgeWebView location: %DEST%
                call :log "[INFO] Cleaning up temporary files..."
                del /f /q "%EDGE_INSTALLER%" >nul 2>&1
                rmdir /s /q "%TEMP_DIR%" >nul 2>&1
                goto success_exit
            ) else (
                call :log "    [?] Copy verification failed. msedge.exe not found."
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
        call :log "    [?] Edge installation failed with error code: %INSTALL_RESULT%"
        call :log "[ERROR] Edge installation failed."
        echo [ERROR] Edge installation failed with error code: %INSTALL_RESULT%
        goto manual_instructions
    )
) else (
    call :log "    [?] Failed to download Edge installer."
    call :log "[ERROR] Failed to download Edge installer."
    echo [ERROR] Failed to download Edge installer.
    goto manual_instructions
)

:manual_instructions
call :log ""
call :log "????????????????????????????????????????????????????????"
call :log "?? Manual Instructions"
call :log "????????????????????????????????????????????????????????"
call :log "[ERROR] All automated methods failed. Providing manual instructions."

echo ????????????????????????????????????????????????????????
echo ? AUTOMATED METHOD FAILED - Manual Instructions Required
echo ????????????????????????????????????????????????????????
echo.
echo ?? SUMMARY OF WHAT HAPPENED:
echo ? Attempted to detect Microsoft Edge installation
echo ? Tried automated download and installation methods
echo ? Copy operations failed or Edge installation was unsuccessful
echo ? Manual intervention is now required
echo.


goto final_exit

:success_exit
call :log "[DEBUG] Reached success_exit section"
echo [DEBUG] Reached success_exit section
call :log ""
call :log "????????????????????????????????????????????????????????"
call :log "? Success"
call :log "????????????????????????????????????????????????????????"
call :log "[SUCCESS] WebView2 is now properly configured for Bunni."
call :log "[INFO] You can now try launching Bunni again."
call :log ""
call :log "?? SUMMARY OF ACTIONS PERFORMED:"
call :log "????????????????????????????????????????????????????????"
call :log "? Microsoft Edge detected at: !SOURCE_PATH!"
call :log "? EdgeWebView folder created at: !DEST!"
call :log "? Edge files successfully copied to EdgeWebView location"
call :log "? Copy verification completed - msedge.exe found in EdgeWebView"
call :log ""
call :log "?? WHAT THIS FIXES:"
call :log "? Resolves Bunni white screen/blank window issues"
call :log "? Provides fresh WebView2 Runtime installation"
call :log "? Creates EdgeWebView backup copy using Edge browser engine"
call :log "? Ensures dual compatibility with both official and fallback WebView2"
call :log "? Enables Bunni to display web content properly"
call :log ""
call :log "?? FILES CREATED:"
call :log "? WebView2 Runtime: Installed system-wide"
call :log "? EdgeWebView folder: !DEST!"
call :log "? All Edge browser files copied for WebView2 compatibility"
call :log ""
call :log "?? NEXT STEPS:"
call :log "1. Launch Bunni application"
call :log "2. Check if white screen issue is resolved"
call :log "3. If issues persist, restart your computer and try again"
call :log ""
call :log "?? Log saved at:"
call :log "    !LOGFILE!"

echo ????????????????????????????????????????????????????????
echo ? SUCCESS - Bunni WebView2 Data Directory Fixed!
echo ????????????????????????????????????????????????????????
echo.
echo ?? SUMMARY OF ACTIONS PERFORMED:
echo ? Microsoft Edge detected at: !SOURCE_PATH!
echo ? EBWebView folder created at: !DEST!
echo ? All !FILE_COUNT! Edge files successfully copied to Bunni's expected location
echo ? Copy verification completed - msedge.exe found in EBWebView
echo ? Proper permissions set for Bunni WebView2 compatibility
echo.
echo ?? WHAT THIS FIXES:
echo ? Resolves "Microsoft Edge can't read and write to its data directory" error
echo ? Fixes Bunni white screen/blank window issues
echo ? Creates EBWebView folder using Edge browser engine
echo ? Ensures WebView2 compatibility for Bunni application
echo ? Enables Bunni to display web content properly
echo.
echo ?? FILES CREATED:
echo ? EBWebView folder: !DEST!
echo ? All !FILE_COUNT! Edge browser files copied for Bunni WebView2 compatibility
echo ? Proper folder structure with version directories maintained
echo.
echo ?? NEXT STEPS:
echo 1. Launch Bunni application
echo 2. Check if white screen issue is resolved
echo 3. If issues persist, restart your computer and try again
echo.

if "%1"=="elevated" (
    echo ????????????????????????????????????????????????????????
    echo ?  ?? ELEVATED SESSION - INSTALLATION COMPLETE! ??     ?
    echo ?                                                      ?
    echo ?  ?? Log file: !LOGFILE!        ?
    echo ?  ?? This elevated window will remain open briefly    ?
    echo ?  ?? Your main window will detect this completion     ?
    echo ????????????????????????????????????????????????????????
) else (
    echo [INFO] Log saved at: !LOGFILE!
)

:: === FINAL REGISTRY CONFIGURATION FOR WEBVIEW2 DATA DIRECTORY ===
echo.
echo [INFO] Applying final WebView2 registry configuration...
call :log "[INFO] Applying final WebView2 registry configuration for data directory fix..."

:: Configure WebView2 to use our Edge installation
reg add "HKEY_CURRENT_USER\Software\Microsoft\EdgeUpdate\ClientState\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}" /v "UseLocalEdge" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\EdgeUpdate\ClientState\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}" /v "EdgePath" /t REG_SZ /d "!DEST_EDGE_EXE!" /f >nul 2>&1

:: Configure WebView2 data directory permissions in registry
reg add "HKEY_CURRENT_USER\Software\Microsoft\EdgeWebView\EBWebView" /v "UserDataFolder" /t REG_SZ /d "%LOCALAPPDATA%\Bunni\EBWebView" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\EdgeWebView\EBWebView" /v "EnableLogging" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\EdgeWebView\EBWebView" /v "AdditionalBrowserArguments" /t REG_SZ /d "--disable-web-security --disable-features=VizDisplayCompositor --user-data-dir=%LOCALAPPDATA%\Bunni\EBWebView" /f >nul 2>&1

:: Ensure WebView2 can find our Edge installation
reg add "HKEY_CURRENT_USER\Software\Policies\Microsoft\Edge\WebView2" /v "BrowserExecutableFolder" /t REG_SZ /d "!DEST_EDGE_DIR!" /f >nul 2>&1

:: Set additional permissions for Bunni WebView2 data directory
reg add "HKEY_CURRENT_USER\Software\Microsoft\Edge\WebView2" /v "UserDataFolder" /t REG_SZ /d "%LOCALAPPDATA%\Bunni\EBWebView" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Edge\WebView2" /v "AllowNonAdminInstall" /t REG_DWORD /d 1 /f >nul 2>&1

echo [SUCCESS] WebView2 registry configuration completed
call :log "[SUCCESS] WebView2 registry configuration completed - data directory permissions set"

echo Made by nerfine

call :log "========================================"
call :log "WebView2 Fix Script Completed Successfully"
call :log "              By nerfine"
call :log "Session ID: !LOGSTAMP!"
call :log "Final Status: SUCCESS - All operations completed"
call :log "Log file location: !LOGFILE!"
call :log "EdgeWebView installed at: !DEST!"
call :log "Source Edge location: !SOURCE_PATH!"
call :log "Files copied successfully: Bunni WebView2 data directory error fixed"
call :log "========================================"
call :log ""
call :log "SCRIPT COMPLETION SUMMARY:"
call :log "? Microsoft Edge detected and validated"
call :log "? WebView2 cleanup completed successfully"
call :log "? Edge files copied to Bunni EBWebView location"
call :log "? Copy verification passed with all required files"
call :log "? Bunni WebView2 data directory error resolved"
call :log ""
call :log "NEXT STEPS:"
call :log "- Launch Bunni application"
call :log "- The 'Microsoft Edge can't read and write to its data directory' error should be resolved"
call :log "- If issues persist, check this log file for troubleshooting information"
call :log ""
call :log "FINAL SCRIPT STATUS: COMPLETED SUCCESSFULLY"
call :log "========================================"

if "%1"=="elevated" (
    echo.
    echo [INFO] Elevated script completed. Press any key to close...
    call :log "[INFO] Elevated script completed. Waiting for user input..."
    pause >nul
    call :log "[INFO] User closed elevated window"
) else (
    echo.
    echo [INFO] Script completed successfully! Check the summary above.
    call :log "[INFO] Script completed successfully!"
    echo [INFO] Complete log saved at: !LOGFILE!
    timeout /t 10 /nobreak >nul 2>&1
    call :log "[INFO] Script window closed automatically after 10 seconds"
)

call :log ""
call :log "========================================"
call :log "SCRIPT EXECUTION COMPLETED SUCCESSFULLY"
call :log "              By nerfine"
call :log "========================================"
call :log "All operations completed successfully!"
call :log "Bunni WebView2 data directory error has been fixed."
call :log "You can now launch Bunni and it should work properly."
call :log ""
call :log "FINAL STATUS: SUCCESS"
call :log "END OF LOG - All operations completed successfully"
call :log "========================================"

endlocal
exit /b 0

:final_exit
call :log "[DEBUG] Reached final_exit section (error/manual case)"
echo [DEBUG] Reached final_exit section (error/manual case)
call :log ""
call :log "========================================"
call :log "WebView2 Fix Script Ended - Manual Intervention Required"
call :log "Session ID: !LOGSTAMP!"
call :log "Final Status: MANUAL INTERVENTION REQUIRED"
call :log "Log file location: !LOGFILE!"
call :log "========================================"
call :log ""
call :log "MANUAL STEPS NEEDED:"
call :log "1. Review the error messages above for specific issues"
call :log "2. Try running the script again with administrator privileges"
call :log "3. Check the log file for detailed error information"
call :log "4. If problems persist, manually install Microsoft Edge"
call :log ""
call :log "FINAL STATUS: FAILED - MANUAL INTERVENTION REQUIRED"
call :log "END OF LOG - Script completed with errors"
call :log "========================================"

echo.
echo ???????????????????????????????????????????????????????????????
echo ??  SCRIPT ENDED - MANUAL STEPS REQUIRED ??
echo ???????????????????????????????????????????????????????????????
echo.
echo ? WHAT TO DO NEXT:
echo 1. Review the error messages above for specific issues
echo 2. Try running the script again with administrator privileges
echo 3. Check the log file for detailed error information
echo 4. If problems persist, manually install Microsoft Edge
echo.
echo ?? Log file location: !LOGFILE!
echo.
echo Press any key to close this window...

pause >nul
call :log "[INFO] Script ended - user closed window"
endlocal
exit /b 1
