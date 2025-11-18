# TenThousand - Setup Guide

This guide will walk you through setting up the TenThousand Skill Tracker app in Xcode.

## Prerequisites

- macOS 14.0 or later
- Xcode 15.0 or later
- Apple Developer account (for code signing)

## Step-by-Step Setup

### Step 1: Open the Project

```bash
cd /path/to/TenThousand
open TenThousand.xcodeproj
```

### Step 2: Configure Info.plist

The app uses a custom `Info.plist` file to configure it as a menubar-only application. Follow these steps:

1. **Open Project Settings**
   - Click on the blue "TenThousand" project icon in the Project Navigator (left sidebar)

2. **Select Target**
   - Under "TARGETS", click on "TenThousand"

3. **Open Build Settings**
   - Click the "Build Settings" tab at the top
   - Make sure "All" and "Combined" are selected (not "Basic" or "Customized")

4. **Disable Auto-Generated Info.plist**
   - In the search bar, type "Generate Info.plist"
   - Find "Generate Info.plist File" setting
   - Change the value from "Yes" to **No**

5. **Set Custom Info.plist Path**
   - Clear the search bar and type "Info.plist File"
   - Find "Info.plist File" setting
   - Set the value to: **TenThousand/Info.plist**

6. **Verify Configuration**
   - The project should now use the custom Info.plist
   - This file includes `LSUIElement = YES` to hide the app from the Dock

### Step 3: Configure Code Signing

1. **Select Target**
   - Make sure "TenThousand" target is selected

2. **Open Signing & Capabilities**
   - Click the "Signing & Capabilities" tab

3. **Set Development Team**
   - Check "Automatically manage signing"
   - Select your team from the "Team" dropdown
   - If you don't see your team, you may need to add your Apple ID in Xcode > Settings > Accounts

4. **Verify Bundle Identifier**
   - The bundle identifier should be: `com.cleverClosure.TenThousand`
   - You can change this if needed

### Step 4: Configure Entitlements

The project includes an `TenThousand.entitlements` file with these capabilities:
- App Sandbox (enabled)
- User Selected Files (Read-Only)

These are required for macOS app distribution. No changes needed for MVP.

### Step 5: Add to File System Synchronized Group (If Needed)

If Xcode shows errors about missing files:

1. **Right-click on the "TenThousand" folder** in Project Navigator
2. Select "Add Files to TenThousand..."
3. Navigate to and select any missing folders:
   - Models/
   - Views/
   - Utilities/
4. Make sure "Create groups" is selected (not "Create folder references")
5. Make sure "TenThousand" target is checked
6. Click "Add"

### Step 6: Build and Run

1. **Select Run Destination**
   - Click the device/simulator selector next to the scheme
   - Select "My Mac (Designed for Mac)"

2. **Build the Project**
   - Press `Cmd + B` or select Product > Build
   - Fix any compilation errors if they appear

3. **Run the App**
   - Press `Cmd + R` or select Product > Run
   - The app should launch and appear in your menubar
   - Look for a clock icon in the top-right of your screen

### Step 7: Test the App

1. **Click the Menubar Icon**
   - The dropdown should appear with "Time Remaining" section

2. **Add a Skill**
   - Click "+ Add Skill"
   - Enter "Test Skill" as the name
   - Leave goal as 10000
   - Click "Create"

3. **Start Tracking**
   - Click the play button (▶) next to your skill
   - The button should change to pause (⏸) and turn orange
   - The menubar icon should change to a timer icon and turn green

4. **Wait 1 Minute**
   - Watch the time update
   - The progress should increment

5. **Stop Tracking**
   - Click the pause button
   - Time should be saved

6. **Test Settings**
   - Click the gear icon
   - Toggle "Launch at startup"
   - Click "Done"

7. **Test Persistence**
   - Quit the app (click "Quit" button)
   - Re-run from Xcode
   - Your skill should still be there with saved time

## Common Issues and Solutions

### Issue: "No such file or directory" errors

**Solution:** The project uses Xcode's file system synchronized groups (new in Xcode 15). If you see missing file errors:
1. Clean build folder: Shift + Cmd + K
2. Close and reopen Xcode
3. Try adding files manually (see Step 5)

### Issue: Code signing errors

**Solution:**
1. Open Xcode > Settings > Accounts
2. Add your Apple ID if not present
3. Download manual profiles if needed
4. Select your team in target settings

### Issue: App doesn't appear in menubar

**Solution:**
1. Check Console app for errors
2. Verify Info.plist is configured correctly
3. Make sure `LSUIElement` is set to `YES` in Info.plist
4. Try building for Release configuration

### Issue: "SMAppService" errors for launch at startup

**Solution:**
1. This requires macOS 13.0+
2. Add Service Management entitlement if needed
3. For testing, you can comment out the SMAppService code in SettingsView.swift

### Issue: Build succeeds but app crashes on launch

**Solution:**
1. Check Console app for crash logs
2. Verify all Swift files are included in target
3. Check for missing asset files
4. Verify deployment target matches your macOS version

## Advanced Configuration

### Changing the App Name

1. Select project in Project Navigator
2. Select "TenThousand" target
3. Change "Display Name" in General tab
4. Update `CFBundleDisplayName` in Info.plist

### Changing the Bundle Identifier

1. Select project in Project Navigator
2. Select "TenThousand" target
3. Change "Bundle Identifier" in General tab
4. Update signing if needed

### Lowering Deployment Target

The app is currently set to macOS 14.0. To support older versions:

1. Select project in Project Navigator
2. Select "TenThousand" target
3. Change "Minimum Deployments" to desired version
4. Update `MACOSX_DEPLOYMENT_TARGET` in build settings
5. Update `LSMinimumSystemVersion` in Info.plist
6. **Note:** Some features may not work on older macOS versions (e.g., SMAppService requires 13.0+)

### Adding App Icon

1. Open Assets.xcassets
2. Click on "AppIcon"
3. Drag and drop icon images for various sizes
4. Recommended sizes: 16x16, 32x32, 128x128, 256x256, 512x512, 1024x1024

## Building for Distribution

### Creating an Archive

1. Select "Any Mac" as the run destination
2. Select Product > Archive
3. Wait for archive to complete
4. Organizer window will open

### Exporting for Distribution

1. Select your archive in Organizer
2. Click "Distribute App"
3. Choose distribution method:
   - **Developer ID:** For distribution outside App Store
   - **App Store:** For App Store submission
   - **Copy App:** For local testing
4. Follow the export wizard

### Creating a DMG Installer

(Will be added in Week 8 of development)

## Need Help?

If you encounter issues not covered here:
1. Check the README.md for general information
2. Review the MVP specification document
3. Check Xcode console for error messages
4. Create an issue on GitHub

---

**Last Updated:** November 18, 2025
