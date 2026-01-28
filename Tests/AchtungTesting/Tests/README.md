# AchtungTesting Test Suite

Comprehensive unit tests for the Achtung error handling and notification framework.

## Test Files

### 1. AchtungToastTests.swift
Tests for Toast functionality including:
- Toast creation with various parameters
- Display style options (custom, native, automatic)
- Toast queue management
- Duration settings and defaults
- Color customization
- File metadata tracking
- Tap actions and sharing
- Queue limits enforcement

**Test Count:** ~15 tests

### 2. AchtungAlertTests.swift
Tests for Alert functionality including:
- Alert creation with titles, messages, and buttons
- Tag-based deduplication
- Field input with text bindings
- Multiple button types (OK, Cancel, Destructive)
- Color customization
- Tap-outside-to-dismiss behavior
- Button actions
- Alert removal and display

**Test Count:** ~18 tests

### 3. AchtungErrorHandlingTests.swift
Tests for error handling including:
- Error level comparisons (debug, testing, standard)
- Error display at different levels
- HandleErrors method (sync and async)
- Deprecated `do` method backward compatibility
- Error filtering (ignore, log, display, replace)
- Error descriptions and formatting
- File description utility
- Recording limit configuration

**Test Count:** ~17 tests

### 4. AchtungErrorRecordingTests.swift
Tests for error recording including:
- Error recording with metadata
- Recording limit enforcement
- Clear record functionality
- Filter integration with recording
- Error ordering by time
- Multiple error recording
- Unique ID generation
- Localized description preservation

**Test Count:** ~14 tests

### 5. AchtungIntegrationTests.swift
End-to-end integration tests including:
- Complete error handling flows
- Simultaneous toast and alert display
- Multiple errors with different levels
- Error filter integration
- Toast queue processing
- Alert tag deduplication
- Color configuration
- Singleton pattern verification
- Presentable protocol conformance

**Test Count:** ~15 tests

### 6. AchtungDisplayStyleTests.swift
Tests for Display Style (formerly Nativity) including:
- Display style enum cases (custom, native, automatic)
- Deprecated ToastNativity alias
- Deprecated ifPossible mapping to automatic
- Display style behavior with different toast types
- Consistency across multiple toasts
- Sendable conformance
- Display style in various initializers

**Test Count:** ~13 tests

### 7. AchtungUtilityTests.swift
Tests for utilities and edge cases including:
- File description utility with various inputs
- Error description formatting
- Time interval constants verification
- Text extension initialization
- Edge cases (empty strings, long strings, special characters)
- Error filter result pattern matching
- Button kind distinctions
- Identifiable conformance for all types
- MainActor isolation
- Memory management

**Test Count:** ~25 tests

## Total Test Coverage

**Total Tests:** ~117 comprehensive unit tests

## Running the Tests

### Using Xcode
1. Open the AchtungTesting project
2. Select the test target
3. Press Cmd+U to run all tests

### Using Swift Package Manager
```bash
cd "/Users/ben/Documents/Managed Projects/Frameworks/Achtung"
swift test
```

### Using Command Line
```bash
xcodebuild test -scheme AchtungTesting -destination 'platform=macOS'
```

## Test Categories

### Functionality Tests
- Toast creation and display
- Alert creation and display
- Error handling and filtering
- Error recording and limits

### Integration Tests
- Complete workflows
- Multiple component interactions
- State management across operations

### Edge Case Tests
- Empty inputs
- Long strings
- Special characters
- Memory management
- Thread safety

### Backward Compatibility Tests
- Deprecated API aliases
- Legacy naming conventions
- Migration paths

## Key Testing Patterns

### Async/Await Testing
Many tests use `async`/`await` to handle asynchronous operations:
```swift
func testAsyncOperation() async {
    await Achtung.instance.show(toast: toast)
    try? await Task.sleep(nanoseconds: 200_000_000)
    // Verify results
}
```

### MainActor Testing
Tests that interact with UI state are marked `@MainActor`:
```swift
@MainActor
final class AchtungToastTests: XCTestCase {
    // Tests run on main actor
}
```

### Setup and Teardown
Each test file clears state in `setUp`:
```swift
override func setUp() async throws {
    Achtung.instance.clearRecord()
    Achtung.instance.pendingAlerts.removeAll()
    // More cleanup
}
```

## Coverage Areas

✅ Toast functionality (creation, display, queue management)
✅ Alert functionality (creation, display, deduplication)
✅ Error handling (levels, filtering, recording)
✅ Error recording (limits, metadata, clearing)
✅ Display styles (custom, native, automatic)
✅ Integration scenarios (multiple components)
✅ Edge cases and utilities
✅ Backward compatibility (deprecated APIs)
✅ Thread safety (@MainActor isolation)
✅ Memory management

## Notes

- Tests are designed to run independently
- Async operations use appropriate wait times
- State is cleared between tests to ensure isolation
- Tests verify both happy paths and edge cases
- Backward compatibility is maintained for deprecated APIs

## Adding New Tests

When adding new tests:

1. Choose the appropriate test file based on functionality
2. Follow existing naming conventions (`test<Feature><Behavior>`)
3. Include setup/teardown if needed
4. Add async/await for asynchronous operations
5. Use descriptive assertions with clear messages
6. Document complex test scenarios

## CI/CD Integration

These tests are designed to run in continuous integration environments:

- All tests are hermetic (no external dependencies)
- State is cleared between tests
- Timing is generous to avoid flakiness
- Tests work on both macOS and iOS (where applicable)
