# Unit Test Coverage for TenThousand

## Overview

This document describes the comprehensive unit test suite for the TenThousand app. All tests follow the principle of **testing behaviors, not implementations**, ensuring tests remain resilient to refactoring.

## Running Tests

### In Xcode
1. Open `TenThousand.xcodeproj`
2. Press `Cmd+U` to run all tests
3. View coverage report: Product → Show Code Coverage

### From Command Line
```bash
xcodebuild test -scheme TenThousand -destination 'platform=macOS'
```

### With Coverage Report
```bash
xcodebuild test -scheme TenThousand -destination 'platform=macOS' -enableCodeCoverage YES
```

## Test Suite Structure

### 1. TimerManagerTests (31 tests)

**Location:** `TenThousandTests/TimerManagerTests.swift`

**Behaviors Tested:**
- **Timer State Transitions** (13 tests)
  - Starting a timer transitions to running state
  - Starting an already running timer has no effect (idempotence)
  - Pausing a running timer transitions to paused state
  - Pausing a non-running timer has no effect
  - Pausing an already paused timer has no effect
  - Resuming a paused timer transitions back to running
  - Resuming a non-paused timer has no effect
  - Stopping a running timer resets state
  - Stopping a non-running timer returns zero
  - Stopping a paused timer includes elapsed time
  - Complete start-pause-resume-stop lifecycle
  - Multiple pause-resume cycles maintain running state
  - Restarting a stopped timer resets all state

- **Pause Duration Tracking** (2 tests)
  - Paused duration starts at zero
  - Paused duration remains zero when not paused

- **Time Formatting** (12 tests)
  - Zero seconds formats as "0:00"
  - Seconds only format as "M:SS"
  - Minutes and seconds format as "M:SS"
  - Hours format as "H:MM:SS"
  - Large hours format correctly
  - Zero seconds short format as "<1m"
  - Less than one minute short format as "<1m"
  - Minutes only short format as "Nm"
  - Hours only short format as "Nh"
  - Hours and minutes short format as "Nh Nm"
  - Short format ignores seconds
  - Large hours short format correctly

- **Edge Cases** (4 tests)
  - Boundary values format correctly
  - Negative values are handled gracefully

---

### 2. AppViewModelTests (34 tests)

**Location:** `TenThousandTests/AppViewModelTests.swift`

**Behaviors Tested:**
- **Skill Creation** (11 tests)
  - Creating a valid skill adds it to the skills list
  - Creating multiple skills adds them all
  - Creating a skill with whitespace trims the name
  - Creating a skill with only whitespace is rejected
  - Creating a skill with empty name is rejected
  - Creating a skill with name too long is rejected (>30 chars)
  - Creating a skill with exactly 30 characters is accepted
  - Creating duplicate skill names is rejected
  - Creating duplicate skill names with different whitespace is rejected
  - Creating skills assigns different color indices
  - Creating skill resets isAddingSkill flag

- **Skill Deletion** (2 tests)
  - Deleting a skill removes it from the list
  - Deleting one skill keeps others intact

- **Session Management** (7 tests)
  - Starting tracking creates an active session
  - Starting tracking on a new skill stops previous session
  - Pausing tracking pauses the timer
  - Resuming tracking resumes the timer
  - Stopping tracking clears active session
  - Stopping tracking saves the session
  - Stopping tracking sets justUpdatedSkillId temporarily

- **Statistics** (3 tests)
  - Today's total seconds is zero with no sessions
  - Today's skill count is zero with no sessions
  - Today's skill count counts unique skills

- **Heatmap Level Mapping** (8 tests)
  - Level 0: 0 seconds
  - Level 1: <15 minutes
  - Level 2: 15-29 minutes
  - Level 3: 30-59 minutes
  - Level 4: 60-119 minutes
  - Level 5: 120-179 minutes
  - Level 6: 180+ minutes
  - Boundary values are correct

- **Heatmap Data** (3 tests)
  - Heatmap data with no sessions returns all zeros
  - Heatmap data has correct structure (weeks × days)
  - Heatmap data with different weeks back has correct structure

---

### 3. DataModelTests (22 tests)

**Location:** `TenThousandTests/DataModelTests.swift`

**Behaviors Tested:**

#### Skill Model (9 tests)
- **Initialization**
  - Creating a skill sets all required properties
  - Creating a skill without color index defaults to 0
  - Creating a skill generates unique IDs
  - Creating a skill sets creation timestamp

- **totalSeconds Computed Property**
  - Skill with no sessions has zero total seconds
  - Skill with one session calculates total seconds correctly
  - Skill with multiple sessions sums total seconds
  - Skill total seconds excludes paused duration
  - Skill total seconds handles multiple sessions with pauses

#### Session Model (13 tests)
- **Initialization**
  - Creating a session sets all required properties
  - Creating a session generates unique IDs
  - Creating a session sets start time to now

- **durationSeconds Computed Property**
  - Session without end time uses current time for duration
  - Session with end time calculates exact duration
  - Session duration excludes paused time
  - Session with only paused time returns correct duration
  - Session duration is never negative
  - Session without start time returns zero duration
  - Session duration calculations are consistent

- **Skill-Session Relationship**
  - Session belongs to the correct skill
  - Skill contains its sessions
  - Multiple skills can have different sessions

---

### 4. PersistenceTests (17 tests)

**Location:** `TenThousandTests/PersistenceTests.swift`

**Behaviors Tested:**
- **Initialization** (4 tests)
  - Creating persistence controller with in-memory store succeeds
  - Creating persistence controller initializes view context
  - In-memory persistence controller uses null store
  - Regular persistence controller does not use null store

- **Save Operations** (4 tests)
  - Saving with no changes does nothing
  - Saving with changes persists data
  - Saved data can be fetched
  - Multiple saves accumulate data
  - Saving preserves relationships

- **Data Integrity** (3 tests)
  - Deleting and saving removes data
  - Updating and saving persists changes
  - Cascade delete removes related sessions

- **Concurrent Access** (1 test)
  - Merge policy handles concurrent updates

- **Context Merge** (1 test)
  - View context automatically merges changes from parent

- **Data Isolation** (1 test)
  - In-memory stores are isolated per instance

- **Fetch Requests** (3 tests)
  - Fetching with no data returns empty array
  - Fetching with predicate filters results
  - Fetching with sort descriptor orders results

---

## Test Statistics

| Test Suite | Test Count | Focus Area |
|------------|------------|------------|
| TimerManagerTests | 31 | Timer state, time calculations |
| AppViewModelTests | 34 | Skill/session management, statistics |
| DataModelTests | 22 | Computed properties, relationships |
| PersistenceTests | 17 | CoreData stack, CRUD operations |
| **Total** | **104** | **Comprehensive coverage** |

## Testing Philosophy

All tests follow these principles:

1. **Test Behaviors, Not Implementations**
   - Tests focus on WHAT the code does, not HOW
   - Tests verify inputs/outputs and state changes
   - Tests avoid checking internal implementation details
   - Tests remain resilient to refactoring

2. **Clear Test Names**
   - Each test name describes the expected behavior
   - Format: "test[Scenario][ExpectedBehavior]"
   - Example: `testCreateSkillRejectsDuplicates`

3. **Isolation**
   - Each test is independent and can run in any order
   - Tests use in-memory CoreData stores
   - No shared state between tests

4. **Comprehensive Edge Cases**
   - Boundary values (0, 1, max-1, max)
   - Empty/nil inputs
   - Invalid inputs
   - State transitions

## Code Coverage Goals

Target coverage by module:
- **TimerManager**: 95%+ (highly testable)
- **AppViewModel**: 85%+ (business logic)
- **Data Models**: 90%+ (computed properties)
- **Persistence**: 80%+ (infrastructure)
- **Overall**: 85%+

## Running Specific Test Suites

### Run only TimerManager tests
```bash
xcodebuild test -scheme TenThousand -destination 'platform=macOS' -only-testing:TenThousandTests/TimerManagerTests
```

### Run only AppViewModel tests
```bash
xcodebuild test -scheme TenThousand -destination 'platform=macOS' -only-testing:TenThousandTests/AppViewModelTests
```

### Run only DataModel tests
```bash
xcodebuild test -scheme TenThousand -destination 'platform=macOS' -only-testing:TenThousandTests/DataModelTests
```

### Run only Persistence tests
```bash
xcodebuild test -scheme TenThousand -destination 'platform=macOS' -only-testing:TenThousandTests/PersistenceTests
```

## Continuous Integration

To integrate with CI/CD:

```yaml
# Example GitHub Actions workflow
- name: Run Tests
  run: |
    xcodebuild test \
      -scheme TenThousand \
      -destination 'platform=macOS' \
      -enableCodeCoverage YES \
      -resultBundlePath TestResults

- name: Generate Coverage Report
  run: |
    xcrun xccov view --report TestResults.xcresult
```

## Next Steps

After running tests for the first time:
1. Review code coverage report
2. Identify any uncovered edge cases
3. Add integration tests for complete workflows
4. Consider adding UI tests for critical user journeys

## Maintenance

When adding new features:
1. Write tests FIRST (TDD approach)
2. Focus on behaviors, not implementations
3. Ensure tests are isolated and independent
4. Maintain the behavior-based naming convention
