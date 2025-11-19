---
description: Enforce project code conventions - eliminate magic literals, use named constants
---

# Code Conventions Skill

You are helping to enforce code conventions for this Swift/SwiftUI project.

## Core Mission

**Eliminate ALL magic literals from the codebase. Every string and number should be a named constant.**

## Primary Responsibilities

1. **Detect magic literals** (raw strings, numbers) in code
2. **Suggest refactorings** to named constants
3. **Enforce CODE_CONVENTIONS.md** standards
4. **Guide proper constant organization** (local vs project-wide)

## What to Look For

### Magic Literals to Flag

❌ **Strings:**
- `.init("n")` - keyboard shortcuts
- `"Error: "` - error messages
- `"admin"` - usernames or identifiers
- `"GET"` - HTTP methods
- Any hardcoded string that could be reused or has meaning

❌ **Numbers:**
- `.frame(width: 320)` - UI dimensions
- `.padding(16)` - spacing values
- `.cornerRadius(12)` - visual properties
- `retry(maxAttempts: 3)` - configuration values
- `.opacity(0.5)` - alpha values
- `sleep(5)` - timing values

### Patterns to Search For

Use these grep patterns when reviewing:
- `\.init\("` - inline string initializers
- `\(".*"\)` - string literals in function calls
- `\d+\.?\d*` - number literals (exclude array indices)
- `width: \d+` - dimension literals
- `padding\(\d+` - spacing literals

## Constant Organization Rules

### Local Constants (File-Specific)

Use `private enum Const` for values used only in one file:

```swift
private enum Const {
    static let maxRetries = 3
    static let defaultTimeout: TimeInterval = 30
    static let errorPrefix = "Error: "
}
```

**Use for:**
- File-specific implementation details
- One-off values not shared elsewhere
- Temporary or experimental constants

### Domain-Specific Enums (Project-Wide)

Use domain enums for values used across multiple files:

```swift
enum KeyboardShortcuts {
    static let addSkill = KeyEquivalent("n")
}

enum Dimensions {
    static let panelWidth: CGFloat = 320
}

enum Spacing {
    static let base: CGFloat = 16
}
```

**Use for:**
- UI dimensions and spacing (Dimensions, Spacing)
- Keyboard shortcuts (KeyboardShortcuts)
- Colors and themes (Colors, Theme)
- Animation durations (Animations)
- API configuration (API, Endpoints)

## Review Process

When reviewing code:

1. **Read CODE_CONVENTIONS.md** first
2. **Search for magic literals** using grep/search
3. **Categorize findings**:
   - File-local → `private enum Const`
   - Project-wide → domain enum (create if needed)
4. **Propose refactoring** with before/after examples
5. **Implement approved changes**
6. **Verify improved clarity**

## Example Workflow

### Step 1: Detect

Search for `.init("` in Swift files:
```bash
grep -r '\.init("' --include="*.swift"
```

### Step 2: Analyze

Found: `.onKeyPress(keys: [.init("n")]`

**Assessment:**
- Type: String literal for keyboard shortcut
- Scope: Could be reused across project
- Action: Add to domain enum

### Step 3: Refactor

**Before:**
```swift
.onKeyPress(keys: [.init("n")], phases: .down)
```

**After:**
```swift
// Add to KeyboardShortcuts enum
enum KeyboardShortcuts {
    static let addSkill = KeyEquivalent("n")
}

// Use named constant
.onKeyPress(keys: [KeyboardShortcuts.addSkill], phases: .down)
```

### Step 4: Verify

- ✅ More readable
- ✅ Searchable with cmd+click
- ✅ Single source of truth
- ✅ Self-documenting

## Common Refactorings

### UI Dimensions

**Before:**
```swift
.frame(width: 320, height: 200)
.padding(16)
.cornerRadius(12)
```

**After:**
```swift
private enum Const {
    static let width: CGFloat = 320
    static let height: CGFloat = 200
    static let padding: CGFloat = 16
    static let cornerRadius: CGFloat = 12
}

.frame(width: Const.width, height: Const.height)
.padding(Const.padding)
.cornerRadius(Const.cornerRadius)
```

### String Literals

**Before:**
```swift
let message = "Error: Invalid input"
if username == "admin" { }
```

**After:**
```swift
private enum Const {
    static let errorPrefix = "Error: "
    static let adminUsername = "admin"
}

let message = "\(Const.errorPrefix)Invalid input"
if username == Const.adminUsername { }
```

### Configuration Values

**Before:**
```swift
retry(maxAttempts: 3, delay: 5)
```

**After:**
```swift
private enum Const {
    static let maxRetries = 3
    static let retryDelay: TimeInterval = 5
}

retry(maxAttempts: Const.maxRetries, delay: Const.retryDelay)
```

## Acceptable Exceptions

These are OK without constants:

1. Array indices: `array[0]`, `items[1]`
2. Simple boolean assignment: `isEnabled = true`
3. Trivial separators: `.split(separator: ",")`
4. Simple arithmetic: `x * 2`, `count + 1`
5. Conventional zero: `.cornerRadius(0)` to disable

**When in doubt, create a constant.**

## Commands to Run

### Find potential issues:
```bash
# String literals
grep -rn '\.init("' --include="*.swift"

# Likely magic numbers in UI
grep -rn 'width: [0-9]' --include="*.swift"
grep -rn 'padding([0-9]' --include="*.swift"
grep -rn 'cornerRadius([0-9]' --include="*.swift"
```

### Check for existing constant enums:
```bash
grep -rn '^enum.*{' --include="*.swift" | grep -i 'const\|spacing\|dimension\|color'
```

## Tips

- **Start with obvious wins**: Keyboard shortcuts, repeated strings
- **Group related constants**: All spacing in one enum, all colors in another
- **Use descriptive names**: `maxRetryCount` not `three`
- **Document non-obvious values**: `// 320px matches design spec`
- **Be consistent**: If one dimension is a constant, all should be

## Always Reference

Read `/home/user/TenThousand/CODE_CONVENTIONS.md` before making recommendations.
