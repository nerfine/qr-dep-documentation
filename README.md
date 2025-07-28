
# `.qr-dep` Support Instructions

This guide is for the **support team** assisting users with the `.qr-dep` installer.

## 📋 Table of Contents

### 🚀 Getting Started
- [Running the Installer](#running-the-installer)

### ⚠️ Common Issues
- [Winget Not Found](#common-issue-winget-not-found)
  - [Step 1: Download Required Files (ALL 3)](#step-1-download-required-files-all-3)
  - [Step 2: Verify Winget Installation](#step-2-verify-winget-installation)
  - [Step 3: Rerun the .bat Installer](#step-3-rerun-the-bat-installer)
  - [Still Not Working?](#still-not-working)
- [WebView2 Installation Error - 0x80040c01](#issue-webview2-installation-error---0x80040c01)
- [Bunni Shows White Screen or Won't Load](#issue-bunni-shows-white-screen-or-wont-load)

### 🔧 Dependency Installation Issues
- [.NET Desktop Runtime Installation Fails](#issue-net-desktop-runtime-installation-fails)
- [Visual C++ Redistributable Installation Fails](#issue-visual-c-redistributable-installation-fails)
- [DirectX Runtime Installation Problems](#issue-directx-runtime-installation-problems)
- [.NET Framework 4.8.1 Installation Problems](#issue-net-framework-481-installation-problems)
- [Script Requires Admin Rights](#issue-script-requires-admin-rights)
- [Antivirus Interference](#issue-antivirus-interference)
- [Network/Firewall Problems](#issue-networkfirewall-problems)
- [Corrupted Downloads](#issue-corrupted-downloads)
- [Windows Updates Required](#issue-windows-updates-required)

### 🩺 Advanced Troubleshooting
- [Troubleshooting Flowchart](#troubleshooting-flowchart)
- [Emergency Fallback: Complete Manual Installation](#emergency-fallback-complete-manual-installation)
- [Advanced Troubleshooting Commands](#advanced-troubleshooting-commands)

### 📖 Manual Installation Guide
- [Option 2: Manual Dependency Installation](#option-2-manual-dependency-installation)

### 📞 Support Resources
- [Quick Support Reference Card](#quick-support-reference-card)
- [Need Help?](#need-help)

═══════════════════════════════════════════════════════════════════════

## Running the Installer

When users run the `.bat` file from the `.qr-dep` directory:

1. A **log file** will be created at (access by pressing **WIN + R**):

```
%temp%\batch_installer
```

2. The log file will be named something like:

```
depinstaller_XXXXXXXX_XXXXXX.log
```

**Ask users to send this log file in the support chat.** It helps us troubleshoot quickly.

═══════════════════════════════════════════════════════════════════════

## Common Issue: Winget Not Found

If users see this error:

```
[ERROR] Winget not found. Please install it from the Microsoft Store.
```

### Step 1: Download Required Files (ALL 3)

They must try to download **all three files**, even if some do not install properly:

- <https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx>  
- <https://www.nuget.org/api/v2/package/Microsoft.UI.Xaml/2.7.0>  
- <https://aka.ms/getwinget>  

### Step 2: Verify Winget Installation

1. Open **PowerShell as Administrator**.
2. Run:

```powershell
winget --version
```

* If it outputs a version number → Winget is installed correctly.
* If not, verify the user installed **App Installer** from the link above.

### Step 3: Rerun the `.bat` Installer

After confirming Winget is installed, ask the user to **rerun the `.bat` file**.

────────────────────────────────────────────────────────────────────────────────

## Still Not Working?

If the problem persists even with Winget installed:

* Send the user the alternative batch file:

```
depinstaller-nowinget.bat
```

* You can find the `.bat` file above.

<details>
<summary>Premade Support Message</summary>

```
No worries! Winget isn't installed on your system. Here are two ways to fix this:

**Option 1 - Use Alternative Installer (Easiest):**
- Use the file `depinstaller-nowinget.bat` we just provided.
- Run that instead. It doesn't need Winget and should work fine

**Option 2 - Install Winget:**
1. Download these 3 files (try all of them even if some don't install):
   - <https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx>
   - <https://www.nuget.org/api/v2/package/Microsoft.UI.Xaml/2.7.0>
   - <https://aka.ms/getwinget>

2. After installing, open PowerShell as admin and run: `winget --version`
3. If you see a version number, try the original installer again

We'd recommend trying Option 1 first since it's simpler!
```

</details>

═══════════════════════════════════════════════════════════════════════

## Issue: WebView2 Installation Error - `0x80040c01`

### Description

Users sometimes encounter the following error during WebView2 installation:

```
0x80040c01
```

This error is often caused by problems with the **Evergreen bootstrapper** installer or corrupted WebView2 components.

### Workaround

1. **Use the full offline installer** instead of the bootstrapper:
   - Download from: <https://developer.microsoft.com/en-us/microsoft-edge/webview2/#download-section>
   - Choose the **Evergreen Standalone Installer** (usually around 90MB)

2. **Clear existing WebView2 installations**:
   - Go to Settings > Apps > Apps & features
   - Search for "Microsoft Edge WebView2"
   - Uninstall all WebView2 entries
   - Restart PC and install the standalone version

3. **Run Windows Update** before attempting installation again

<details>
<summary>Premade Support Message</summary>

```
Hi! That's a known WebView2 error. Here's the exact fix:

1. First, let's remove any existing WebView2:
   - Go to Settings > Apps & features
   - Search for "Microsoft Edge WebView2" 
   - Uninstall any WebView2 entries you find

2. Download the correct installer:
   - Go to: <https://developer.microsoft.com/en-us/microsoft-edge/webview2/>
   - Download "Evergreen Standalone Installer" (the big 90MB file, NOT the small bootstrapper)

3. Install it:
   - Right-click the downloaded file → "Run as administrator"
   - Let it install completely

4. Restart your PC and try launching Bunni again

This specific error (0x80040c01) is usually caused by the small bootstrapper installer failing. The standalone version almost always works!

Let us know if you run into any issues with these steps.
```

</details>

═══════════════════════════════════════════════════════════════════════

## Common Dependency Installation Issues

### Issue: .NET Desktop Runtime Installation Fails

**Error Messages:**
- "Installation failed with exit code [number]"
- ".NET Runtime installation returned error"

**Solutions:**
1. **Manual Installation:**
   - Download directly from: <https://dotnet.microsoft.com/en-us/download/dotnet/8.0/runtime>
   - Choose "Desktop Runtime x64" for most systems
   - Run as Administrator

2. **Clear .NET Cache:**
   ```cmd
   dotnet nuget locals all --clear
   ```

3. **Check Windows Version:**
   - .NET 8.0 requires Windows 10 version 1607 or later
   - Update Windows if necessary

<details>
<summary>Premade Support Message</summary>

```
The .NET Runtime installation hit an issue. Let's fix this:

**Quick Fix:**
1. Download .NET 8.0 Desktop Runtime manually from:
   <https://dotnet.microsoft.com/en-us/download/dotnet/8.0/runtime>

2. On that page, click "Download x64" under "Desktop Runtime 8.0.x"

3. Run the downloaded file as Administrator

4. Once installed, try launching Bunni again

**If that doesn't work:**
- Make sure Windows is up to date (Settings > Windows Update)
- .NET 8.0 requires Windows 10 version 1607 or newer

**To check your Windows version:**
- Press Win+R, type `winver`, press Enter
- You should see version 1607 or higher

Let us know if the manual installation works or if you need help with Windows updates!
```

</details>

••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••

### Issue: Visual C++ Redistributable Installation Fails

**Error Messages:**
- "VC++ installation failed"
- "Error installing Visual C++ Redistributable"
- "MSVCP140.dll was not found"
- "The code execution cannot proceed because MSVCP140.dll was not found"
- "VCRUNTIME140.dll is missing"
- "The code execution cannot proceed because VCRUNTIME140.dll was not found"

**Solutions:**
1. **Download latest versions manually:**
   - x64: <https://aka.ms/vs/17/release/vc_redist.x64.exe>
   - x86: <https://aka.ms/vs/17/release/vc_redist.x86.exe>

2. **Uninstall existing versions first:**
   - Go to Control Panel > Programs
   - Remove all "Microsoft Visual C++ Redistributable" entries
   - Restart and install fresh

3. **Use /repair flag:**
   ```cmd
   vc_redist.x64.exe /repair
   ```

<details>
<summary>Premade Support Message</summary>

```
The Visual C++ components failed to install, or you're getting an MSVCP140.dll or VCRUNTIME140.dll error. This is pretty common.

**If you're seeing "MSVCP140.dll was not found" or "VCRUNTIME140.dll is missing" error:**
This means Visual C++ Redistributable is missing or corrupted. The fix below will resolve this.

**Download both of these:**
1. VC++ x64: <https://aka.ms/vs/17/release/vc_redist.x64.exe>
2. VC++ x86: <https://aka.ms/vs/17/release/vc_redist.x86.exe>

**Before installing:**
- Go to Control Panel > Programs and Features
- Look for any "Microsoft Visual C++ Redistributable" entries
- Uninstall ALL of them (yes, all of them)
- Restart your PC

**Then install:**
1. Run the x64 version first (as Administrator)
2. Then run the x86 version (as Administrator)
3. Restart your PC again
4. Try launching Bunni

**If you still get DLL errors after installation:**
Try running the repair command:
- Open Command Prompt as Administrator
- Run: `vc_redist.x64.exe /repair`
- Then run: `vc_redist.x86.exe /repair`

This clean install approach usually fixes VC++ issues and MSVCP140.dll/VCRUNTIME140.dll errors.
```

</details>

••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••

### Issue: DirectX Runtime Installation Problems

**Error Messages:**
- "DirectX installation failed"
- "DXSETUP.exe not found"

**Solutions:**
1. **Manual DirectX Installation:**
   - Download: <https://www.microsoft.com/en-us/download/details.aspx?id=35>
   - Extract and run DXSETUP.exe as Administrator

2. **Check for Windows Updates:**
   - Modern Windows includes DirectX 12
   - Legacy DirectX components may still be needed

<details>
<summary>Premade Support Message</summary>

```
DirectX installation failed. This happens sometimes on older Windows systems. Let's install it manually:

**Download DirectX End-User Runtime:**
<https://www.microsoft.com/en-us/download/details.aspx?id=35>

**Installation steps:**
1. Download the file
2. Extract it to a folder (it's a self-extracting archive)
3. Open the extracted folder
4. Right-click on DXSETUP.exe → "Run as administrator"
5. Follow the installation wizard
6. Restart your PC
7. Try launching Bunni again

If you're on Windows 10/11, DirectX should already be built-in, so this error might indicate a deeper system issue. Let us know if the manual installation doesn't work!
```

</details>

••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••

### Issue: .NET Framework 4.8.1 Installation Problems

**Error Messages:**
- "Framework installation blocked"
- "Newer version already installed"

**Solutions:**
1. **Check current version:**
   ```cmd
   reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" /v Release
   ```

2. **If blocked by newer version:**
   - This is normal - newer versions include 4.8.1 features
   - Skip this component

3. **Manual installation:**
   - Download: <https://dotnet.microsoft.com/en-us/download/dotnet-framework/net481>

### Issue: Script Requires Admin Rights

**Error Messages:**
- "Access denied"
- "Administrative privileges required"

**Solutions:**
1. **Right-click the .bat file** → "Run as administrator"
2. **If UAC prompt doesn't appear:**
   ```cmd
   powershell -Command "Start-Process 'depinstaller_fixed.bat' -Verb runAs"
   ```

<details>
<summary>Premade Support Message</summary>

```
The script needs Administrator privileges to install system components. Here's how to run it properly:

**Method 1 (Easiest):**
1. Find the depinstaller_fixed.bat file
2. Right-click on it
3. Select "Run as administrator"
4. Click "Yes" when Windows asks for permission

**Method 2 (If right-click doesn't work):**
1. Open Command Prompt as Administrator:
   - Press Windows + X
   - Select "Command Prompt (Admin)" or "PowerShell (Admin)"
2. Navigate to where you saved the file
3. Run: `depinstaller_fixed.bat`

**Method 3 (Alternative):**
Open PowerShell and run:
`powershell -Command "Start-Process 'depinstaller_fixed.bat' -Verb runAs"`

The script needs admin rights because it's installing system-level components like .NET and Visual C++. This is normal and safe.
```

</details>

••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••

### Issue: Antivirus Interference

**Symptoms:**
- Downloads fail silently
- Installers deleted immediately
- "File not found" errors

**Solutions:**
1. **Temporarily disable real-time protection**
2. **Add exclusion for the temp directory:**
   ```
   %TEMP%\batch_installer\
   ```
3. **Whitelist the script location**

### Issue: Network/Firewall Problems

**Error Messages:**
- "Download failed"
- "Connection timeout"
- "Unable to connect to remote server"

**Solutions:**
1. **Check internet connection**
2. **Temporarily disable firewall/VPN**
3. **Use alternative download method:**
   - Download installers manually
   - Place in `%TEMP%\batch_installer\` folder
   - Rerun script

<details>
<summary>Premade Support Message</summary>

```
It looks like the downloads are failing due to network/firewall issues

**Quick fixes to try:**
1. Check your internet connection
2. Temporarily disable your VPN if you're using one
3. Try running the script again (sometimes it's just a temporary issue)

**If downloads keep failing, do manual installation:**

**Download these files manually:**
1. .NET 8 Desktop Runtime: <https://aka.ms/dotnet/8.0/windowsdesktop-runtime-win-x64.exe>
2. WebView2: <https://go.microsoft.com/fwlink/p/?LinkId=2124703>
3. VC++ x64: <https://aka.ms/vs/17/release/vc_redist.x64.exe>
4. VC++ x86: <https://aka.ms/vs/17/release/vc_redist.x86.exe>

**Installation order:**
1. Install .NET 8 Desktop Runtime first
2. Install WebView2
3. Install both VC++ packages
4. Restart your PC
5. Try launching Bunni

We know this is annoying, but some corporate firewalls or antivirus programs block the automatic downloads.
```

</details>

••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••

### Issue: Corrupted Downloads

**Error Messages:**
- "SHA256 validation failed"
- "File corrupted"
- "Invalid installer"

**Solutions:**
1. **Clear temp directory:**
   ```cmd
   del /f /q "%TEMP%\batch_installer\*"
   ```
2. **Rerun the script** to download fresh files
3. **Check disk space** - ensure at least 1GB free

<details>
<summary>Premade Support Message</summary>

```
The downloaded files got corrupted during the download. This happens sometimes with unstable internet connections. Let's fix this:

**Step 1: Clear the corrupted files**
1. Press Windows + R
2. Type: %TEMP%\batch_installer
3. Press Enter
4. Delete everything in that folder (or it might be empty already)

**Step 2: Try the installer again**
Run depinstaller_fixed.bat again. It will download fresh copies of everything.

**If corruption keeps happening:**
Your internet connection might be unstable. Try:
1. Using a different network (mobile hotspot, etc.)
2. Downloading one component at a time manually:
   - .NET 8: <https://aka.ms/dotnet/8.0/windowsdesktop-runtime-win-x64.exe>
   - WebView2: <https://go.microsoft.com/fwlink/p/?LinkId=2124703>
   - VC++ x64: <https://aka.ms/vs/17/release/vc_redist.x64.exe>
   - VC++ x86: <https://aka.ms/vs/17/release/vc_redist.x86.exe>

Let us know if the problem persists. We might need to send you a pre-packaged installer.
```

</details>

••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••

### Issue: Windows Updates Required

**Symptoms:**
- Multiple components fail to install
- "This update is not applicable" errors

**Solutions:**
1. **Run Windows Update:**
   - Settings > Update & Security > Windows Update
   - Install all available updates
   - Restart and try again

2. **Update Windows 10/11 to latest version**

<details>
<summary>Premade Support Message</summary>

```
Several components failed to install, which usually means your Windows needs updates. Modern software requires recent Windows updates to install properly.

**Here's how to update Windows:**

**Windows 11:**
1. Click Start → Settings
2. Go to "Windows Update" (left sidebar)
3. Click "Check for updates"
4. Install everything it finds
5. Restart when prompted
6. Repeat until no more updates are found

**Windows 10:**
1. Click Start → Settings
2. Go to "Update & Security"
3. Click "Windows Update"
4. Click "Check for updates"
5. Install everything it finds
6. Restart when prompted
7. Repeat until no more updates are found

**This process might take a while** (sometimes 30-60 minutes) and may require multiple restarts. Once your Windows is fully updated, try running depinstaller_fixed.bat again.

If you're on Windows 7 or 8, those are no longer supported by Microsoft, and modern software like Bunni may not work properly.
```

</details>

═══════════════════════════════════════════════════════════════════════

## Issue: Bunni Shows White Screen or Won't Load

### Description

Users may encounter a white screen, blank window, or completely unresponsive interface when launching Bunni. This is typically caused by missing or corrupted WebView2 components.

### Common Causes:
1. **WebView2 Runtime not installed** - Most common cause
2. **Corrupted WebView2 installation** - Partially installed or damaged
3. **Conflicting WebView2 versions** - Multiple versions causing conflicts
4. **Missing Visual C++ Redistributables** - Required by WebView2
5. **Outdated Windows version** - WebView2 requires specific Windows updates
6. **Antivirus blocking WebView2** - Some security software interferes

### Solutions:

**Method 1: Use the automated fix script**
1. Run `fix_webview2.bat` as Administrator
2. The script will automatically try multiple solutions
3. Restart your PC after completion

**Method 2: Manual WebView2 reinstallation**
1. **Remove existing WebView2:**
   - Go to Settings > Apps & features
   - Search for "Microsoft Edge WebView2"
   - Uninstall ALL WebView2 entries you find
   - Restart your PC

2. **Download and install fresh WebView2:**
   - Visit: <https://developer.microsoft.com/microsoft-edge/webview2/>
   - Download "Evergreen Standalone Installer" (90MB+ file)
   - Run as Administrator
   - Restart your PC

**Method 3: Check dependencies**
1. Ensure Visual C++ Redistributables are installed:
   - Download: <https://aka.ms/vs/17/release/vc_redist.x64.exe>
   - Download: <https://aka.ms/vs/17/release/vc_redist.x86.exe>
   - Install both as Administrator

2. Update Windows to latest version
3. Run Windows Update until no more updates available

**Method 4: Edge reinstall workaround (if WebView2 installers fail)**
1. Download and reinstall Microsoft Edge:
   - Go to: <https://www.microsoft.com/edge/download>
   - Download and install the latest version
   - Restart your PC after installation

2. Copy Edge folder to create EdgeWebView:
   - Navigate to: `C:\Program Files (x86)\Microsoft\`
   - Copy the entire `Edge` folder
   - Paste it in the same location
   - Rename the copied folder from `Edge - Copy` to `EdgeWebView`
   - Try launching Bunni again

**Method 5: Check for interfering software**
1. Temporarily disable antivirus real-time protection
2. Try launching Bunni
3. If it works, add Bunni to antivirus exclusions
4. Re-enable antivirus protection

<details>
<summary>Premade Support Message</summary>

```
Hi! If you're having a WebView2 issue. Here's how to fix it:

**Quick Fix - Try this first:**
1. We have an automated fix script called `fix_webview2.bat`
2. Right-click on it and select "Run as administrator"
3. Let it complete, then restart your PC
4. Try launching Bunni again

**After the script finishes, it will create a log file here:**

* Press **Win + R** and enter: `%TEMP%\webview2_fix\`
* Look for a file named something like: `webview2_fix_XXXXXXXX_XXXXXX.log`
* Please send **that log file** in the chat if the issue continues. It helps us troubleshoot.

**If that doesn't work, manual fix:**

**Step 1: Remove old WebView2**
1. Go to Settings > Apps & features
2. Search for "Microsoft Edge WebView2"
3. Uninstall EVERYTHING that shows up with "WebView2" in the name
4. Restart your PC

**Step 2: Install fresh WebView2**
1. Go to: <https://developer.microsoft.com/microsoft-edge/webview2/>
2. Download "Evergreen Standalone Installer" (the big 90MB+ file)
3. Right-click the downloaded file → "Run as administrator"
4. Let it install completely
5. Restart your PC again

**Step 3: Test Bunni**
Try launching Bunni now. It should load properly.

**If WebView2 installer fails, try the Edge workaround:**
1. Download and reinstall Microsoft Edge from: <https://www.microsoft.com/edge/download>
2. After installation, go to: C:\Program Files (x86)\Microsoft\
3. Copy the "Edge" folder and paste it in the same location
4. Rename the copied folder from "Edge - Copy" to "EdgeWebView"
5. Restart your PC and try Bunni again

**If you still get a white screen:**
- Make sure Windows is fully updated (Settings > Windows Update)
- Check if your antivirus is blocking Bunni (try disabling temporarily)
- Run our dependency installer: `depinstaller-nowinget.bat`

The white screen happens because Bunni uses WebView2 to display its interface, and when WebView2 is missing or broken, you just get a blank window.

Let us know if you need help with any of these steps!
```

</details>

═══════════════════════════════════════════════════════════════════════

## Troubleshooting Flowchart

When users report issues with `depinstaller_fixed.bat`, follow this diagnostic flow:

### Step 1: Check Basic Requirements
- [x] Windows 10/11 (version 1607+)
- [x] Admin rights (script auto-elevates)
- [x] Internet connection
- [x] At least 1GB free disk space

### Step 2: Identify the Failure Point
Ask user to find the **exact error message** in the log file:
```
%temp%\batch_installer\depinstaller_XXXXXXXX_XXXXXX.log
```

### Step 3: Match Error to Solution

| Error Contains | Issue Type | Quick Fix |
|----------------|------------|-----------|
| `Winget not found` | Missing Winget | Use `depinstaller-nowinget.bat` |
| `0x80040c01` | WebView2 Error | Use standalone WebView2 installer |
| `MSVCP140.dll` | Missing VC++ | Install Visual C++ Redistributable |
| `SHA256 validation failed` | Corrupted download | Clear temp folder, retry |
| `Access denied` | Permissions | Run as Administrator |
| `Download failed` | Network issue | Check firewall/antivirus |
| `Installation failed` | Component issue | Manual installation required |
| `White screen` or `Blank window` | WebView2 Issue | Run `fix_webview2.bat` or reinstall WebView2 |

### Step 4: Log File Analysis
Key sections to check in the log:
1. **Dependency Check Summary** - Shows what's missing
2. **Download attempts** - Network/corruption issues
3. **Installation results** - Component-specific failures
4. **Error codes** - Specific failure reasons

═══════════════════════════════════════════════════════════════════════

## Emergency Fallback: Complete Manual Installation

If the automated installer completely fails, provide users with this **complete manual installation guide**:

### Required Downloads (in order):
1. **.NET Framework 4.8.1**: <https://dotnet.microsoft.com/en-us/download/dotnet-framework/net481>
2. **.NET 8.0 Desktop Runtime**: <https://dotnet.microsoft.com/en-us/download/dotnet/8.0/runtime> (Choose "Desktop Runtime x64")
3. **Visual C++ 2015-2022 x64**: <https://aka.ms/vs/17/release/vc_redist.x64.exe>
4. **Visual C++ 2015-2022 x86**: <https://aka.ms/vs/17/release/vc_redist.x86.exe>
5. **WebView2 Runtime**: <https://developer.microsoft.com/en-us/microsoft-edge/webview2/> (Evergreen Standalone Installer)
6. **DirectX End-User Runtime**: <https://www.microsoft.com/en-us/download/details.aspx?id=35>

### Installation Order:
1. Install .NET Framework 4.8.1 first
2. Restart computer
3. Install .NET 8.0 Desktop Runtime
4. Install both Visual C++ redistributables (x64 then x86)
5. Install WebView2 Runtime
6. Install DirectX Runtime
7. Final restart

### Verification Steps:
After all installations:
```cmd
# Check .NET versions
dotnet --list-runtimes

# Check registry for components
reg query "HKLM\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64"
reg query "HKLM\SOFTWARE\Microsoft\EdgeUpdate\Clients\{F4A5B3DC-0E5D-4C0A-836E-4AD7EA73D1B2}"
```

<details>
<summary>Premade Support Message</summary>

```
The automatic installer is having multiple issues. Let's switch to completely manual installation:

**We need you to download and install these in this exact order:**

1. **.NET Framework 4.8.1** (if needed):
   <https://dotnet.microsoft.com/en-us/download/dotnet-framework/net481>

2. **Restart your PC** (important!)

3. **.NET 8.0 Desktop Runtime**:
   <https://dotnet.microsoft.com/en-us/download/dotnet/8.0/runtime>
   (Click "Download x64" under Desktop Runtime)

4. **Visual C++ x64**:
   <https://aka.ms/vs/17/release/vc_redist.x64.exe>

5. **Visual C++ x86**:
   <https://aka.ms/vs/17/release/vc_redist.x86.exe>

6. **WebView2 Runtime**:
   <https://developer.microsoft.com/en-us/microsoft-edge/webview2/>
   (Download "Evergreen Standalone Installer")

7. **DirectX Runtime**:
   <https://www.microsoft.com/en-us/download/details.aspx?id=35>

**Installation tips:**
- Run each installer as Administrator (right-click → Run as admin)
- Install them in the order listed above
- Restart your PC after installing .NET Framework
- Do a final restart after everything is installed

This manual approach bypasses all the automatic installer issues. Let us know if you run into problems with any specific component!
```

</details>

═══════════════════════════════════════════════════════════════════════

## Advanced Troubleshooting Commands

For technical support staff, these commands help diagnose issues:

### Check System Information:
```cmd
systeminfo | findstr /C:"OS Name" /C:"OS Version"
wmic os get Caption,Version,BuildNumber,OSArchitecture
```

### Check Installed Runtimes:
```cmd
dotnet --list-runtimes
reg query "HKLM\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" /v Release
```

### Check Available Disk Space:
```cmd
dir %TEMP% | find "bytes free"
```

### Manual Winget Installation Check:
```cmd
winget --version
Get-AppxPackage Microsoft.DesktopAppInstaller
```

### Clear All Temp Files:
```cmd
del /f /q "%TEMP%\batch_installer\*.*"
rmdir /s /q "%TEMP%\batch_installer"
```

═══════════════════════════════════════════════════════════════════════

## Option 2: Manual Dependency Installation

If the automatic dependency installer fails or the user prefers to install manually, provide them with the following official download links:

They must download and install **all** the following:

- <https://dotnet.microsoft.com/en-us/download/dotnet/8.0/runtime>  
- <https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist>  
- <https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist>  
- <https://developer.microsoft.com/en-us/microsoft-edge/webview2/>  
- <https://www.microsoft.com/en-us/download/details.aspx?id=35>  
- <https://dotnet.microsoft.com/en-us/download/dotnet-framework/net48>


## Option 2: Manual Dependency Installation (If Auto Installer Fails)

If the automatic `.bat` installer doesn't work, guide the user through manually installing dependencies:

Ask them to install **each** of the following files manually:

- <https://dotnet.microsoft.com/en-us/download/dotnet/8.0/runtime>
- <https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist>
- <https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist>
- <https://developer.microsoft.com/en-us/microsoft-edge/webview2/>
- <https://www.microsoft.com/en-us/download/details.aspx?id=35>
- <https://dotnet.microsoft.com/en-us/download/dotnet-framework/net48>

Ask the user to restart their PC after installing everything. If they still experience issues, continue troubleshooting in chat.

<details>
<summary>Premade Message for Option 2 Support</summary>

Support staff can use the following message when sending users instructions for manual dependency installation:

```

Hi! Since you request manual installtion.

Here are the links to each one. Make sure to install **all of them**, even if you think they’re already on your PC:

* .NET Runtime 8.0: <https://dotnet.microsoft.com/en-us/download/dotnet/8.0/runtime>
* Visual C++ Redistributable (x64): <https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist>
* Visual C++ Redistributable (x86): <https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist>
* Microsoft Edge WebView2 Runtime: <https://developer.microsoft.com/en-us/microsoft-edge/webview2/>
* DirectX End-User Runtime: <https://www.microsoft.com/en-us/download/details.aspx?id=35>
* .NET Framework 4.8: <https://dotnet.microsoft.com/en-us/download/dotnet-framework/net48>

After installing all of them, restart your PC and try launching Bunni again.

Let us know if you run into any issues!

```

</details>


### Important:
- Make sure users **restart their PC** after installing all the dependencies  
- They should test Bunni again only **after the restart**

═══════════════════════════════════════════════════════════════════════

## Quick Support Reference Card

### Most Common Issues & Instant Solutions:

| User Says... | Quick Response |
|-------------|----------------|
| "WebView2 error 0x80040c01" | Use standalone WebView2 installer from Microsoft |
| "Bunni shows white screen" or "Bunni won't load" | Run `fix_webview2.bat` or reinstall WebView2 |
| "Winget not found" | Use `depinstaller-nowinget.bat` instead |
| "Access denied" | Run as Administrator (right-click → Run as admin) |
| "Download failed" | Check antivirus/firewall, clear temp folder |
| "Installation failed" | Get log file from `%temp%\batch_installer` |

### Emergency Contacts & Resources:
- **Alternative Installer**: `depinstaller-nowinget.bat`
- **Log Location**: `%temp%\batch_installer\depinstaller_*.log`
- **Manual Downloads**: All links provided in Option 2 section above

═══════════════════════════════════════════════════════════════════════

## Need Help?

If you have questions or need further assistance, please reach out in the support chat.

*Generated with ❤️ by the nerfine*
