# Code Conventions

## Core Principle: No Magic Literals

**Never use raw string or number literals directly in code. Always use named constants.**

Magic literals are hard to find, easy to mistype, and difficult to maintain. Named constants are self-documenting, searchable, and provide a single source of truth.

## Constant Organization

### Local Constants (File-Specific)

Use `private enum Const` for constants used only within a single file:

```swift
private enum Const {
    static let maxRetries = 3
    static let timeoutSeconds = 30.0
    static let defaultUsername = "Guest"
    static let errorPrefix = "Error: "
}

func performRequest() {
    retry(maxAttempts: Const.maxRetries, timeout: Const.timeoutSeconds)
}
```

### Domain-Specific Constants (Project-Wide)

Use domain-specific enums (or structs) for constants used across multiple files.

**This project uses `DesignSystem.swift` for UI constants. Always check there first before creating new constants.**

Existing design system constants:
- `Dimensions.*` - Panel widths, heights, corner radii
- `Spacing.*` - Atomic, tight, base, loose, section, chunk
- `Typography.*` - Display, body, caption, time display fonts
- `Shadows.*` - Shadow configurations
- `Animation.*` - Micro interaction, panel transition, etc.
- `Color.*` - Named color palette (pureWhite, graphite, trackingBlue, etc.)

For new domain constants:

```swift
// Add to DesignSystem.swift or create domain-specific files

enum KeyboardShortcuts {
    static let addSkill = KeyEquivalent("n")
    static let stopTracking = KeyEquivalent(".")
}

enum APIEndpoints {
    static let baseURL = "https://api.example.com"
    static let timeout: TimeInterval = 30
}
```

**Note:** Both `enum` and `struct` work for constant namespaces. This project uses `struct` in DesignSystem.swift. Use `enum` to prevent accidental instantiation, or `struct` to match existing patterns.

## Examples by Category

### ❌ Bad: Magic Literals

```swift
// Strings
.onKeyPress(keys: [.init("n")], phases: .down)
let message = "Error: Invalid input"
if username == "admin" { }

// Numbers
.frame(width: 320, height: 200)
.padding(16)
.cornerRadius(12)
retry(maxAttempts: 3)
sleep(for: .seconds(5))

// Booleans in complex logic
if shouldValidate == true && userType == 2 { }
```

### ✅ Good: Named Constants

```swift
// Local file constants
private enum Const {
    static let defaultWidth: CGFloat = 320
    static let defaultHeight: CGFloat = 200
    static let cornerRadius: CGFloat = 12
    static let basePadding: CGFloat = 16
    static let maxRetries = 3
    static let retryDelay: TimeInterval = 5
    static let errorPrefix = "Error: "
    static let adminUsername = "admin"
}

// Usage
.frame(width: Const.defaultWidth, height: Const.defaultHeight)
.padding(Const.basePadding)
.cornerRadius(Const.cornerRadius)
retry(maxAttempts: Const.maxRetries)
sleep(for: .seconds(Const.retryDelay))
let message = "\(Const.errorPrefix)Invalid input"
if username == Const.adminUsername { }

// Project-wide domain constants
.onKeyPress(keys: [KeyboardShortcuts.addSkill], phases: .down)
.frame(width: Dimensions.panelWidth)
.padding(Spacing.base)
```

## When to Use Which Approach

### Use `private enum Const`

- Constants used only in one file
- Implementation details
- Temporary or experimental values
- File-specific magic numbers

### Use Domain-Specific Enums

- Values used across multiple files
- UI dimensions and spacing
- Colors and themes
- Animation durations
- API endpoints and keys
- Keyboard shortcuts
- Common business logic values

### Exceptions (Rare)

These literals are acceptable without constants:

1. **Array indices**: `array[0]`, `items[1]`
2. **Boolean literals in simple assignment**: `isEnabled = true`
3. **Single-character strings in trivial context**: `components(separatedBy: ",")`
4. **Simple math**: `x * 2`, `count + 1` (but not domain-specific calculations)
5. **Well-known conventions**: `cornerRadius: 0` to disable rounding

## Guidelines

### Naming Constants

- Use descriptive names: `maxRetryCount` not `three`
- Indicate units: `timeoutSeconds`, `widthPixels`, `delayMilliseconds`
- Group by purpose: `KeyboardShortcuts.addItem` not `Keys.n`
- Avoid redundancy: `Spacing.base` not `Spacing.baseSpacing`

### Organizing Constants

1. **Keep related constants together** in a single enum
2. **Use namespacing** to avoid polluting global scope
3. **Make enums `private`** when possible to limit visibility
4. **Document non-obvious values** with comments
5. **Prefer static over computed** for true constants

### Type Safety

Avoid `.init()` shortcuts that obscure types:

❌ Bad:
```swift
.onKeyPress(keys: [.init("n")], phases: .down)
```

✅ Good:
```swift
private enum Const {
    static let addKey = KeyEquivalent("n")
}
.onKeyPress(keys: [Const.addKey], phases: .down)
```

## Benefits

1. **Searchability**: Find all usages with cmd+click
2. **Type Safety**: Compiler catches type mismatches
3. **Single Source of Truth**: Change once, update everywhere
4. **Self-Documenting**: `Dimensions.panelWidth` is clearer than `320`
5. **Refactoring Safety**: Rename constants safely across codebase
6. **Testing**: Mock or override constants easily
7. **Consistency**: Reuse exact values, prevent typos

## Migration Strategy

When you find magic literals:

1. **Identify the scope** (file-local or project-wide)
2. **Create or find the appropriate constant enum**
3. **Add a well-named constant** with the literal value
4. **Replace all occurrences** with the named constant
5. **Verify the code is more readable** after the change

---

# Swift/SwiftUI/Combine Code Conventions

## Naming Conventions

### General
- Use clear, descriptive names that reveal intent
- Prefer clarity over brevity
- Use American English spelling

### Types
- **Classes, Structs, Enums, Protocols**: `PascalCase`
  ```swift
  class UserManager { }
  struct UserProfile { }
  enum NetworkError { }
  protocol DataProviding { }
  ```

### Variables & Functions
- **Variables, constants, functions**: `camelCase`
  ```swift
  let userName = "John"
  var isAuthenticated = false
  func fetchUserData() { }
  ```

### Protocols
- Use `-able`, `-ible`, or `-ing` suffixes for capability protocols
  ```swift
  protocol Cancellable { }
  protocol Refreshable { }
  ```

## SwiftUI Conventions

### View Structure
```swift
struct ContentView: View {
    // MARK: - Properties
    @StateObject private var viewModel: ContentViewModel
    @State private var isPresented = false
    @Environment(\.dismiss) private var dismiss

    // MARK: - Body
    var body: some View {
        content
    }

    // MARK: - Views
    private var content: some View {
        VStack {
            // Implementation
        }
    }
}
```

### View Composition
- Extract complex views into computed properties or separate view structs
- Keep `body` simple and readable
- Use `@ViewBuilder` for conditional view logic

### State Management
- `@State`: Local view state only
- `@StateObject`: Own the lifecycle of ObservableObject
- `@ObservedObject`: Passed from parent
- `@EnvironmentObject`: Shared across view hierarchy
- `@Environment`: System values

## Combine Conventions

### Publishers
- Prefix custom publishers with `Publisher` or suffix with `Publisher`
  ```swift
  final class DataPublisher { }
  var userUpdatesPublisher: AnyPublisher<User, Never>
  ```

### Subscriptions
- Store cancellables in `Set<AnyCancellable>` or `@Published` property
  ```swift
  private var cancellables = Set<AnyCancellable>()
  ```

### Naming
- Use descriptive names for publisher chains
  ```swift
  let validatedEmailPublisher = emailPublisher
      .map { $0.isValidEmail }
      .eraseToAnyPublisher()
  ```

## Architecture

### MVVM Pattern
```
Models/          # Data structures
ViewModels/      # Business logic, Combine publishers
Views/           # SwiftUI views
Services/        # API, persistence, etc.
Utilities/       # Extensions, helpers
```

### ViewModels
```swift
final class ContentViewModel: ObservableObject {
    @Published var items: [Item] = []
    @Published var isLoading = false

    private let service: DataService
    private var cancellables = Set<AnyCancellable>()

    init(service: DataService) {
        self.service = service
        setupBindings()
    }

    func fetchData() {
        // Implementation
    }

    private func setupBindings() {
        // Setup Combine pipelines
    }
}
```

## Code Organization

### File Structure
- One type per file
- File name matches type name
- Group related files in folders

### MARK Comments
Use MARK to organize code sections:
```swift
// MARK: - Properties
// MARK: - Lifecycle
// MARK: - Public Methods
// MARK: - Private Methods
// MARK: - Actions
```

## Swift Best Practices

### Optionals
- Avoid force unwrapping (`!`) in production code
- Use optional binding or nil coalescing
  ```swift
  if let user = optionalUser { }
  let name = user?.name ?? "Unknown"
  ```

### Access Control
- Default to `private` or `fileprivate`
- Mark public API explicitly
- Use `internal` sparingly

### Properties
- Prefer `let` over `var` when possible
- Use computed properties for derived values
- Lazy properties for expensive initialization

### Error Handling
```swift
enum NetworkError: LocalizedError {
    case invalidURL
    case noData

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .noData: return "No data received"
        }
    }
}
```

## SwiftUI Specific

### Modifiers Order
Apply modifiers in logical order:
1. Layout modifiers (frame, padding)
2. Visual modifiers (background, foregroundStyle)
3. Interaction modifiers (onTapGesture)
4. Accessibility modifiers

### PreviewProvider
```swift
#Preview {
    ContentView()
        .environmentObject(AppState())
}
```

## Combine Patterns

### Resource Cleanup
```swift
cancellable?.cancel()
cancellables.removeAll()
```

### Avoiding Retain Cycles
```swift
publisher
    .sink { [weak self] value in
        self?.handleValue(value)
    }
    .store(in: &cancellables)
```

### Error Handling
```swift
dataPublisher
    .catch { error -> Just<DefaultValue> in
        print("Error: \(error)")
        return Just(defaultValue)
    }
    .sink { value in }
    .store(in: &cancellables)
```

## Comments

- Write self-documenting code
- Comment "why" not "what"
- Use `///` for documentation comments
- Keep comments up to date

## Testing

- Prefix test methods with `test`
  ```swift
  func testUserLoginSuccess() { }
  ```
- Use descriptive test names
- Follow Arrange-Act-Assert pattern

## Version Control

- Commit messages: Imperative mood ("Add feature" not "Added feature")
- Keep commits atomic and focused
- Reference issue numbers when applicable
