# Code Conventions

## SwiftUI Keyboard Handling

### KeyEquivalent Constants

**Always use named constants for keyboard shortcuts instead of inline initializers.**

❌ **Bad - Prone to bugs and unclear:**
```swift
.onKeyPress(keys: [.init("n")], phases: .down) { press in
    // handler
}
```

✅ **Good - Clear and maintainable:**
```swift
private enum KeyboardShortcuts {
    static let addSkill = KeyEquivalent("n")
    static let stopTracking = KeyEquivalent(".")
}

.onKeyPress(keys: [KeyboardShortcuts.addSkill], phases: .down) { press in
    // handler
}
```

### Why This Matters

1. **Type Safety**: Explicit `KeyEquivalent` type is clear and prevents confusion
2. **Searchability**: Named constants can be found with cmd+click and search
3. **Single Source of Truth**: Change a shortcut in one place
4. **Self-Documenting**: `KeyboardShortcuts.addSkill` is clearer than `.init("n")`
5. **Refactoring Safety**: Renaming/moving constants is easier than finding string literals

### Guidelines

1. **Group related shortcuts** in an enum or struct
2. **Use descriptive names** that indicate the action (e.g., `addSkill`, not `nKey`)
3. **Document complex shortcuts** with comments explaining their purpose
4. **Place constants near their usage** (private to file/view if local, shared if global)

## General Swift Conventions

### Naming

- Use descriptive names that clearly indicate purpose
- Avoid abbreviations unless widely understood
- Prefer clarity over brevity

### Constants Organization

- Group related constants in enums or structs
- Use `private` scope when constants are file-specific
- Use clear namespacing (e.g., `KeyboardShortcuts`, `Dimensions`, `Colors`)

### Code Clarity

- Avoid "magic values" - use named constants
- Prefer explicit types over type inference when it improves clarity
- Use `.init()` sparingly - prefer explicit type names for non-obvious types
