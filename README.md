# TenThousand

A minimalist macOS menubar application for tracking time spent on skills. Built with SwiftUI, TenThousand helps you work toward mastery by tracking your progress toward the famous "10,000 hour rule."

## Features

### Core Tracking
- **Start/Pause/Resume/Stop** - Full control over time tracking sessions
- **Multiple Skills** - Track different skills with color-coded organization
- **Persistent Storage** - All data saved locally with CoreData
- **Accurate Timing** - Pause duration tracking for precise measurements

### Visualization
- **Today's Summary** - See total time and skills practiced today
- **4-Week Heatmap** - Visual activity overview with intensity levels
- **Skill Details** - Dive deep into individual skill statistics
- **Progress Charts** - Interactive charts showing daily/weekly progress over 30/90/365 days
- **Per-Skill Heatmaps** - Detailed activity visualization for each skill

### Goals & Planning
- **Daily/Weekly Goals** - Set practice targets and track completion
- **Goal Progress** - Real-time feedback on goal achievement
- **Remaining Time** - See exactly how much practice time is left to meet your goal

### Advanced Features
- **Heatmap Visualization Window** - Dedicated window for deep data analysis
- **Enhanced Heatmap** - Multiple view modes (intensity, calendar)
- **Keyboard Shortcuts** - Blazing fast navigation without touching the mouse
- **Dark Mode** - Full support for light and dark appearance

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `⌘N` | Create new skill |
| `Space` | Pause/Resume active timer |
| `⌘.` | Stop tracking current session |
| `⌘1-9` | Quick switch to skill 1-9 |
| `↑↓` | Navigate skill list |
| `⏎` | Open selected skill details |
| `Esc` | Close panel |
| `⌘Q` | Quit application |

## System Requirements

- **macOS**: 14.0 (Sonoma) or later
- **Xcode**: 15.0+ (for building from source)
- **Swift**: 5.9+

## Installation

### From Source

1. **Clone the repository**
   ```bash
   git clone https://github.com/cleverClosure/TenThousand.git
   cd TenThousand
   ```

2. **Open in Xcode**
   ```bash
   open TenThousand.xcodeproj
   ```

3. **Build and run**
   - Select the `TenThousand` scheme
   - Press `⌘R` to build and run
   - The app will appear in your menubar

### Building for Release

1. Open the project in Xcode
2. Select **Product → Archive**
3. Use the Organizer to export the app
4. Choose **Export** and select your distribution method

## Usage

### Getting Started

1. **Launch the app** - TenThousand appears in your menubar
2. **Create a skill** - Click the menubar icon and press `⌘N` or click "Add skill"
3. **Start tracking** - Click the play button next to any skill
4. **Pause/Resume** - Use the Space key or click the pause button
5. **Stop tracking** - Press `⌘.` or click the stop button

### Managing Skills

- **Create**: Click "Add skill" or press `⌘N`
- **Edit**: Click on a skill name to open the detail view
- **Delete**: Hover over a skill and click the trash icon
- **Track**: Click the play button to start timing

### Viewing Progress

- **Today's Summary**: Shows at the bottom of the panel
- **Heatmap**: 4-week visual activity overview
- **Skill Details**: Click a skill name to see statistics, charts, and session history
- **Goals**: Configure daily/weekly targets in the settings section

### Advanced Visualization

Open the **Heatmap Visualization** window for:
- Year-round activity calendar
- Intensity-based heatmap
- Multiple view modes
- Per-skill filtering

## Architecture

TenThousand follows the **MVVM (Model-View-ViewModel)** architecture pattern:

```
┌─────────────────────────────────────────┐
│           Views (SwiftUI)               │
│  MenuBar, Panel, Skill List, Charts    │
└────────────┬────────────────────────────┘
             │ binds to
             ↓
┌─────────────────────────────────────────┐
│      AppViewModel (State Manager)       │
│  @Published properties, business logic  │
└────────┬─────────────────────────────────┘
         │ manages
         ↓
┌─────────────────────────────────────────┐
│      CoreData Models                    │
│  Skill, Session, GoalSettings           │
└────────┬─────────────────────────────────┘
         │ persisted by
         ↓
┌─────────────────────────────────────────┐
│      Persistence Layer                  │
│  CoreData stack with error handling     │
└─────────────────────────────────────────┘
```

### Technology Stack

- **UI Framework**: SwiftUI (native macOS)
- **State Management**: Combine (reactive programming)
- **Data Persistence**: CoreData (SQLite-backed)
- **Charts**: Swift Charts (Apple's charting framework)
- **Logging**: os.log (unified logging system)

### Project Structure

```
TenThousand/
├── Views/              # SwiftUI view components
│   ├── TenThousandApp.swift
│   ├── MenuBarIconView.swift
│   ├── DropdownPanelView.swift
│   ├── ActiveSessionView.swift
│   ├── SkillRowView.swift
│   ├── SkillDetailView.swift
│   ├── HeatmapView.swift
│   ├── ProgressChartsView.swift
│   └── ...
├── ViewModels/         # Business logic
│   └── AppViewModel.swift
├── Models/             # CoreData entities
│   ├── Skill+CoreDataClass.swift
│   ├── Session+CoreDataClass.swift
│   └── GoalSettings+CoreDataClass.swift
├── Managers/           # Specialized managers
│   └── TimerManager.swift
└── System/             # Core infrastructure
    ├── Persistence.swift
    ├── DesignSystem.swift
    └── ButtonStyles.swift
```

## Development

### Running Tests

```bash
# Run all tests
xcodebuild test -scheme TenThousand -destination 'platform=macOS'

# Run specific test suite
xcodebuild test -scheme TenThousand -destination 'platform=macOS' \
  -only-testing:TenThousandTests/TimerManagerTests

# Run with code coverage
xcodebuild test -scheme TenThousand -destination 'platform=macOS' \
  -enableCodeCoverage YES
```

### Test Coverage

- **103 unit tests** across 4 test suites
- **Behavior-driven** test naming for clarity
- **In-memory CoreData** for test isolation
- **Edge case coverage** for robust validation

Test suites:
- `TimerManagerTests` (29 tests) - Timer state and formatting
- `AppViewModelTests` (34 tests) - Skill and session management
- `DataModelTests` (22 tests) - CoreData computed properties
- `PersistenceTests` (18 tests) - Database operations

### Code Conventions

TenThousand follows strict code conventions documented in `CODE_CONVENTIONS.md`:

- **No magic literals** - All constants named and organized
- **MVVM architecture** - Clear separation of concerns
- **Reactive patterns** - Combine publishers for state management
- **Error handling** - All CoreData operations wrapped in do-catch
- **Memory safety** - Consistent `[weak self]` usage in closures

### Design System

The project uses a centralized design system (`DesignSystem.swift`) with:

- **Color palette** - 15+ named colors for light/dark mode
- **Typography** - 5 font styles with kerning and line-height
- **Spacing** - 8pt grid system (2, 4, 8, 12, 16, 24pt)
- **Animations** - Pre-configured timing curves
- **Dimensions** - Standardized sizes for UI components

Example usage:
```swift
Text("Hello")
    .displayFont()                    // Typography
    .foregroundColor(.trackingBlue)   // Color
    .padding(Spacing.base)            // Spacing
    .animation(.microInteraction)     // Animation
```

## Data Storage

All data is stored locally using CoreData:

- **Location**: `~/Library/Application Support/TenThousand/`
- **Format**: SQLite database
- **Backup**: Standard macOS Time Machine backups
- **Privacy**: No cloud sync, no network access, all data stays local

### Data Model

**Skill**
- `id` - Unique identifier
- `name` - Skill name (max 30 characters)
- `colorIndex` - Color for visual identification (0-7)
- `createdAt` - Creation timestamp
- `sessions` - Relationship to Session entities

**Session**
- `id` - Unique identifier
- `startTime` - When tracking started
- `endTime` - When tracking stopped
- `pausedDuration` - Total time paused (seconds)
- `skill` - Relationship to parent Skill

**GoalSettings**
- `id` - Unique identifier
- `goalType` - "daily" or "weekly"
- `targetMinutes` - Goal target in minutes
- `isEnabled` - Whether goal is active

## Privacy & Security

- **Sandboxed** - Runs in macOS sandbox for security
- **Local-only** - No network access, no cloud sync
- **No tracking** - No analytics, no telemetry
- **Open source** - All code is visible and auditable

## Performance

- **Efficient rendering** - SwiftUI optimizations for smooth 60fps
- **Smart fetching** - CoreData predicates filter data efficiently
- **Reactive updates** - Only affected views re-render on state changes
- **Low memory** - Typically uses <50MB RAM

## Contributing

Contributions are welcome! Please read the contributing guidelines before submitting PRs.

### Development Workflow

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

### Code Quality Standards

- All new features must have unit tests
- Follow the code conventions in `CODE_CONVENTIONS.md`
- No force unwraps or magic literals
- Document public APIs with `///` comments
- Ensure all tests pass before submitting PR

### Areas for Contribution

See `CODE_REVIEW_ACTION_ITEMS.md` for a comprehensive list of improvement areas:

- **Accessibility** - VoiceOver support (HIGH PRIORITY)
- **Localization** - Multi-language support
- **UI Tests** - End-to-end workflow testing
- **Export/Import** - Data portability
- **Widgets** - macOS widgets for quick glance
- **Performance** - Optimization opportunities

## Documentation

- **CODE_CONVENTIONS.md** - Coding standards and best practices
- **CODE_REVIEW_SUMMARY.md** - Comprehensive code review findings
- **CODE_REVIEW_ACTION_ITEMS.md** - Prioritized improvement tasks
- **IMPLEMENTATION_REPORT.md** - Feature implementation status
- **TEST_COVERAGE.md** - Testing approach and philosophy

## Roadmap

### Current Status (v1.0)
- ✅ Core time tracking functionality
- ✅ Multiple skill management
- ✅ Heatmap visualization
- ✅ Goal planning
- ✅ Comprehensive testing

### Planned Improvements

**Phase 1: Production Polish**
- Add VoiceOver accessibility support
- Complete UI test coverage
- Performance optimization

**Phase 2: International**
- Multi-language localization
- Date/time format localization
- RTL language support

**Phase 3: Enhanced Features**
- Data export/import (CSV, JSON)
- Backup/restore functionality
- Advanced statistics
- macOS widgets
- Notification support

## License

[Add your license here - e.g., MIT, GPL, etc.]

## Credits

Developed with ❤️ using SwiftUI and Combine.

**The 10,000 Hour Rule** - Based on research by K. Anders Ericsson and popularized by Malcolm Gladwell.

## Support

- **Issues**: Report bugs via [GitHub Issues](https://github.com/cleverClosure/TenThousand/issues)
- **Discussions**: Ask questions in [GitHub Discussions](https://github.com/cleverClosure/TenThousand/discussions)
- **Email**: [Add support email if desired]

## Acknowledgments

- Apple's SwiftUI and Combine frameworks
- The Swift and macOS developer community
- All contributors and testers

---

**Made with Swift** 🚀

*TenThousand - Track your journey to mastery, one hour at a time.*
