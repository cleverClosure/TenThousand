---
description: Extended Swift/SwiftUI/Combine conventions - Part 2
---

# Extended Code Conventions - Part 2

This file contains extended conventions for Combine, Architecture, Design Systems, and more.

## Combine Framework Patterns

### Publisher Creation

#### Built-in Publishers

```swift
// Just - Single value
let numberPublisher = Just(42)

// Future - Async value
let futurePublisher = Future<String, Error> { promise in
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        promise(.success("Done"))
    }
}

// PassthroughSubject - Imperative sends
let subject = PassthroughSubject<String, Never>()
subject.send("Hello")

// CurrentValueSubject - Maintains current value
let currentSubject = CurrentValueSubject<Int, Never>(0)
print(currentSubject.value)  // 0
currentSubject.send(1)
print(currentSubject.value)  // 1

// Published property
class ViewModel: ObservableObject {
    @Published var items: [Item] = []
}

// From URLSession
let dataPublisher = URLSession.shared
    .dataTaskPublisher(for: url)
    .map(\.data)
    .eraseToAnyPublisher()

// From Timer
let timerPublisher = Timer.publish(every: 1, on: .main, in: .common)
    .autoconnect()

// From NotificationCenter
let keyboardPublisher = NotificationCenter.default
    .publisher(for: NSApplication.willTerminateNotification)
```

### Operators

#### Transforming Operators

```swift
// map - Transform values
let doubled = numbers.publisher
    .map { $0 * 2 }

// flatMap - Transform to new publisher
let userDataPublisher = userIDs.publisher
    .flatMap { id in
        fetchUser(id: id)
    }

// compactMap - Filter and transform
let validEmails = inputs.publisher
    .compactMap { $0.asEmail() }  // Returns Optional<Email>

// tryMap - Throwing transformation
let parsed = jsonData.publisher
    .tryMap { data in
        try JSONDecoder().decode(User.self, from: data)
    }

// scan - Accumulate values
let runningTotal = numbers.publisher
    .scan(0, +)  // Running sum

// collect - Gather into array
let allValues = stream.publisher
    .collect()  // Waits for completion, emits [Value]

// collect(count) - Buffer specific number
let batches = items.publisher
    .collect(5)  // Emits arrays of 5 items
```

#### Filtering Operators

```swift
// filter
let evens = numbers.publisher
    .filter { $0 % 2 == 0 }

// removeDuplicates
let unique = values.publisher
    .removeDuplicates()

// first
let firstValue = stream.publisher
    .first()

// last
let lastValue = stream.publisher
    .last()

// drop(while:)
let afterCondition = values.publisher
    .drop(while: { $0 < 10 })

// prefix(while:)
let beforeCondition = values.publisher
    .prefix(while: { $0 < 100 })

// debounce - Throttle rapid changes
let searchPublisher = searchField.publisher
    .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)

// throttle - Limit update rate
let locationPublisher = locationUpdates.publisher
    .throttle(for: .seconds(1), scheduler: DispatchQueue.main, latest: true)
```

#### Combining Operators

```swift
// combineLatest - When any publishes
let combined = Publishers.CombineLatest(publisher1, publisher2)
    .map { value1, value2 in
        // Use both values
    }

// zip - Pairs values
let zipped = Publishers.Zip(publisher1, publisher2)
    .map { pair in
        // Synchronized pairs
    }

// merge - Interleave values
let merged = Publishers.Merge(publisher1, publisher2)

// append - Chain sequences
let full = firstPublisher
    .append(secondPublisher)
```

#### Error Handling Operators

```swift
// catch - Recover from errors
let recovered = riskyPublisher
    .catch { error -> Just<DefaultValue> in
        print("Error: \(error)")
        return Just(defaultValue)
    }

// retry - Retry on failure
let retried = networkPublisher
    .retry(3)

// replaceError - Replace with value
let safe = publisher
    .replaceError(with: defaultValue)

// mapError - Transform error type
let transformed = publisher
    .mapError { error -> MyError in
        MyError.network(error)
    }

// assertNoFailure - Crash on error (use for debugging)
let guaranteed = publisher
    .assertNoFailure()
```

### Subscription Patterns

#### Basic Subscription

```swift
// sink - Terminal subscriber
let cancellable = publisher
    .sink(
        receiveCompletion: { completion in
            switch completion {
            case .finished:
                print("Completed successfully")
            case .failure(let error):
                print("Failed: \(error)")
            }
        },
        receiveValue: { value in
            print("Received: \(value)")
        }
    )

// For Never failure type
let cancellable = publisher
    .sink { value in
        print("Received: \(value)")
    }
```

#### Storing Cancellables

```swift
// ✅ Good - Store in Set
class ViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()

    func setupSubscriptions() {
        publisher1
            .sink { self.handle($0) }
            .store(in: &cancellables)

        publisher2
            .sink { self.process($0) }
            .store(in: &cancellables)
    }

    func cleanup() {
        cancellables.removeAll()  // Cancel all
    }
}

// ✅ Good - Store individual cancellables
class ViewModel: ObservableObject {
    private var timerCancellable: AnyCancellable?
    private var networkCancellable: AnyCancellable?

    func startTimer() {
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in self.tick() }
    }

    func stopTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }
}
```

### Common Patterns

#### Form Validation

```swift
class FormViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""

    @Published var isEmailValid = false
    @Published var isPasswordValid = false
    @Published var doPasswordsMatch = false
    @Published var canSubmit = false

    private var cancellables = Set<AnyCancellable>()

    init() {
        setupValidation()
    }

    private func setupValidation() {
        // Email validation
        $email
            .map { email in
                email.contains("@") && email.contains(".")
            }
            .assign(to: &$isEmailValid)

        // Password validation
        $password
            .map { $0.count >= 8 }
            .assign(to: &$isPasswordValid)

        // Passwords match
        Publishers.CombineLatest($password, $confirmPassword)
            .map { password, confirm in
                !password.isEmpty && password == confirm
            }
            .assign(to: &$doPasswordsMatch)

        // Can submit form
        Publishers.CombineLatest3($isEmailValid, $isPasswordValid, $doPasswordsMatch)
            .map { $0 && $1 && $2 }
            .assign(to: &$canSubmit)
    }
}
```

#### Network Requests

```swift
class NetworkService {
    func fetchUser(id: UUID) -> AnyPublisher<User, Error> {
        let url = URL(string: "https://api.example.com/users/\(id)")!

        return URLSession.shared
            .dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: User.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func fetchUsers() -> AnyPublisher<[User], Error> {
        let url = URL(string: "https://api.example.com/users")!

        return URLSession.shared
            .dataTaskPublisher(for: url)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      200...299 ~= httpResponse.statusCode else {
                    throw NetworkError.invalidResponse
                }
                return data
            }
            .decode(type: [User].self, decoder: JSONDecoder())
            .retry(2)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
```

---

## Architecture & Design Patterns

### MVVM (Model-View-ViewModel)

#### ViewModel Layer
```swift
@MainActor
final class UserProfileViewModel: ObservableObject {
    // Published state
    @Published private(set) var user: User?
    @Published private(set) var stats: UserStats?
    @Published private(set) var posts: [Post] = []
    @Published private(set) var loadingState: LoadingState = .idle

    // Dependencies
    private let userId: UUID
    private let userService: UserService
    private let postService: PostService

    private var cancellables = Set<AnyCancellable>()

    // Initialization
    init(
        userId: UUID,
        userService: UserService = .shared,
        postService: PostService = .shared
    ) {
        self.userId = userId
        self.userService = userService
        self.postService = postService
    }

    // Public methods
    func loadProfile() {
        loadingState = .loading

        Publishers.Zip(
            userService.fetchUser(id: userId),
            postService.fetchPosts(for: userId)
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.loadingState = .error(error)
                }
            },
            receiveValue: { [weak self] user, posts in
                self?.user = user
                self?.posts = posts
                self?.calculateStats()
                self?.loadingState = .loaded
            }
        )
        .store(in: &cancellables)
    }

    func likePost(_ post: Post) {
        postService.likePost(id: post.id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] updatedPost in
                    self?.updatePost(updatedPost)
                }
            )
            .store(in: &cancellables)
    }

    // Private methods
    private func calculateStats() {
        guard let user = user else { return }

        stats = UserStats(
            postsCount: posts.count,
            totalLikes: posts.reduce(0) { $0 + $1.likes },
            joinDate: user.joinDate
        )
    }

    private func updatePost(_ post: Post) {
        if let index = posts.firstIndex(where: { $0.id == post.id }) {
            posts[index] = post
        }
    }
}
```

### Service Layer

```swift
// Protocol-based service
protocol UserServiceProtocol {
    func fetchUser(id: UUID) -> AnyPublisher<User, Error>
    func updateUser(_ user: User) -> AnyPublisher<User, Error>
    func deleteUser(id: UUID) -> AnyPublisher<Void, Error>
}

// Implementation
final class UserService: UserServiceProtocol {
    static let shared = UserService()

    private let networkService: NetworkService
    private let cacheService: CacheService

    init(
        networkService: NetworkService = .shared,
        cacheService: CacheService = .shared
    ) {
        self.networkService = networkService
        self.cacheService = cacheService
    }

    func fetchUser(id: UUID) -> AnyPublisher<User, Error> {
        // Check cache first
        if let cachedUser = cacheService.getUser(id: id) {
            return Just(cachedUser)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        // Fetch from network
        return networkService
            .request(endpoint: .user(id))
            .decode(type: User.self, decoder: JSONDecoder())
            .handleEvents(receiveOutput: { [weak self] user in
                self?.cacheService.saveUser(user)
            })
            .eraseToAnyPublisher()
    }
}
```

---

## Design System

### Design Tokens

#### Color Tokens

```swift
// MARK: - Color System

extension Color {
    // MARK: - Brand Colors
    static let brandPrimary = Color("BrandPrimary")
    static let brandSecondary = Color("BrandSecondary")
    static let brandTertiary = Color("BrandTertiary")

    // MARK: - Semantic Colors (Light/Dark mode adaptive)
    static let textPrimary = Color("TextPrimary")
    static let textSecondary = Color("TextSecondary")
    static let textTertiary = Color("TextTertiary")
    static let textDisabled = Color("TextDisabled")

    static let backgroundPrimary = Color("BackgroundPrimary")
    static let backgroundSecondary = Color("BackgroundSecondary")
    static let backgroundTertiary = Color("BackgroundTertiary")

    // MARK: - State Colors
    static let success = Color("Success")
    static let warning = Color("Warning")
    static let error = Color("Error")
    static let info = Color("Info")
}
```

#### Typography Tokens

```swift
// MARK: - Typography System

extension Font {
    // MARK: - Display Styles
    static let displayLarge = Font.system(size: 57, weight: .bold)
    static let displayMedium = Font.system(size: 45, weight: .bold)
    static let displaySmall = Font.system(size: 36, weight: .bold)

    // MARK: - Headline Styles
    static let headlineXLarge = Font.system(size: 32, weight: .semibold)
    static let headlineLarge = Font.system(size: 28, weight: .semibold)
    static let headlineMedium = Font.system(size: 24, weight: .semibold)
    static let headlineSmall = Font.system(size: 20, weight: .semibold)

    // MARK: - Body Styles
    static let bodyLarge = Font.system(size: 17, weight: .regular)
    static let bodyMedium = Font.system(size: 15, weight: .regular)
    static let bodySmall = Font.system(size: 13, weight: .regular)
}
```

#### Spacing Tokens

```swift
// MARK: - Spacing System (8pt grid)

enum Spacing {
    // Base unit: 8pt
    static let xxxs: CGFloat = 2      // 0.25x
    static let xxs: CGFloat = 4       // 0.5x
    static let xs: CGFloat = 8        // 1x
    static let sm: CGFloat = 12       // 1.5x
    static let md: CGFloat = 16       // 2x
    static let lg: CGFloat = 24       // 3x
    static let xl: CGFloat = 32       // 4x
    static let xxl: CGFloat = 48      // 6x
    static let xxxl: CGFloat = 64     // 8x

    // Semantic spacing
    static let elementPadding = md
    static let componentGap = lg
    static let sectionGap = xl
    static let screenPadding = lg
}
```

---

## Error Handling

### Error Types

```swift
// ✅ Good - Comprehensive error enum
enum NetworkError: LocalizedError {
    case invalidURL
    case noConnection
    case timeout
    case serverError(statusCode: Int)
    case decodingError(Error)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is invalid"
        case .noConnection:
            return "No internet connection"
        case .timeout:
            return "Request timed out"
        case .serverError(let code):
            return "Server error with status code \(code)"
        case .decodingError:
            return "Failed to decode response"
        case .unknown(let error):
            return "An unknown error occurred: \(error.localizedDescription)"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .noConnection:
            return "Check your internet connection and try again"
        case .timeout:
            return "Check your connection and try again"
        case .serverError:
            return "Please try again later"
        default:
            return nil
        }
    }
}
```

---

## Concurrency & Threading

### Async/Await

```swift
// ✅ Good - Modern async/await
@MainActor
final class UserViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var error: Error?

    private let userService: UserService

    init(userService: UserService) {
        self.userService = userService
    }

    func loadUser(id: UUID) async {
        isLoading = true
        error = nil

        do {
            user = try await userService.fetchUser(id: id)
        } catch {
            self.error = error
        }

        isLoading = false
    }
}
```

### Actors

```swift
// ✅ Good - Actor for thread-safe state
actor UserCache {
    private var users: [UUID: User] = [:]
    private var lastUpdate: Date?

    func getUser(id: UUID) -> User? {
        users[id]
    }

    func setUser(_ user: User) {
        users[user.id] = user
        lastUpdate = Date()
    }

    func clearCache() {
        users.removeAll()
        lastUpdate = nil
    }
}
```

---

## Performance Optimization

### SwiftUI Performance

```swift
// ✅ Good - Minimize view updates with Equatable
struct ItemRow: View, Equatable {
    let item: Item

    var body: some View {
        HStack {
            Text(item.name)
            Spacer()
            Text("$\(item.price)")
        }
    }

    static func == (lhs: ItemRow, rhs: ItemRow) -> Bool {
        lhs.item.id == rhs.item.id &&
        lhs.item.name == rhs.item.name &&
        lhs.item.price == rhs.item.price
    }
}

// Usage with equatable
ForEach(items) { item in
    ItemRow(item: item)
        .equatable()
}

// ✅ Good - Use LazyVStack/LazyHStack for large lists
ScrollView {
    LazyVStack(spacing: 12) {
        ForEach(items) { item in
            ItemRow(item: item)
        }
    }
}
```

---

## Accessibility

### VoiceOver Support

```swift
// ✅ Good - Descriptive labels
Button(action: deleteItem) {
    Image(systemName: "trash")
}
.accessibilityLabel("Delete item")

// ✅ Good - Combine elements
HStack {
    Image(systemName: "star.fill")
    Text("4.5")
    Text("(123 reviews)")
}
.accessibilityElement(children: .combine)
.accessibilityLabel("Rating: 4.5 stars from 123 reviews")

// ✅ Good - Hints
Button("Save") { saveData() }
    .accessibilityHint("Saves your current work")
```

---

## Testing

### Unit Testing

```swift
import XCTest
@testable import YourApp

final class UserViewModelTests: XCTestCase {
    var sut: UserViewModel!
    var mockService: MockUserService!

    override func setUp() {
        super.setUp()
        mockService = MockUserService()
        sut = UserViewModel(userService: mockService)
    }

    override func tearDown() {
        sut = nil
        mockService = nil
        super.tearDown()
    }

    func testFetchUserSuccess() async throws {
        // Arrange
        let expectedUser = User.preview
        mockService.mockUser = expectedUser

        // Act
        await sut.loadUser(id: expectedUser.id)

        // Assert
        XCTAssertEqual(sut.user, expectedUser)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.error)
    }
}
```

---

## Documentation

### Code Comments

```swift
/// Fetches a user from the remote server.
///
/// This method performs a network request to retrieve user data.
/// The result is cached locally for offline access.
///
/// - Parameter id: The unique identifier of the user to fetch
/// - Returns: A publisher that emits the user or an error
/// - Throws: `NetworkError` if the request fails
///
/// # Example
/// ```swift
/// userService.fetchUser(id: userId)
///     .sink { user in
///         print("Fetched: \(user.name)")
///     }
///     .store(in: &cancellables)
/// ```
func fetchUser(id: UUID) -> AnyPublisher<User, Error> {
    // Implementation
}
```

---

## Summary

These extended conventions cover:

- **Combine Framework**: Publishers, operators, subscriptions, and common patterns
- **Architecture**: MVVM, service layer, dependency injection
- **Design System**: Tokens, component library, accessibility
- **Error Handling**: Comprehensive error types and user-facing messages
- **Concurrency**: Async/await, actors, main actor usage
- **Performance**: SwiftUI optimizations, memory management
- **Accessibility**: VoiceOver, dynamic type, keyboard navigation
- **Testing**: Unit tests, mocks, test data
- **Documentation**: Code comments, examples

## Integration with Main Conventions

This file extends the main code-conventions.md skill with deeper coverage of:
1. Combine reactive programming patterns
2. Advanced SwiftUI architecture
3. Design system implementation
4. Production-ready error handling
5. Modern Swift concurrency
6. Performance best practices
7. Accessibility compliance
8. Comprehensive testing strategies

Always apply these conventions alongside the magic literal elimination rules from the main conventions file.
