# Flutter Installation Path Information

## Flutter is Not Currently Installed

Flutter is not found in your system PATH or common installation locations.

## Recommended Installation Path

For Windows, the recommended Flutter installation path is:

```
C:\src\flutter
```

**Full path to Flutter executable:**
```
C:\src\flutter\bin\flutter.bat
```

## Alternative Installation Locations

Common Flutter installation paths on Windows:
- `C:\src\flutter` (Recommended - Google's recommendation)
- `C:\flutter`
- `%USERPROFILE%\flutter` (e.g., `C:\Users\Shawn\flutter`)
- `%LOCALAPPDATA%\flutter` (e.g., `C:\Users\Shawn\AppData\Local\flutter`)

## Installation Steps

1. **Choose an installation location** (recommended: `C:\src\flutter`)

2. **Download Flutter:**
   - Go to: https://docs.flutter.dev/get-started/install/windows
   - Download the Flutter SDK zip file
   - Extract to your chosen location

3. **Add to PATH:**
   - Add `C:\src\flutter\bin` to your system PATH
   - Or set `FLUTTER_ROOT` environment variable to `C:\src\flutter`

4. **Verify installation:**
   ```powershell
   flutter --version
   flutter doctor
   ```

## Setting Up PATH

### Option 1: System Environment Variables (Permanent)
1. Right-click "This PC" → Properties
2. Advanced system settings → Environment Variables
3. Under "System variables", edit "Path"
4. Add: `C:\src\flutter\bin`
5. Click OK

### Option 2: PowerShell (Current Session)
```powershell
$env:Path += ";C:\src\flutter\bin"
```

### Option 3: Set FLUTTER_ROOT
```powershell
[System.Environment]::SetEnvironmentVariable("FLUTTER_ROOT", "C:\src\flutter", "User")
```

## After Installation

Once Flutter is installed, you can verify it's working:
```powershell
flutter --version
flutter doctor
```

## For This Project

The Flutter frontend is located at:
```
C:\CodeDev\bootyhunterv1\frontend
```

Once Flutter is installed, you can:
```powershell
cd C:\CodeDev\bootyhunterv1\frontend
flutter pub get
flutter run
```

## Quick Install Script

If you want to install Flutter automatically, you can use:
```powershell
# Download and extract Flutter
$flutterPath = "C:\src\flutter"
New-Item -ItemType Directory -Path "C:\src" -Force | Out-Null
Invoke-WebRequest -Uri "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.5-stable.zip" -OutFile "$env:TEMP\flutter.zip"
Expand-Archive -Path "$env:TEMP\flutter.zip" -DestinationPath "C:\src" -Force
# Add to PATH
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
[Environment]::SetEnvironmentVariable("Path", "$currentPath;$flutterPath\bin", "User")
```

---

**Current Status:** Flutter is not installed  
**Recommended Path:** `C:\src\flutter`  
**Executable Path:** `C:\src\flutter\bin\flutter.bat`

