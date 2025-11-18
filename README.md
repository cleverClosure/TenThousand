# TenThousand - Skill Tracker MVP

A macOS menubar app for tracking time spent on skills toward 10,000-hour mastery goals.

## Overview

TenThousand is a simple, always-accessible menubar application that helps you:
- Track time spent on multiple skills
- Monitor progress toward 10,000-hour goals
- View time remaining in day/week/month/year
- Get projected completion dates based on your activity

## Features (MVP v1.0)

### Core Functionality
- ✅ Create and delete skills with custom goals
- ✅ Start/pause time tracking (one skill at a time)
- ✅ Visual progress bars and percentages
- ✅ Projected completion dates
- ✅ Time remaining display (day/week/month/year)
- ✅ Auto-save every 60 seconds
- ✅ Data persistence with UserDefaults
- ✅ Launch at startup option

### Technical Details
- **Platform:** macOS 14.0+
- **Language:** Swift 5.9+
- **UI Framework:** SwiftUI
- **Storage:** UserDefaults (local only)
- **Dependencies:** None

## Project Structure

```
TenThousand/
├── TenThousandApp.swift          # App entry point
├── Models/
│   ├── Session.swift             # Session data model
│   ├── Skill.swift               # Skill data model
│   └── SkillTrackerData.swift    # Data manager (ObservableObject)
├── Views/
│   ├── MenuBarView.swift         # Main dropdown view
│   ├── SkillRowView.swift        # Individual skill row
│   ├── AddSkillView.swift        # Add skill sheet
│   ├── TimeRemainingView.swift   # Time perspectives section
│   └── SettingsView.swift        # Settings sheet
├── Utilities/
│   ├── Extensions.swift          # Helper extensions
│   └── Constants.swift           # App constants
├── Info.plist                    # App configuration
└── Assets.xcassets               # Icons and colors
```

## Setup Instructions

### 1. Open in Xcode
```bash
open TenThousand.xcodeproj
```

### 2. Configure Info.plist
The project includes a custom `Info.plist` file that needs to be configured in Xcode:

1. Select the project in the Project Navigator
2. Select the "TenThousand" target
3. Go to the "Build Settings" tab
4. Search for "Info.plist"
5. Find "Generate Info.plist File" and set it to **NO**
6. Find "Info.plist File" and set it to **TenThousand/Info.plist**

This configuration includes:
- `LSUIElement = YES` - Hides app from Dock (menubar only)
- App name and bundle identifier
- Minimum system version

### 3. Configure Code Signing
1. Select the project in the Project Navigator
2. Select the "TenThousand" target
3. Go to the "Signing & Capabilities" tab
4. Select your development team
5. Ensure "Automatically manage signing" is checked

### 4. Build and Run
- Press `Cmd + R` to build and run
- The app will appear in your menubar as a clock icon
- Click the icon to open the dropdown

## Usage

### Adding a Skill
1. Click the menubar icon
2. Click "+ Add Skill"
3. Enter skill name (e.g., "Python Programming")
4. Enter goal hours (default: 10,000)
5. Click "Create"

### Tracking Time
1. Click the play button (▶) next to a skill
2. The icon changes to pause (⏸) and turns orange
3. Time tracking begins
4. Click pause when done
5. Time is saved automatically

### Viewing Progress
- Progress bars show percentage complete
- Current hours vs goal hours displayed
- Projected completion date (based on last 30 days)
- Time remaining in day/week/month/year always visible

### Deleting a Skill
1. Click the trash icon next to a skill
2. Confirm deletion
3. **Warning:** This cannot be undone!

### Settings
1. Click the gear icon in the header
2. Toggle "Launch at startup"
3. Click "Done"

## Development Roadmap

### MVP (Week 1-8) ✅
- [x] Core data models
- [x] Time tracking functionality
- [x] Progress display
- [x] Time remaining display
- [x] Goal projections
- [x] Menubar integration
- [x] Settings (launch at startup)

### v1.1 (Future)
- [ ] Edit skill functionality
- [ ] Session history view
- [ ] Improved error handling
- [ ] Enhanced UI polish

### v1.5 (Future)
- [ ] Heatmap calendar
- [ ] Daily/weekly goals
- [ ] Notifications
- [ ] Dark mode support

### v2.0 (Future)
- [ ] Data export/import
- [ ] iCloud sync
- [ ] Advanced analytics
- [ ] Life milestones

## Known Limitations (MVP)

- No skill editing (must delete and recreate)
- No custom colors (auto-assigned)
- No manual time entry
- No session editing/deletion
- No data export/backup
- Local storage only (no sync)
- No idle time detection

## Testing

### Manual Testing Checklist
- [ ] App launches without crash
- [ ] Menubar icon appears
- [ ] Can create a skill
- [ ] Can start tracking
- [ ] Timer increments correctly
- [ ] Can pause tracking
- [ ] Time saves correctly
- [ ] Can start different skill (stops previous)
- [ ] Can delete a skill
- [ ] Progress updates correctly
- [ ] Completion date calculates
- [ ] Time remaining displays update
- [ ] App quits properly
- [ ] Data persists after restart

### Unit Tests
```bash
# Run tests
xcodebuild test -scheme TenThousand -destination 'platform=macOS'
```

## Building for Release

### Debug Build
```bash
xcodebuild -scheme TenThousand -configuration Debug
```

### Release Build
```bash
xcodebuild -scheme TenThousand -configuration Release
```

### Create DMG Installer
(Instructions for creating .dmg will be added in Week 8)

## Troubleshooting

### App doesn't appear in menubar
- Check that the app is running (Activity Monitor)
- Restart the Mac
- Check System Settings > Privacy & Security

### Launch at startup not working
- Check System Settings > General > Login Items
- Ensure app has permission
- Try toggling the setting off and on

### Data not saving
- Check Console app for errors
- Ensure app has proper permissions
- Check UserDefaults storage

## Performance Targets

- **Launch time:** < 2 seconds (cold start)
- **UI response:** < 100ms for all interactions
- **Memory usage:** < 40 MB idle, < 60 MB tracking
- **CPU usage:** < 0.5% idle, < 1% tracking
- **Disk space:** < 5 MB app size

## Support & Feedback

For bugs, feature requests, or feedback:
- Create an issue on GitHub
- Email: [your-email@example.com]

## License

[Add your license here]

## Credits

Created by Tim Isaev
MVP Specification: November 18, 2025
Target Launch: 8 weeks from start

---

**Version:** 1.0 MVP
**Last Updated:** November 18, 2025
**Status:** Development Complete ✅
