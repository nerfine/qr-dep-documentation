```markdown
#  `.qr-dep` Support Instructions

This guide is for the **support team** assisting users with the `.qr-dep` installer.

---

##  Running the Installer

When users run the `.bat` file from the `.qr-dep` directory:

1. A **log file** will be created at:

```

%temp%\batch\_installer

```

2. The log file will be named something like:

```

depinstaller\_XXXXXXXX\_XXXXXX.log

```

 **Ask users to send this log file in the support chat.** It helps us troubleshoot quickly.

---

## Common Issue: Winget Not Found

If users see this error:

```

\[ERROR] Winget not found. Please install it from the Microsoft Store.

````

### Step 1: Download Required Files (ALL 3)

They must try to download **all three files**, even if some do not install properly:

- [Microsoft.VCLibs.x64.14.00.Desktop.appx](https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx)  
- [Microsoft.UI.Xaml 2.7.0 Package](https://www.nuget.org/api/v2/package/Microsoft.UI.Xaml/2.7.0)  
- [App Installer (includes Winget)](https://aka.ms/getwinget)  

---

###  Step 2: Verify Winget Installation

1. Open **PowerShell as Administrator**.
2. Run:

   ```powershell
   winget --version
````

*  If it outputs a version number → Winget is installed correctly.
*  If not, verify the user installed **App Installer** from the link above.

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

* This file is located in the same directory as the main installer.

---

## Need Help?

If you have questions or need further assistance, please reach out in the support chat.

*Generated with ❤️ by the nerfine*
