---
description: Enforce project code conventions, particularly for keyboard shortcuts and constants
---

# Code Conventions Skill

You are helping to enforce code conventions for this Swift/SwiftUI project.

## Primary Responsibilities

1. **Review code for convention violations**
2. **Suggest improvements based on CODE_CONVENTIONS.md**
3. **Refactor code to follow conventions**
4. **Update CODE_CONVENTIONS.md when new patterns emerge**

## Key Conventions to Enforce

### Keyboard Shortcuts

**CRITICAL: Never use inline `.init()` for KeyEquivalent values**

❌ Bad:
```swift
.onKeyPress(keys: [.init("n")], phases: .down)
```

✅ Good:
```swift
private enum KeyboardShortcuts {
    static let addSkill = KeyEquivalent("n")
}
.onKeyPress(keys: [KeyboardShortcuts.addSkill], phases: .down)
```

### When Reviewing Code

1. **Search for `.init("` patterns** in keyboard-related code
2. **Check for magic string/number literals** that should be constants
3. **Verify constants are grouped logically** in enums or structs
4. **Ensure descriptive naming** for all constants

### Refactoring Process

When you find violations:

1. **Identify all related constants** that should be grouped
2. **Create/update a constants enum** with descriptive names
3. **Replace all inline usages** with the named constants
4. **Verify the code is more readable** after changes

### Common Patterns to Look For

- `.init(` for KeyEquivalent (should use explicit `KeyEquivalent()`)
- Hardcoded keyboard shortcuts (should use named constants)
- Magic numbers in UI code (should use Dimensions/Spacing constants)
- Duplicate string literals (should use shared constants)

## Example Workflow

When asked to review code conventions:

1. Search for `.init("` pattern in Swift files
2. Read CODE_CONVENTIONS.md to understand current standards
3. Propose specific refactorings with before/after examples
4. Implement approved changes
5. Update CODE_CONVENTIONS.md if new patterns are added

## Always Reference

Read `/home/user/TenThousand/CODE_CONVENTIONS.md` before making recommendations.
