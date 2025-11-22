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

## Additional Conventions to Enforce

Beyond magic literals, enforce these Swift/SwiftUI/Combine standards from CODE_CONVENTIONS.md:

### Naming
- **Types**: PascalCase (UserManager, NetworkError)
- **Variables/Functions**: camelCase (userName, fetchData)
- **Protocols**: Use -able, -ible, -ing suffixes (Cancellable, Refreshable)

### SwiftUI View Structure
```swift
struct ContentView: View {
    // MARK: - Properties
    @StateObject private var viewModel: ContentViewModel

    // MARK: - Body
    var body: some View {
        content
    }

    // MARK: - Views
    private var content: some View {
        VStack { }
    }
}
```

### Access Control
- Default to `private` or `fileprivate`
- Avoid force unwrapping (`!`)
- Prefer `let` over `var`

### Code Organization
- Use MARK comments to organize sections
- One type per file
- File name matches type name

### Combine
- Store cancellables: `private var cancellables = Set<AnyCancellable>()`
- Avoid retain cycles: Use `[weak self]` in closures
- Suffix publishers: `userUpdatesPublisher`

### SwiftUI Modifiers
Apply in order:
1. Layout (frame, padding)
2. Visual (background, foregroundStyle)
3. Interaction (onTapGesture)
4. Accessibility

## Common Issues to Flag

1. **Magic literals** (primary focus)
2. **Force unwrapping** (`!`) without justification
3. **Missing MARK comments** in large files
4. **var instead of let** when value doesn't change
5. **Poor naming** (abbreviations, unclear intent)
6. **Missing access control** (should be private)
7. **Retain cycles** in Combine/closures (missing [weak self])

## Always Reference

Read `/home/user/TenThousand/CODE_CONVENTIONS.md` before making recommendations. The file now contains:
- Magic literals elimination (primary focus)
- Swift/SwiftUI/Combine naming conventions
- Architecture patterns (MVVM)
- Code organization standards
- Best practices for optionals, access control, error handling
- Testing and version control guidelines

---

# Comprehensive Swift/SwiftUI/Combine Code Conventions
## macOS Development Guide

---

## Table of Contents
1. [Naming Conventions](#naming-conventions)
2. [File Organization](#file-organization)
3. [SwiftUI Best Practices](#swiftui-best-practices)
4. [Combine Framework Patterns](#combine-framework-patterns)
5. [Architecture & Design Patterns](#architecture--design-patterns)
6. [Design System](#design-system)
7. [Code Style & Formatting](#code-style--formatting)
8. [Error Handling](#error-handling)
9. [Concurrency & Threading](#concurrency--threading)
10. [Performance Optimization](#performance-optimization)
11. [Accessibility](#accessibility)
12. [Localization](#localization)
13. [Security Best Practices](#security-best-practices)
14. [Testing](#testing)
15. [Documentation](#documentation)
16. [Version Control](#version-control)

---

## Naming Conventions

### General Principles
- **Clarity over brevity**: Names should be self-documenting
- **Avoid abbreviations**: Use `button` not `btn`, `configuration` not `config`
- **Exception**: Well-known abbreviations are acceptable (`URL`, `ID`, `HTTP`, `UI`, `min`, `max`)
- **American English spelling**: Use `color` not `colour`, `center` not `centre`
- **Avoid prefixes**: Swift uses namespaces, so avoid Hungarian notation or type prefixes

### Types

#### Classes
```swift
// ✅ Good
class NetworkManager { }
class UserProfileViewController { }
class DataCache { }

// ❌ Bad
class networkManager { }  // Should be PascalCase
class NMgr { }             // Too abbreviated
class TDataCache { }       // Unnecessary prefix
```

#### Structs
```swift
// ✅ Good
struct User { }
struct APIRequest { }
struct Coordinates { }

// ❌ Bad
struct user { }
struct UserStruct { }  // Redundant suffix
```

#### Enums
```swift
// ✅ Good - Singular name
enum Result { }
enum NetworkError { }
enum HTTPMethod { }

// ❌ Bad - Plural name
enum Results { }
enum NetworkErrors { }

// Enum cases - lowercase camelCase
enum CompassPoint {
    case north
    case south
    case east
    case west
}

// Associated values with labels
enum FileError {
    case notFound(path: String)
    case permissionDenied(path: String, reason: String)
    case corrupted(details: ErrorDetails)
}
```

#### Protocols
```swift
// ✅ Good - Capability protocols use -able, -ible, -ing
protocol Equatable { }
protocol Comparable { }
protocol Cancellable { }
protocol DataProviding { }
protocol ViewModeling { }

// ✅ Good - Requirements protocols use noun
protocol DataSource { }
protocol Delegate { }
protocol Repository { }

// ❌ Bad
protocol EquatableProtocol { }  // Redundant suffix
protocol IComparable { }        // Language-specific prefix
```

#### Type Aliases
```swift
// ✅ Good
typealias CompletionHandler = (Result<Data, Error>) -> Void
typealias JSONDictionary = [String: Any]
typealias UserID = UUID

// Use for clarity in complex generic types
typealias StringKeyedDictionary<T> = [String: T]
```

### Properties and Variables

#### General Variables
```swift
// ✅ Good - Descriptive, camelCase
let maximumRetryCount = 3
var isUserAuthenticated = false
let defaultBackgroundColor = NSColor.white

// ❌ Bad
let maxRetryCnt = 3           // Abbreviated
let is_user_authenticated = false  // Snake case
let kDefaultBackgroundColor = NSColor.white  // Unnecessary prefix
```

#### Boolean Properties
```swift
// ✅ Good - Read as assertions
var isEmpty: Bool
var isEnabled: Bool
var hasChildren: Bool
var canEdit: Bool
var shouldRefresh: Bool

// ❌ Bad
var empty: Bool        // Not clear if it's a state
var enabled: Bool
var isNotEmpty: Bool   // Double negative
```

#### Collections
```swift
// ✅ Good - Plural for collections
var users: [User]
var activeConnections: Set<Connection>
var usersByID: [UUID: User]

// ❌ Bad
var user: [User]              // Not plural
var userArray: [User]         // Type in name
var activeConnectionsSet: Set<Connection>  // Redundant suffix
```

#### Constants
```swift
// ✅ Good - Use let, descriptive names
let maximumNumberOfLoginAttempts = 3
let defaultAnimationDuration: TimeInterval = 0.3
let apiBaseURL = URL(string: "https://api.example.com")!

// For global constants, use static let in appropriate namespace
enum AppConstants {
    static let maxUploadSize = 10_000_000  // 10MB
    static let timeoutInterval: TimeInterval = 30
}

// ❌ Bad
let MAX_LOGIN_ATTEMPTS = 3    // Screaming snake case
var maxLoginAttempts = 3      // Should be let, not var
```

### Functions and Methods

#### General Functions
```swift
// ✅ Good - Verb phrases, describe what they do
func fetchUserData()
func validateEmail(_ email: String) -> Bool
func convert(_ temperature: Double, from: TemperatureUnit, to: TemperatureUnit) -> Double

// ❌ Bad
func user()              // Not descriptive
func data()              // Vague
func getUserData()       // Unnecessary 'get' prefix
```

#### Factory Methods
```swift
// ✅ Good - Use make prefix
func makeUserViewModel() -> UserViewModel
func makeNetworkRequest(for endpoint: Endpoint) -> URLRequest

// Or use static factory methods
extension User {
    static func guest() -> User
    static func registered(with credentials: Credentials) -> User
}
```

#### Boolean Methods
```swift
// ✅ Good - Read as assertions
func isValid() -> Bool
func hasPrefix(_ prefix: String) -> Bool
func canPerformAction() -> Bool
func shouldUpdateUI() -> Bool

// ❌ Bad
func valid() -> Bool
func checkPrefix(_ prefix: String) -> Bool  // Use 'has' instead
```

#### Parameter Labels
```swift
// ✅ Good - Read like a sentence
func insert(_ element: Element, at index: Int)
func move(from start: Index, to end: Index)
func compare(_ lhs: Value, with rhs: Value) -> Bool

// Omit first parameter label when it's clear from method name
func remove(_ element: Element)
func validate(_ email: String) -> Bool

// ❌ Bad
func insert(element: Element, index: Int)  // Doesn't read well
func move(start: Index, end: Index)        // Unclear parameter roles
```

### SwiftUI Specific Naming

#### Views
```swift
// ✅ Good - Descriptive, ends with View (optional but recommended)
struct LoginView: View { }
struct UserProfileCard: View { }
struct SettingsPanel: View { }

// For view modifiers
struct CustomCardModifier: ViewModifier { }
extension View {
    func customCard() -> some View {
        modifier(CustomCardModifier())
    }
}
```

#### View Models
```swift
// ✅ Good - Matches view name + ViewModel
class LoginViewModel: ObservableObject { }
class UserProfileViewModel: ObservableObject { }
final class SettingsViewModel: ObservableObject { }

// ❌ Bad
class LoginVM: ObservableObject { }  // Abbreviated
class Login: ObservableObject { }    // Doesn't indicate it's a view model
```

#### Property Wrappers
```swift
// State properties - describe the state
@State private var isPresented = false
@State private var selectedUser: User?
@State private var searchQuery = ""

// Published properties in ViewModels
@Published var items: [Item] = []
@Published var isLoading = false
@Published var errorMessage: String?

// Environment and bindings
@Environment(\.dismiss) private var dismiss
@EnvironmentObject private var appState: AppState
@Binding var isSelected: Bool
```

### Combine Naming

#### Publishers
```swift
// ✅ Good - Suffix with Publisher or describe the stream
let userUpdatesPublisher: AnyPublisher<User, Never>
let networkResponsePublisher: AnyPublisher<Data, NetworkError>
var textFieldPublisher: Published<String>.Publisher

// For custom publishers
class DataStreamPublisher: Publisher {
    typealias Output = Data
    typealias Failure = Error
}
```

#### Subjects
```swift
// ✅ Good - Describe what they publish
private let userActionSubject = PassthroughSubject<UserAction, Never>()
private let errorSubject = PassthroughSubject<Error, Never>()
```

#### Cancellables
```swift
// ✅ Good
private var cancellables = Set<AnyCancellable>()
private var requestCancellable: AnyCancellable?

// For specific subscriptions
private var timerCancellable: AnyCancellable?
private var networkCancellable: AnyCancellable?
```

---

## File Organization

### Project Structure
```
ProjectName/
├── App/
│   ├── ProjectNameApp.swift      # App entry point
│   ├── AppDelegate.swift         # macOS-specific app delegate
│   └── AppState.swift            # Global app state
├── Models/
│   ├── User.swift
│   ├── Post.swift
│   └── APIModels/
│       ├── UserResponse.swift
│       └── ErrorResponse.swift
├── ViewModels/
│   ├── LoginViewModel.swift
│   ├── UserProfileViewModel.swift
│   └── SettingsViewModel.swift
├── Views/
│   ├── Login/
│   │   ├── LoginView.swift
│   │   └── LoginFormView.swift
│   ├── UserProfile/
│   │   ├── UserProfileView.swift
│   │   ├── ProfileHeaderView.swift
│   │   └── ProfileStatsView.swift
│   ├── Settings/
│   │   └── SettingsView.swift
│   └── Components/
│       ├── CustomButton.swift
│       ├── LoadingView.swift
│       └── ErrorView.swift
├── Services/
│   ├── NetworkService.swift
│   ├── AuthenticationService.swift
│   ├── DatabaseService.swift
│   └── Analytics/
│       └── AnalyticsService.swift
├── Utilities/
│   ├── Extensions/
│   │   ├── String+Extensions.swift
│   │   ├── Date+Extensions.swift
│   │   └── View+Extensions.swift
│   ├── Helpers/
│   │   ├── ValidationHelper.swift
│   │   └── FormattingHelper.swift
│   └── Constants/
│       └── AppConstants.swift
├── Resources/
│   ├── Assets.xcassets
│   ├── Localizable.strings
│   └── Colors.xcassets
└── Tests/
    ├── UnitTests/
    ├── IntegrationTests/
    └── UITests/
```

### File Naming
- One primary type per file
- File name matches the primary type name
- Use descriptive folder names
- Group related functionality

```swift
// ✅ Good
User.swift              // Contains User struct
UserViewModel.swift     // Contains UserViewModel class
String+Extensions.swift // String extensions
NetworkService.swift    // NetworkService class

// ❌ Bad
Models.swift           // Multiple unrelated models
Utils.swift            // Grab bag of utilities
Extensions.swift       // All extensions mixed together
```

### File Organization Within a File

```swift
// MARK: - Imports
import SwiftUI
import Combine

// MARK: - Type Definition
struct UserProfileView: View {

    // MARK: - Properties

    // Property wrappers first
    @StateObject private var viewModel: UserProfileViewModel
    @State private var isEditMode = false
    @Environment(\.dismiss) private var dismiss

    // Regular properties
    private let userId: UUID

    // MARK: - Initialization

    init(userId: UUID) {
        self.userId = userId
        _viewModel = StateObject(wrappedValue: UserProfileViewModel(userId: userId))
    }

    // MARK: - Body

    var body: some View {
        content
            .navigationTitle("Profile")
            .toolbar { toolbarContent }
    }

    // MARK: - Views

    private var content: some View {
        ScrollView {
            VStack(spacing: 20) {
                profileHeader
                profileStats
                profileActions
            }
            .padding()
        }
    }

    private var profileHeader: some View {
        // Implementation
    }

    private var profileStats: some View {
        // Implementation
    }

    private var profileActions: some View {
        // Implementation
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button("Edit") { isEditMode = true }
        }
    }

    // MARK: - Actions

    private func handleEditAction() {
        // Implementation
    }

    private func handleSaveAction() {
        // Implementation
    }
}

// MARK: - Preview

#Preview {
    UserProfileView(userId: UUID())
}
```

---

## SwiftUI Best Practices

### View Composition

#### Keep Body Simple
```swift
// ✅ Good - Body delegates to computed properties
struct DashboardView: View {
    var body: some View {
        content
    }

    private var content: some View {
        VStack {
            header
            statistics
            recentActivity
        }
    }

    private var header: some View {
        // Complex header implementation
    }

    private var statistics: some View {
        // Statistics view
    }

    private var recentActivity: some View {
        // Recent activity list
    }
}

// ❌ Bad - Everything in body
struct DashboardView: View {
    var body: some View {
        VStack {
            // 100+ lines of view code here
        }
    }
}
```

#### Extract Complex Views
```swift
// ✅ Good - Separate view for reusable component
struct StatisticCard: View {
    let title: String
    let value: String
    let trend: Double

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)

                TrendIndicator(value: trend)
            }
        }
        .padding()
        .background(.background.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// Then use in main view
struct DashboardView: View {
    var body: some View {
        HStack {
            StatisticCard(title: "Revenue", value: "$45,231", trend: 0.15)
            StatisticCard(title: "Users", value: "2,543", trend: -0.05)
        }
    }
}
```

#### ViewBuilder for Conditional Views
```swift
// ✅ Good - Clean conditional rendering
struct ContentView: View {
    @StateObject private var viewModel: ContentViewModel

    var body: some View {
        content
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            LoadingView()
        case .loaded(let data):
            DataView(data: data)
        case .error(let error):
            ErrorView(error: error, retry: viewModel.retry)
        case .empty:
            EmptyStateView()
        }
    }
}

// ❌ Bad - Nested ifs
var body: some View {
    if viewModel.isLoading {
        LoadingView()
    } else {
        if let data = viewModel.data {
            DataView(data: data)
        } else {
            if let error = viewModel.error {
                ErrorView(error: error)
            } else {
                EmptyStateView()
            }
        }
    }
}
```

### State Management

#### State Property Wrapper Usage

```swift
// @State - Private, view-local state
struct CounterView: View {
    @State private var count = 0  // Only this view needs this

    var body: some View {
        Button("Count: \(count)") {
            count += 1
        }
    }
}

// @StateObject - Own the lifecycle
struct UserProfileView: View {
    @StateObject private var viewModel = UserProfileViewModel()

    var body: some View {
        // View implementation
    }
}

// @ObservedObject - Passed from parent
struct UserDetailView: View {
    @ObservedObject var viewModel: UserViewModel

    var body: some View {
        // View implementation
    }
}

// @EnvironmentObject - Shared across hierarchy
struct SettingsView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        // View implementation
    }
}

// @Binding - Two-way binding to parent's state
struct ToggleRow: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(title, isOn: $isOn)
    }
}
```

#### When to Use Each Wrapper

| Wrapper | Use When | Ownership |
|---------|----------|-----------|
| `@State` | Simple value types, view-local state | View owns |
| `@StateObject` | Creating ObservableObject in view | View owns |
| `@ObservedObject` | Receiving ObservableObject from parent | Parent owns |
| `@EnvironmentObject` | Sharing across view hierarchy | App/parent owns |
| `@Binding` | Child needs to mutate parent's state | Parent owns |
| `@Environment` | Reading system or custom environment values | System/parent owns |

---

## Extended Conventions Reference

For comprehensive coverage of additional topics, see **code-conventions-extended.md** which includes:

### Combine Framework Patterns (Detailed)
- Built-in publishers (Just, Future, PassthroughSubject, CurrentValueSubject)
- Comprehensive operators (map, flatMap, filter, debounce, throttle, combineLatest, zip, merge)
- Error handling (catch, retry, replaceError, mapError)
- Subscription patterns and cancellable management
- Common patterns: Form validation, network requests, search/debouncing

### Architecture & Design Patterns (Detailed)
- MVVM implementation with full examples
- Service layer patterns (protocol-based services, mocking)
- Repository pattern
- Dependency injection
- Clean architecture principles

### Design System (Comprehensive)
- Design tokens (colors, typography, spacing, border radius, shadows, animations)
- Component library (buttons, cards, inputs, toggles, alerts, badges)
- Layout system (grid, containers, responsive design)
- Iconography
- Dark mode support
- Accessibility integration
- Design system governance

### Error Handling (Production-Ready)
- Comprehensive error types with LocalizedError
- Error propagation patterns
- Result type usage
- Error handling in Combine
- User-facing error messages and recovery

### Concurrency & Threading (Modern Swift)
- Async/await patterns
- Task management and cancellation
- Task groups for parallel execution
- Actors for thread-safe state
- MainActor for UI updates
- Legacy DispatchQueue patterns

### Performance Optimization
- SwiftUI view optimization (Equatable, LazyVStack/LazyHStack)
- List performance and prefetching
- Memory management (weak/unowned references)
- Image optimization and caching

### Accessibility (WCAG Compliance)
- VoiceOver support (labels, hints, traits, element combination)
- Dynamic Type support
- Color contrast requirements
- Keyboard navigation
- Focus management

### Localization (i18n)
- String localization (LocalizedStringKey, NSLocalizedString)
- Pluralization with stringsdict
- Date and number formatting
- RTL language support

### Security Best Practices
- Keychain access for sensitive data
- Secure data handling
- Network security (HTTPS, certificate pinning)
- Input validation and sanitization

### Testing (Comprehensive)
- Unit testing patterns
- Combine testing with expectations
- SwiftUI testing approaches
- Mock objects and dependency injection
- Test data and preview content

### Documentation Standards
- Code comments (documentation comments, MARK sections)
- README templates
- API documentation

### Version Control Best Practices
- Commit message conventions
- Branching strategies
- Pull request templates

## Quick Reference Summary

### Magic Literals (Primary Focus)
✅ **DO:**
- Use named constants for all strings and numbers
- Organize in `private enum Const` for local use
- Create domain enums for project-wide constants
- Name constants descriptively

❌ **DON'T:**
- Hardcode dimensions: `.frame(width: 320)`
- Hardcode strings: `"Error: "`
- Hardcode numbers: `.opacity(0.5)`
- Use abbreviations in constant names

### SwiftUI State Management
- `@State` - View-local simple values
- `@StateObject` - Create and own ObservableObject
- `@ObservedObject` - Receive ObservableObject from parent
- `@EnvironmentObject` - Share across view hierarchy
- `@Binding` - Two-way binding to parent state

### View Organization
```swift
struct MyView: View {
    // MARK: - Properties (property wrappers first)
    // MARK: - Initialization
    // MARK: - Body
    // MARK: - Views (computed properties)
    // MARK: - Actions (functions)
}
// MARK: - Preview
```

### Combine Patterns
- Store cancellables in `Set<AnyCancellable>()`
- Use `[weak self]` to avoid retain cycles
- Suffix publishers: `userPublisher`
- Use `.eraseToAnyPublisher()` for clean interfaces

### Naming Quick Guide
- **Types**: PascalCase (`UserManager`, `NetworkError`)
- **Variables/Functions**: camelCase (`userName`, `fetchData`)
- **Booleans**: `is`/`has`/`can`/`should` prefix
- **Protocols**: `-able`, `-ible`, `-ing` suffix or noun
- **Collections**: Plural names

### Access Control
- Default to `private` or `fileprivate`
- Use `public` only when necessary
- Document public APIs thoroughly

### Code Quality Checks
1. No magic literals ✓
2. No force unwrapping without justification ✓
3. Proper MARK comments ✓
4. `let` preferred over `var` ✓
5. Clear, non-abbreviated names ✓
6. Proper access control ✓
7. No retain cycles in closures ✓

## Integration Workflow

1. **Read** CODE_CONVENTIONS.md
2. **Apply** magic literal elimination (priority)
3. **Reference** code-conventions-extended.md for specific topics
4. **Enforce** naming, structure, and architecture patterns
5. **Review** for accessibility, performance, and security
6. **Test** with unit tests and previews
7. **Document** public APIs and complex logic

---

**Remember:** These conventions are living documents. Update them as Swift, SwiftUI, and Combine evolve, and as project needs change.
