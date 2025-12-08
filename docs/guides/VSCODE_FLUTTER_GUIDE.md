# Running Flutter App in VS Code

## Setup Steps

### 1. Restart VS Code
Since we just updated the PATH, restart VS Code to pick up the new Flutter SDK location:
- Close VS Code completely
- Reopen VS Code
- Open the project folder: `/Users/munishm/Documents/am-investment-ui`

### 2. Verify Flutter Extension
Make sure you have the Flutter extension installed:
- Press `Cmd+Shift+X` to open Extensions
- Search for "Flutter"
- Install "Flutter" by Dart Code (if not already installed)

### 3. Select Device

**Option A: macOS Desktop (Recommended)**
1. Press `Cmd+Shift+P` to open Command Palette
2. Type "Flutter: Select Device"
3. Choose "macOS (desktop)"

**Option B: Chrome (Will fail due to compiler bug)**
1. Press `Cmd+Shift+P`
2. Type "Flutter: Select Device"  
3. Choose "Chrome (web)"
4. Note: This will encounter the same Riverpod compilation error

### 4. Run the App

**Method 1: Using Debug Menu**
1. Go to Run → Start Debugging (or press `F5`)
2. The app should build and launch

**Method 2: Using Command Palette**
1. Press `Cmd+Shift+P`
2. Type "Flutter: Run Flutter Doctor"
3. Verify everything shows checkmarks
4. Press `Cmd+Shift+P` again
5. Type "Flutter: Launch Emulator" or "Flutter: Run"

**Method 3: Using Terminal in VS Code**
1. Open integrated terminal (`Ctrl+\``)
2. Run: `flutter run -d macos`

## Expected Behavior

### ✅ If Running on macOS Desktop
- App should compile successfully
- macOS window will open with your app
- Hot reload will work with `r` in terminal

### ❌ If Running on Chrome/Web
- Will fail with Riverpod compilation error
- Error: `Unsupported invalid type InvalidType(<invalid>)`
- This is the known Flutter 3.38.3 + Riverpod web bug

## Troubleshooting

### "Flutter SDK not found"
1. Open VS Code settings (`Cmd+,`)
2. Search for "flutter sdk"
3. Set "Dart: Flutter Sdk Path" to: `/Users/munishm/develop/flutter`

### "No devices found"
1. Run `flutter doctor` in terminal
2. For macOS: Install Xcode Command Line Tools
   ```bash
   xcode-select --install
   ```
3. Restart VS Code

### Hot Reload Not Working
- Press `r` in the terminal where Flutter is running
- Or use the hot reload button in VS Code's debug toolbar

## VS Code Settings (Optional)

Add to `.vscode/settings.json` in your project:

```json
{
  "dart.flutterSdkPath": "/Users/munishm/develop/flutter",
  "dart.previewFlutterUiGuides": true,
  "dart.previewFlutterUiGuidesCustomTracking": true,
  "[dart]": {
    "editor.formatOnSave": true,
    "editor.formatOnType": true,
    "editor.rulers": [80],
    "editor.selectionHighlight": false,
    "editor.suggest.snippetsPreventQuickSuggestions": false,
    "editor.suggestSelection": "first",
    "editor.tabCompletion": "onlySnippets",
    "editor.wordBasedSuggestions": "off"
  }
}
```

## Summary

**Yes, VS Code Flutter extension will work!** Just:
1. Restart VS Code
2. Select "macOS (desktop)" as device
3. Press F5 to run

The web compilation issue affects both command line and VS Code equally, so use macOS desktop target instead.
