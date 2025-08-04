## 🔧 BUNNI "This app can't run on your PC" - QUICK FIX GUIDE

### **Problem:** Getting "This app can't run on your PC" error when trying to run Bunni.exe

### **Solution Steps:**

#### **Method 1: Simple File Unblock (Try this first)**
1. Right-click on `Bunni.exe` in the `x1e600` folder
2. Select "Properties"
3. At the bottom, check if there's a "Security" section with "Unblock" checkbox
4. If yes, check "Unblock" and click "OK"
5. Try running Bunni.exe again

#### **Method 2: PowerShell Unblock**
1. Open PowerShell as Administrator
2. Navigate to your Bunni folder: `cd "C:\Users\YourUsername\Desktop\Bunni"`
3. Run: `Unblock-File "x1e600\Bunni.exe"`
4. Try running Bunni.exe again

#### **Method 3: Use the Automated Fix Scripts**
Run one of these batch files in your Bunni folder:
- `fix_bunni_compatibility.bat` - Comprehensive compatibility fixes
- `fix_bunni_unsigned.bat` - Specific fix for unsigned executable issues
- `fix_webview2.bat` - Complete WebView2 and compatibility solution

#### **Method 4: Manual Windows Defender Exclusion**
1. Open Windows Security (search for it in Start menu)
2. Go to "Virus & threat protection"
3. Click "Manage settings" under "Virus & threat protection settings"
4. Scroll down to "Exclusions" and click "Add or remove exclusions"
5. Click "Add an exclusion" → "Folder"
6. Browse and select your Bunni folder (entire folder)
7. Try running Bunni.exe again

#### **Method 5: Run as Administrator**
1. Right-click on `Bunni.exe`
2. Select "Run as administrator"
3. Click "Yes" if UAC prompt appears

#### **Method 6: Compatibility Mode**
1. Right-click on `Bunni.exe`
2. Select "Properties"
3. Go to "Compatibility" tab
4. Check "Run this program in compatibility mode for:"
5. Select "Windows 8" or "Windows 7"
6. Check "Run this program as an administrator"
7. Click "OK" and try running Bunni.exe

### **If None of These Work:**

#### **Check System Requirements:**
- Windows 10/11 (64-bit)
- .NET Framework 4.8 or higher
- Visual C++ Redistributable 2019+
- At least 2GB RAM
- Antivirus exclusions for Bunni folder

#### **Advanced Troubleshooting:**
1. **Restart your computer** after applying fixes
2. **Temporarily disable antivirus** and try running Bunni
3. **Check Windows Event Viewer** for specific error details:
   - Press Win+R, type `eventvwr.msc`
   - Go to Windows Logs → Application
   - Look for errors related to Bunni.exe
4. **Re-download Bunni** - the file might be corrupted

### **Common Causes:**
- Windows SmartScreen blocking unsigned executables
- Antivirus false positive detection
- Missing runtime dependencies (.NET, Visual C++)
- Corrupted download
- Insufficient permissions
- Windows Defender quarantine

### **Contact Support:**
If you're still having issues after trying all methods:
1. Check the log files created by the fix scripts
2. Note the exact error message
3. Include your Windows version (Settings → System → About)
4. Contact Bunni support with this information

---
**Created by nerfine - Bunni Compatibility Fix Suite**
