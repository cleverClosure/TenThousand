//
//  TenThousandTests.swift
//  TenThousandTests
//
//  Comprehensive unit test suite for TenThousand app
//  Testing behaviors, not implementations
//
//  Test Coverage:
//  - TimerManagerTests: Timer state transitions and time calculations
//  - AppViewModelTests: Skill/session management and statistics
//  - DataModelTests: Skill and Session computed properties
//  - PersistenceTests: CoreData stack and save operations
//

import Testing
@testable import TenThousand

// Main test suite - individual tests are organized in separate files
// Run tests with: xcodebuild test -scheme TenThousand -destination 'platform=macOS'
