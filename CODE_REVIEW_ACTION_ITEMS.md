# Code Review Action Items - TenThousand Project

**Generated**: 2025-11-19
**Overall Status**: Production-ready with accessibility gap
**Total Estimated Effort**: 42-71 hours

---

## Priority System

- 🔴 **CRITICAL** - Blocks production release
- 🟠 **HIGH** - Should fix before public release
- 🟡 **MEDIUM** - Important for quality, can ship without
- 🟢 **LOW** - Nice to have, future improvements

---

## 🔴 CRITICAL PRIORITY (Must Fix Before Public Release)

### 1. Add Accessibility Support for VoiceOver

**Status**: ❌ Not Started
**Effort**: 8-12 hours
**Impact**: Excludes 5-10% of potential users (screen reader users)

#### Tasks:

- [ ] **SkillRowView.swift** (2 hours)
  - [ ] Add `.accessibilityLabel("Start tracking [skill name]")` to play button
  - [ ] Add `.accessibilityLabel("Open [skill name] details")` to skill name tap
  - [ ] Add `.accessibilityLabel("Delete [skill name]")` to delete button
  - [ ] Add `.accessibilityHint()` to explain each action

- [ ] **ActiveSessionView.swift** (2 hours)
  - [ ] Add `.accessibilityLabel()` to pause/resume button (dynamic based on state)
  - [ ] Add `.accessibilityLabel("Stop tracking")` to stop button
  - [ ] Add `.accessibilityValue()` to timer display with readable time
  - [ ] Make timer announcement update on significant changes (every minute)

- [ ] **DropdownPanelView.swift** (2 hours)
  - [ ] Add `.accessibilityLabel("Add new skill")` to add skill button
  - [ ] Add `.accessibilityLabel("Quit TenThousand")` to quit button
  - [ ] Add `.accessibilityLabel("Open heatmap visualization")` to heatmap button
  - [ ] Add labels to all settings toggles

- [ ] **AddSkillView.swift** (1 hour)
  - [ ] Add `.accessibilityLabel("Skill name input")` to text field
  - [ ] Add `.accessibilityHint("Enter name for new skill")` to text field

- [ ] **Other Views** (2 hours)
  - [ ] GoalSettingsView.swift - Add labels to goal type picker and sliders
  - [ ] SkillDetailView.swift - Add labels to edit/back buttons
  - [ ] HeatmapView.swift - Add description of heatmap data

- [ ] **Testing** (2 hours)
  - [ ] Test with VoiceOver enabled on macOS
  - [ ] Verify all buttons are properly announced
  - [ ] Verify navigation flow works with VoiceOver
  - [ ] Document accessibility testing procedure

**Acceptance Criteria**:
- ✅ All interactive elements have meaningful accessibility labels
- ✅ VoiceOver can navigate through entire app
- ✅ Timer state changes are announced
- ✅ All button actions are clearly described
- ✅ App tested with VoiceOver enabled successfully

**Files to Modify**:
- `TenThousand/SkillRowView.swift`
- `TenThousand/ActiveSessionView.swift`
- `TenThousand/DropdownPanelView.swift`
- `TenThousand/AddSkillView.swift`
- `TenThousand/GoalSettingsView.swift`
- `TenThousand/SkillDetailView.swift`

---

## 🟠 HIGH PRIORITY (Recommended Before Public Release)

### 2. Add Comprehensive UI Tests

**Status**: ❌ Not Started
**Effort**: 8-12 hours
**Impact**: Prevents regressions in critical user workflows

#### Tasks:

- [ ] **Setup UI Test Infrastructure** (1 hour)
  - [ ] Configure TenThousandUITests target
  - [ ] Add test helpers for common actions
  - [ ] Setup test data creation utilities

- [ ] **Critical Flow Tests** (6 hours)
  - [ ] Test: Create new skill flow
    - [ ] Click add skill button
    - [ ] Enter skill name
    - [ ] Verify skill appears in list

  - [ ] Test: Start tracking workflow
    - [ ] Create skill
    - [ ] Click play button
    - [ ] Verify active session appears
    - [ ] Verify timer is running

  - [ ] Test: Pause and resume
    - [ ] Start tracking
    - [ ] Click pause
    - [ ] Verify paused state
    - [ ] Click resume
    - [ ] Verify running state

  - [ ] Test: Stop tracking and save session
    - [ ] Start tracking
    - [ ] Wait 5 seconds
    - [ ] Stop tracking
    - [ ] Verify session saved
    - [ ] Verify skill total updated

  - [ ] Test: Delete skill with confirmation
    - [ ] Create skill
    - [ ] Click delete
    - [ ] Verify confirmation alert
    - [ ] Confirm deletion
    - [ ] Verify skill removed

- [ ] **Keyboard Shortcut Tests** (3 hours)
  - [ ] Test ⌘N to add skill
  - [ ] Test Space to pause/resume
  - [ ] Test ⌘. to stop tracking
  - [ ] Test ⌘1-9 for quick skill selection
  - [ ] Test ↑↓ arrow navigation
  - [ ] Test ⏎ to open skill detail

- [ ] **Edge Case Tests** (2 hours)
  - [ ] Test creating duplicate skill names
  - [ ] Test skill name max length (30 chars)
  - [ ] Test switching skills while tracking
  - [ ] Test app behavior with no skills

**Acceptance Criteria**:
- ✅ All critical user flows have automated UI tests
- ✅ Keyboard shortcuts are tested
- ✅ Edge cases are covered
- ✅ Tests run successfully in CI
- ✅ Test coverage report shows UI workflows covered

**Files to Create/Modify**:
- `TenThousandUITests/SkillCreationTests.swift` (new)
- `TenThousandUITests/SessionTrackingTests.swift` (new)
- `TenThousandUITests/KeyboardShortcutTests.swift` (new)
- `TenThousandUITests/TestHelpers.swift` (new)

---

### 3. Add Project Documentation (README)

**Status**: ❌ Not Started
**Effort**: 2-3 hours
**Impact**: Essential for open-source or team collaboration

#### Tasks:

- [ ] **Create README.md** (2 hours)
  - [ ] Project description and purpose
  - [ ] Screenshots/demo GIF
  - [ ] Feature list
  - [ ] System requirements
  - [ ] Installation instructions
  - [ ] Build instructions
  - [ ] Usage guide
  - [ ] Keyboard shortcuts reference
  - [ ] Architecture overview
  - [ ] Contributing guidelines
  - [ ] License information

- [ ] **Create CHANGELOG.md** (30 min)
  - [ ] Document version history
  - [ ] List features by version
  - [ ] Note breaking changes

- [ ] **Update CONTRIBUTING.md** (30 min)
  - [ ] Code style guidelines (link to CODE_CONVENTIONS.md)
  - [ ] PR process
  - [ ] Testing requirements
  - [ ] Commit message format

**Acceptance Criteria**:
- ✅ README.md covers all essential project information
- ✅ New developers can build and run app from README
- ✅ Screenshots demonstrate key features
- ✅ Keyboard shortcuts documented
- ✅ Architecture diagram included

**Files to Create**:
- `README.md` (new)
- `CHANGELOG.md` (new)
- `CONTRIBUTING.md` (new)
- `screenshots/` directory (new)

---

### 4. Add Documentation Comments to Public APIs

**Status**: ❌ Not Started
**Effort**: 3-5 hours
**Impact**: Improves code maintainability and onboarding

#### Tasks:

- [ ] **AppViewModel.swift** (2 hours)
  - [ ] Document all public methods with `///` comments
  - [ ] Add parameter descriptions
  - [ ] Add return value descriptions
  - [ ] Add usage examples for complex methods
  - [ ] Document computed properties

- [ ] **TimerManager.swift** (30 min)
  - [ ] Document timer lifecycle methods
  - [ ] Explain pause duration tracking
  - [ ] Document published properties

- [ ] **PersistenceController.swift** (30 min)
  - [ ] Document initialization options
  - [ ] Explain in-memory vs persistent storage
  - [ ] Document save behavior

- [ ] **DesignSystem.swift** (1 hour)
  - [ ] Add header documentation explaining design system
  - [ ] Document color palette with hex values
  - [ ] Document spacing scale
  - [ ] Add usage examples for view modifiers

- [ ] **Model Classes** (1 hour)
  - [ ] Document Skill+CoreDataClass.swift
  - [ ] Document Session+CoreDataClass.swift
  - [ ] Document GoalSettings+CoreDataClass.swift
  - [ ] Explain computed properties and relationships

**Example Format**:
```swift
/// Calculates heatmap data for a specific skill over a date range.
///
/// The heatmap data is returned as a dictionary where keys are dates (normalized to start of day)
/// and values are total seconds tracked on that date. Days with no tracking are not included.
///
/// - Parameters:
///   - skill: The skill to generate heatmap data for
///   - daysBack: Number of days to include in the range (default: 365)
/// - Returns: Dictionary mapping dates to total seconds tracked
///
/// - Note: This performs a CoreData fetch and may be expensive for large date ranges
///
/// Example:
/// ```swift
/// let data = viewModel.heatmapDataForSkill(mySkill, daysBack: 90)
/// // Returns: [2024-01-01: 3600, 2024-01-02: 7200, ...]
/// ```
func heatmapDataForSkill(_ skill: Skill, daysBack: Int = 365) -> [Date: Int64]
```

**Acceptance Criteria**:
- ✅ All public methods have documentation comments
- ✅ Parameters and return values documented
- ✅ Complex logic has explanatory comments
- ✅ Usage examples provided for non-obvious methods
- ✅ Documentation viewable in Xcode Quick Help

**Files to Modify**:
- `TenThousand/AppViewModel.swift`
- `TenThousand/TimerManager.swift`
- `TenThousand/Persistence.swift`
- `TenThousand/DesignSystem.swift`
- `TenThousand/Skill+CoreDataClass.swift`
- `TenThousand/Session+CoreDataClass.swift`
- `TenThousand/GoalSettings+CoreDataClass.swift`

---

## 🟡 MEDIUM PRIORITY (Important for Quality)

### 5. Add Localization Infrastructure

**Status**: ❌ Not Started
**Effort**: 6-10 hours
**Impact**: Enables international user base

#### Tasks:

- [ ] **Setup Localization** (1 hour)
  - [ ] Add Localizable.strings file
  - [ ] Configure Xcode project for localization
  - [ ] Add base localization (English)

- [ ] **Extract All Strings** (3 hours)
  - [ ] Create string keys in Localizable.strings
  - [ ] Replace all hardcoded Text() strings
  - [ ] Replace UIText constants with NSLocalizedString
  - [ ] Add context comments for translators

- [ ] **Add Initial Translations** (4 hours)
  - [ ] Spanish (es)
  - [ ] French (fr)
  - [ ] German (de)
  - [ ] Japanese (ja)
  - [ ] Simplified Chinese (zh-Hans)

- [ ] **Test Localization** (2 hours)
  - [ ] Test each language in simulator
  - [ ] Verify UI layout with longer strings
  - [ ] Check for truncation issues
  - [ ] Verify date/time formatting

**Acceptance Criteria**:
- ✅ All user-facing strings localized
- ✅ At least 3 language translations complete
- ✅ App tested in each supported language
- ✅ No hardcoded English strings remain
- ✅ Localization guide added to docs

**Files to Create**:
- `TenThousand/Resources/Localizable.strings (Base)` (new)
- `TenThousand/Resources/Localizable.strings (Spanish)` (new)
- `TenThousand/Resources/Localizable.strings (French)` (new)
- `TenThousand/Resources/Localizable.strings (German)` (new)

**Files to Modify**:
- All view files using Text() with hardcoded strings
- `TenThousand/DesignSystem.swift` (UIText struct)

---

### 6. Refactor AppViewModel (Split into Smaller Managers)

**Status**: ❌ Not Started
**Effort**: 6-10 hours
**Impact**: Improves maintainability and testability

#### Current Issue:
AppViewModel.swift is 584 lines and handles too many responsibilities:
- Skill management
- Session tracking
- Statistics calculation
- Heatmap data generation
- Goal management
- Chart data generation

#### Proposed Structure:

```
ViewModels/
├── AppViewModel.swift (150 lines) - Coordinates other managers
├── SkillManager.swift (120 lines) - Skill CRUD operations
├── SessionManager.swift (100 lines) - Session tracking
├── StatisticsManager.swift (150 lines) - Stats and heatmap data
└── GoalManager.swift (80 lines) - Goal settings and progress
```

#### Tasks:

- [ ] **Create SkillManager** (2 hours)
  - [ ] Extract skill CRUD methods
  - [ ] Move skill-related @Published properties
  - [ ] Update tests to use SkillManager
  - [ ] Add documentation

- [ ] **Create SessionManager** (2 hours)
  - [ ] Extract session tracking methods
  - [ ] Move timer coordination logic
  - [ ] Update tests to use SessionManager
  - [ ] Add documentation

- [ ] **Create StatisticsManager** (2 hours)
  - [ ] Extract heatmap methods
  - [ ] Extract statistics methods
  - [ ] Extract chart data methods
  - [ ] Update tests to use StatisticsManager
  - [ ] Add documentation

- [ ] **Create GoalManager** (1 hour)
  - [ ] Extract goal-related methods
  - [ ] Move goal settings property
  - [ ] Update tests to use GoalManager
  - [ ] Add documentation

- [ ] **Refactor AppViewModel** (2 hours)
  - [ ] Keep only coordination logic
  - [ ] Compose managers
  - [ ] Update all view bindings
  - [ ] Ensure @Published properties work correctly

- [ ] **Update Tests** (1 hour)
  - [ ] Refactor existing tests
  - [ ] Add tests for new managers
  - [ ] Verify all tests pass

**Acceptance Criteria**:
- ✅ Each manager has single, clear responsibility
- ✅ No manager exceeds 200 lines
- ✅ All existing tests pass
- ✅ New managers have unit tests
- ✅ Views still function correctly
- ✅ No performance regression

**Files to Create**:
- `TenThousand/ViewModels/SkillManager.swift` (new)
- `TenThousand/ViewModels/SessionManager.swift` (new)
- `TenThousand/ViewModels/StatisticsManager.swift` (new)
- `TenThousand/ViewModels/GoalManager.swift` (new)

**Files to Modify**:
- `TenThousand/ViewModels/AppViewModel.swift` (reduce from 584 to ~150 lines)
- All view files that use AppViewModel
- All test files

---

### 7. Performance Optimization

**Status**: ❌ Not Started
**Effort**: 4-8 hours
**Impact**: Improves app responsiveness

#### Tasks:

- [ ] **Profile with Instruments** (2 hours)
  - [ ] Run Time Profiler
  - [ ] Run Allocations instrument
  - [ ] Run SwiftUI instrument
  - [ ] Identify bottlenecks

- [ ] **Optimize View Rendering** (2 hours)
  - [ ] Add `.id()` to prevent unnecessary re-renders
  - [ ] Use `@StateObject` vs `@ObservedObject` correctly
  - [ ] Cache expensive computed properties
  - [ ] Add `EquatableView` where appropriate

- [ ] **Optimize CoreData Fetches** (2 hours)
  - [ ] Add fetch request batching where needed
  - [ ] Review predicate efficiency
  - [ ] Add indexes to frequently queried fields
  - [ ] Consider fetch result caching

- [ ] **Memory Optimization** (2 hours)
  - [ ] Review retain cycles
  - [ ] Optimize image loading if any
  - [ ] Review cancellable cleanup
  - [ ] Profile memory usage under load

**Acceptance Criteria**:
- ✅ No UI lag during normal operations
- ✅ Memory usage stays under 100MB
- ✅ CoreData fetches complete in <100ms
- ✅ View rendering time <16ms (60fps)
- ✅ Performance benchmarks documented

**Files to Review**:
- All view files for render optimization
- `TenThousand/AppViewModel.swift` for fetch optimization
- `TenThousand/Persistence.swift` for CoreData optimization

---

### 8. Add CI/CD Pipeline

**Status**: ❌ Not Started
**Effort**: 4-6 hours
**Impact**: Automates testing and builds

#### Tasks:

- [ ] **Setup GitHub Actions** (2 hours)
  - [ ] Create `.github/workflows/test.yml`
  - [ ] Configure macOS runner
  - [ ] Setup Xcode build environment
  - [ ] Configure test execution

- [ ] **Add Build Workflow** (1 hour)
  - [ ] Run on every PR
  - [ ] Run on main branch push
  - [ ] Build for Release configuration
  - [ ] Upload artifacts

- [ ] **Add Test Coverage** (1 hour)
  - [ ] Enable code coverage in tests
  - [ ] Generate coverage report
  - [ ] Upload to codecov.io or similar
  - [ ] Add coverage badge to README

- [ ] **Add Linting** (2 hours)
  - [ ] Setup SwiftLint
  - [ ] Create .swiftlint.yml configuration
  - [ ] Add to CI pipeline
  - [ ] Fix existing lint warnings

**Acceptance Criteria**:
- ✅ Tests run automatically on every PR
- ✅ Build succeeds on CI
- ✅ Code coverage tracked
- ✅ Linting enforced
- ✅ Status badges in README

**Files to Create**:
- `.github/workflows/test.yml` (new)
- `.github/workflows/build.yml` (new)
- `.swiftlint.yml` (new)

---

## 🟢 LOW PRIORITY (Nice to Have)

### 9. Add Architecture Decision Records (ADRs)

**Status**: ❌ Not Started
**Effort**: 2-3 hours
**Impact**: Documents design decisions for future developers

#### Tasks:

- [ ] Create `docs/adr/` directory
- [ ] Write ADR template
- [ ] Document key decisions:
  - [ ] ADR-001: Why SwiftUI over AppKit
  - [ ] ADR-002: Why CoreData over Realm/SQLite
  - [ ] ADR-003: Why Combine over RxSwift
  - [ ] ADR-004: Why MVVM architecture
  - [ ] ADR-005: Why centralized DesignSystem

**Files to Create**:
- `docs/adr/template.md`
- `docs/adr/001-swiftui-choice.md`
- `docs/adr/002-coredata-choice.md`
- `docs/adr/003-combine-choice.md`
- `docs/adr/004-mvvm-architecture.md`
- `docs/adr/005-design-system.md`

---

### 10. Add Analytics/Crash Reporting

**Status**: ❌ Not Started
**Effort**: 3-5 hours
**Impact**: Helps understand user behavior and fix crashes

#### Tasks:

- [ ] **Choose Analytics Provider**
  - [ ] Research privacy-friendly options
  - [ ] TelemetryDeck (privacy-first)
  - [ ] Or build minimal custom solution

- [ ] **Implement Analytics** (2 hours)
  - [ ] Track app launches
  - [ ] Track feature usage (anonymized)
  - [ ] Track session durations
  - [ ] Respect user privacy settings

- [ ] **Implement Crash Reporting** (2 hours)
  - [ ] Add Sentry or similar
  - [ ] Configure symbolication
  - [ ] Test crash reporting
  - [ ] Add privacy disclosure

- [ ] **Privacy** (1 hour)
  - [ ] Add opt-out mechanism
  - [ ] Update privacy policy
  - [ ] Add settings toggle
  - [ ] Ensure GDPR compliance

---

### 11. Add Export Functionality

**Status**: ❌ Not Started
**Effort**: 4-6 hours
**Impact**: Users can backup/analyze data externally

#### Tasks:

- [ ] **CSV Export** (2 hours)
  - [ ] Export all sessions to CSV
  - [ ] Include skill name, start time, duration, pause time
  - [ ] Add export button in settings
  - [ ] File save dialog

- [ ] **JSON Export** (1 hour)
  - [ ] Export complete data model
  - [ ] Include skills, sessions, goals
  - [ ] Structured format

- [ ] **Import Functionality** (3 hours)
  - [ ] Import CSV data
  - [ ] Validate imported data
  - [ ] Merge with existing data
  - [ ] Handle duplicates

---

### 12. Add Data Backup/Restore

**Status**: ❌ Not Started
**Effort**: 3-5 hours
**Impact**: Protects user data

#### Tasks:

- [ ] **Manual Backup** (2 hours)
  - [ ] Export CoreData store
  - [ ] Add backup button
  - [ ] Save to user-selected location

- [ ] **Restore** (2 hours)
  - [ ] Import backup file
  - [ ] Validate integrity
  - [ ] Restore CoreData store
  - [ ] Confirm with user

- [ ] **Auto Backup** (1 hour)
  - [ ] Optional daily backup
  - [ ] Keep last N backups
  - [ ] Clean old backups

---

### 13. Enhanced Heatmap Features

**Status**: ❌ Not Started
**Effort**: 4-6 hours
**Impact**: Better data visualization

#### Tasks:

- [ ] **Year View** (2 hours)
  - [ ] Full year heatmap (GitHub-style)
  - [ ] Month labels
  - [ ] Scrollable view

- [ ] **Custom Date Ranges** (2 hours)
  - [ ] Date picker for start/end
  - [ ] Dynamic heatmap generation
  - [ ] Export heatmap as image

- [ ] **Comparison View** (2 hours)
  - [ ] Compare two skills
  - [ ] Side-by-side heatmaps
  - [ ] Trend analysis

---

### 14. Add Widgets (macOS 14+)

**Status**: ❌ Not Started
**Effort**: 6-10 hours
**Impact**: Quick glance at progress

#### Tasks:

- [ ] **Today Widget** (3 hours)
  - [ ] Show today's total time
  - [ ] Show active skill (if tracking)
  - [ ] Show goal progress

- [ ] **Week Widget** (3 hours)
  - [ ] Show weekly progress
  - [ ] Mini heatmap
  - [ ] Goal completion

- [ ] **Skill Widget** (2 hours)
  - [ ] Configurable per skill
  - [ ] Show skill total time
  - [ ] Show recent activity

---

### 15. Dark Mode Refinement

**Status**: ❌ Not Started
**Effort**: 2-3 hours
**Impact**: Better visual polish

#### Tasks:

- [ ] **Review Dark Mode Colors** (1 hour)
  - [ ] Test all views in dark mode
  - [ ] Adjust contrast ratios
  - [ ] Ensure WCAG AA compliance

- [ ] **Add Dark Mode Screenshots** (1 hour)
  - [ ] Capture all major views
  - [ ] Add to README
  - [ ] Add to App Store listing

---

## Summary by Priority

### 🔴 CRITICAL (Must Do)
1. ✅ Add Accessibility Support (8-12 hours)

**Total Critical**: 8-12 hours

---

### 🟠 HIGH (Should Do)
2. ✅ Add UI Tests (8-12 hours)
3. ✅ Add README & Documentation (2-3 hours)
4. ✅ Add API Documentation Comments (3-5 hours)

**Total High**: 13-20 hours

---

### 🟡 MEDIUM (Nice to Do)
5. ✅ Add Localization (6-10 hours)
6. ✅ Refactor AppViewModel (6-10 hours)
7. ✅ Performance Optimization (4-8 hours)
8. ✅ CI/CD Pipeline (4-6 hours)

**Total Medium**: 20-34 hours

---

### 🟢 LOW (Future)
9-15: Various enhancements

**Total Low**: 30-50 hours (estimated)

---

## Recommended Roadmap

### Phase 1: Production Release (Minimum Viable)
**Timeline**: 2-3 weeks
**Effort**: 21-32 hours

1. Add Accessibility Support (8-12 hours) - CRITICAL
2. Add README (2-3 hours) - HIGH
3. Add UI Tests (8-12 hours) - HIGH
4. Add API Documentation (3-5 hours) - HIGH

**Deliverable**: App ready for App Store submission

---

### Phase 2: Quality & International
**Timeline**: 3-4 weeks
**Effort**: 20-34 hours

5. Add Localization (6-10 hours)
6. Performance Optimization (4-8 hours)
7. CI/CD Pipeline (4-6 hours)
8. Refactor AppViewModel (6-10 hours)

**Deliverable**: International release with optimized codebase

---

### Phase 3: Enhanced Features
**Timeline**: Ongoing
**Effort**: 30-50 hours

9. Analytics & Crash Reporting
10. Export/Import Functionality
11. Data Backup
12. Enhanced Visualizations
13. Widgets
14. ADRs

**Deliverable**: Feature-rich version with analytics

---

## Quick Wins (< 2 hours each)

These can be done immediately for quick improvements:

- [ ] Add README.md (1 hour)
- [ ] Add CHANGELOG.md (30 min)
- [ ] Document DesignSystem.swift (1 hour)
- [ ] Add dark mode screenshots (1 hour)
- [ ] Create ADR template (30 min)
- [ ] Setup SwiftLint (1 hour)

---

## Next Steps

### Immediate Actions (This Week):
1. Start with accessibility labels (2-hour session)
2. Create README.md (1-hour session)
3. Setup UI test infrastructure (1-hour session)

### Week 1-2:
- Complete accessibility support
- Finish UI tests
- Add documentation comments

### Week 3-4:
- Localization infrastructure
- Performance profiling
- CI/CD setup

---

**Total Effort for Production-Ready Release**: 21-32 hours (Phase 1)
**Total Effort for Quality Release**: 41-66 hours (Phase 1 + 2)
**Total Effort for Feature-Complete**: 71-116 hours (All phases)
