
# `.qr-dep` Support Instructions

This guide is for the **support team** assisting users with the `.qr-dep` installer.

---

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

---

## Common Issue: Winget Not Found

If users see this error:

```
[ERROR] Winget not found. Please install it from the Microsoft Store.
```

### Step 1: Download Required Files (ALL 3)

They must try to download **all three files**, even if some do not install properly:

- [Microsoft.VCLibs.x64.14.00.Desktop.appx](https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx)  
- [Microsoft.UI.Xaml 2.7.0 Package](https://www.nuget.org/api/v2/package/Microsoft.UI.Xaml/2.7.0)  
- [App Installer (includes Winget)](https://aka.ms/getwinget)  

---

### Step 2: Verify Winget Installation

1. Open **PowerShell as Administrator**.
2. Run:

```powershell
winget --version
```

* If it outputs a version number → Winget is installed correctly.
* If not, verify the user installed **App Installer** from the link above.

---

### Step 3: Rerun the `.bat` Installer

After confirming Winget is installed, ask the user to **rerun the `.bat` file**.

---

## Still Not Working?

If the problem persists even with Winget installed:

* Send the user the alternative batch file:

```
depinstaller-nowinget.bat
```

* You can find the `.bat` file above.

---

## Issue: WebView2 Installation Error - `0x80040c01`

### Description

Users sometimes encounter the following error during WebView2 installation:

```
0x80040c01
```

This error is often caused by problems with the **Evergreen bootstrapper** installer available here:

https://go.microsoft.com/fwlink/p/?LinkId=2124704

---

### Workaround

Instead of using the small bootstrapper, try using the **full offline installer** for WebView2:

* Download from the official Microsoft WebView2 page:  
  https://developer.microsoft.com/en-us/microsoft-edge/webview2/#download-section

* Choose the **Evergreen Standalone Installer** (usually around 90MB), not the smaller bootstrapper.

---

## Option 2: Manual Dependency Installation

If the automatic dependency installer fails or the user prefers to install manually, provide them with the following official download links:

They must download and install **all** the following:

- [.NET Runtime 8.0](https://dotnet.microsoft.com/en-us/download/dotnet/8.0/runtime)  
- [Visual C++ Redistributable (x64)](https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist)  
- [Visual C++ Redistributable (x86)](https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist)  
- [Microsoft Edge WebView2 Runtime](https://developer.microsoft.com/en-us/microsoft-edge/webview2/)  
- [DirectX End-User Runtime](https://www.microsoft.com/en-us/download/details.aspx?id=35)  
- [.NET Framework 4.8](https://dotnet.microsoft.com/en-us/download/dotnet-framework/net48)


## Option 2: Manual Dependency Installation (If Auto Installer Fails)

If the automatic `.bat` installer doesn't work, guide the user through manually installing dependencies:

Ask them to install **each** of the following files manually:

- [.NET Runtime 8.0](https://dotnet.microsoft.com/en-us/download/dotnet/8.0/runtime)
- [Visual C++ Redistributable (x64)](https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist)
- [Visual C++ Redistributable (x86)](https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist)
- [Microsoft Edge WebView2 Runtime](https://developer.microsoft.com/en-us/microsoft-edge/webview2/)
- [DirectX End-User Runtime](https://www.microsoft.com/en-us/download/details.aspx?id=35)
- [.NET Framework 4.8](https://dotnet.microsoft.com/en-us/download/dotnet-framework/net48)

Ask the user to restart their PC after installing everything. If they still experience issues, continue troubleshooting in chat.

<details>
<summary>💬 Premade Message for Option 2 Support</summary>

Support staff can use the following message when sending users instructions for manual dependency installation:

```

Hi! Since the automatic installer didn't work on your system, please try installing the required dependencies manually.

Here are the links to each one. Make sure to install **all of them**, even if you think they’re already on your PC:

* .NET Runtime 8.0: [https://dotnet.microsoft.com/en-us/download/dotnet/8.0/runtime](https://dotnet.microsoft.com/en-us/download/dotnet/8.0/runtime)
* Visual C++ Redistributable (x64): [https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist](https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist)
* Visual C++ Redistributable (x86): [https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist](https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist)
* Microsoft Edge WebView2 Runtime: [https://developer.microsoft.com/en-us/microsoft-edge/webview2/](https://developer.microsoft.com/en-us/microsoft-edge/webview2/)
* DirectX End-User Runtime: [https://www.microsoft.com/en-us/download/details.aspx?id=35](https://www.microsoft.com/en-us/download/details.aspx?id=35)
* .NET Framework 4.8: [https://dotnet.microsoft.com/en-us/download/dotnet-framework/net48](https://dotnet.microsoft.com/en-us/download/dotnet-framework/net48)

After installing all of them, restart your PC and try launching Bunni again.

Let us know if you run into any issues!

```

</details>


### Important:
✅ Make sure users **restart their PC** after installing all the dependencies.  
✅ They should test Bunni again only **after the restart**.

---

## Need Help?

If you have questions or need further assistance, please reach out in the support chat.

*Generated with ❤️ by the nerfine*
