# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Achtung is a SwiftUI error handling and notification framework for iOS, macOS, and watchOS. It provides a centralized way to display errors, alerts, and toast notifications with a singleton-based architecture.

## Build Commands

```bash
# Build the package
swift build

# Run tests (if test targets exist)
swift test

# Build for specific platform
swift build -c release
```

## Architecture

### Core Components

1. **Singleton Pattern**: `Achtung.instance` is the main singleton that manages all error display and notifications. Always access via the singleton, never create new instances.

2. **Two Display Mechanisms**:
   - **Toasts**: Temporary, non-blocking notifications (8-12 seconds on screen)
   - **Alerts**: Modal dialogs requiring user interaction

3. **Platform-Specific Setup**:
   - **iOS**: Requires setup with a `UIWindowScene` via `Achtung.instance.setup(in: scene, level: .standard)`. Creates an overlay window at `.statusBar` level that sits above all other UI.
   - **macOS**: Only requires `Achtung.instance.setup(level: .standard)`
   - Setup must be called during app initialization before showing any errors

### Key Architectural Patterns

#### Error Recording System
- All errors can be recorded via `recordError()` independent of display
- Maintains a circular buffer (default 10 errors) in `recordedErrors`
- Each recorded error includes file/function/line metadata for debugging
- Errors include decoding context for `DecodingError` via the `decodingDescription` extension

#### Error Filtering
- `filterError` closure allows custom error handling logic
- Returns `ErrorFilterResult`: `.ignore`, `.log`, `.display`, or `.replace(Error)`
- Filter is called before display or recording

#### Error Display Levels
- Three levels: `.debug`, `.testing`, `.standard`
- `errorDisplayLevel` determines minimum level to show
- Lower levels are always printed but may not show UI

#### Toast Nativity Options
- `.custom`: Always use custom SwiftUI UI
- `.native`: Always use system notifications (iOS 16+/macOS 13+)
- `.ifPossible`: Prefers native notifications (default behavior)

### File Organization

Files use `Achtung.<ComponentName>.swift` or `Achtung+<Feature>.swift` naming:
- `Achtung.swift`: Core singleton and state management
- `Achtung+Setup.swift`: iOS-specific window setup and platform checks
- `Achtung+Show.swift`: Display methods for toasts and alerts
- `Achtung+Recording.swift`: Error recording and filtering
- `Achtung.Toast.swift`: Toast data structure and configuration
- `Achtung.Alert.swift`: Alert data structure
- `Achtung.Errors.swift`: Error display methods and error levels
- `Error.swift`: Extensions for decoding error descriptions
- `UserNotifications.swift`: Native notification support (iOS 16+)
- View files (`*.AlertView.swift`, `*.ToastView.swift`, etc.): SwiftUI views

### Important Implementation Details

1. **MainActor Isolation**: Most public APIs are `nonisolated` but internally dispatch to `@MainActor` via Task wrappers for thread-safe UI updates.

2. **Toast Queue Management**: Toasts are queued and displayed sequentially. `currentToast` shows one at a time, using timers to auto-dismiss and show the next.

3. **Alert Tagging**: Alerts support optional `tag` parameter to prevent duplicate alerts with the same tag from stacking.

4. **File/Function/Line Tracking**: Toast initializers capture `#file`, `#function`, and `#line` for debugging. Always preserved in the structure.

5. **Customization**: Both toasts and alerts support custom colors (foreground, background, border) and can fall back to instance-level defaults.

6. **Error Description Enhancement**: The `achtungDescription` computed property on `Error` provides better formatting for decoding errors and handles the "error 0." case.

## Common Patterns

### Showing Errors
```swift
// Simple error display
Achtung.show(error, level: .standard, title: "Failed to load")

// With error handling wrapper
Achtung.do(level: .testing) {
    try somethingThatMightFail()
}

// Custom toast with accessory view
Achtung.show(error, level: .standard) {
    Image(systemName: "exclamationmark.triangle")
}
```

### Showing Alerts
```swift
// Simple alert
Achtung.show(title: "Confirm", message: "Are you sure?", buttons: [
    .ok(),
    .cancel()
])

// Alert with tag to prevent duplicates
Achtung.show(title: "Error", message: "Network failed", tag: "network-error", buttons: [.ok()])
```

### Custom Toasts
```swift
// Toast with custom duration and colors
let toast = Achtung.Toast(
    "Upload Complete",
    message: "Your file was uploaded successfully",
    duration: 10,
    foreground: .white,
    background: .green
)
Achtung.show(toast: toast)
```

## Code Conventions

- Use `#if os(iOS)` or `#if os(macOS)` for platform-specific code
- All SwiftUI code requires `#if canImport(Combine)` guard at file level
- Availability annotations: `@available(OSX 10.15, iOS 13.0, *)`
- Public APIs are `nonisolated` with internal `@MainActor` dispatch
- Error extensions are `internal` by default (e.g., `decodingDescription`)
