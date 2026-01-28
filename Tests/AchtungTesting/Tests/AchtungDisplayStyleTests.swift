//
//  AchtungDisplayStyleTests.swift
//  AchtungTestingTests
//
//  Tests for Toast Display Style (formerly Nativity)
//

import Testing
import Foundation
@testable import Achtung

@Suite("Display Style Tests")
struct AchtungDisplayStyleTests {

	// MARK: - Display Style Enum Tests

	@Test("Display style cases")
	func displayStyleCases() {
		let custom: ToastDisplayStyle = .custom
		let native: ToastDisplayStyle = .native
		let automatic: ToastDisplayStyle = .automatic

		#expect(custom.rawValue == "custom")
		#expect(native.rawValue == "native")
		#expect(automatic.rawValue == "automatic")
	}

	@Test("Display style from raw value")
	func displayStyleFromRawValue() {
		#expect(ToastDisplayStyle(rawValue: "custom") == .custom)
		#expect(ToastDisplayStyle(rawValue: "native") == .native)
		#expect(ToastDisplayStyle(rawValue: "automatic") == .automatic)
	}

	// MARK: - Deprecated ToastNativity Tests

	@Test("Deprecated toast nativity alias")
	func deprecatedToastNativityAlias() {
		// Test that the deprecated alias still works
		let _: ToastNativity = .custom
		let _: ToastNativity = .native
		let _: ToastNativity = .automatic

		// All should compile without errors
		#expect(true)
	}

	@Test("Deprecated ifPossible maps to automatic")
	func deprecatedIfPossibleMapsToAutomatic() {
		// Test that .ifPossible maps to .automatic
		#expect(ToastDisplayStyle.ifPossible == .automatic)
	}

	// MARK: - Toast Display Style Behavior Tests

	@Test("Toast with custom display style")
	func toastWithCustomDisplayStyle() {
		let toast = Achtung.Toast(title: "Custom", displayStyle: .custom)
		#expect(toast.displayStyle == .custom)
	}

	@Test("Toast with native display style")
	func toastWithNativeDisplayStyle() {
		let toast = Achtung.Toast(title: "Native", displayStyle: .native)
		#expect(toast.displayStyle == .native)
	}

	@Test("Toast with automatic display style")
	func toastWithAutomaticDisplayStyle() {
		let toast = Achtung.Toast(title: "Automatic", displayStyle: .automatic)

		// .automatic converts to .native internally
		#expect(toast.displayStyle == .native)
	}

	@Test("Toast default display style")
	func toastDefaultDisplayStyle() {
		// When not specified, should default to .automatic (which becomes .native)
		let toast = Achtung.Toast(title: "Default")

		#expect(toast.displayStyle == .native)
	}

	// MARK: - Display Style with Different Toast Types

	@Test("Display style with error")
	func displayStyleWithError() {
		let error = NSError(domain: "Test", code: 1)

		let customToast = Achtung.Toast(
			title: "Error",
			displayStyle: .custom,
			error: error
		)
		#expect(customToast.displayStyle == .custom)
		#expect(customToast.error != nil)

		let nativeToast = Achtung.Toast(
			title: "Error",
			displayStyle: .native,
			error: error
		)
		#expect(nativeToast.displayStyle == .native)
	}

	@Test("Display style with message")
	func displayStyleWithMessage() {
		let toast = Achtung.Toast(
			title: "Title",
			displayStyle: .custom,
			message: "Message"
		)

		#expect(toast.displayStyle == .custom)
		#expect(toast.message == "Message")
	}

	@Test("Display style with custom duration")
	func displayStyleWithCustomDuration() {
		let toast = Achtung.Toast(
			title: "Timed",
			displayStyle: .custom,
			duration: 20.0
		)

		#expect(toast.displayStyle == .custom)
		#expect(toast.duration == 20.0)
	}

	// MARK: - Display Style Consistency Tests

	@Test("Multiple toasts with different styles")
	func multipleToastsWithDifferentStyles() {
		let toasts = [
			Achtung.Toast(title: "Custom 1", displayStyle: .custom),
			Achtung.Toast(title: "Native 1", displayStyle: .native),
			Achtung.Toast(title: "Auto 1", displayStyle: .automatic),
			Achtung.Toast(title: "Custom 2", displayStyle: .custom),
		]

		#expect(toasts[0].displayStyle == .custom)
		#expect(toasts[1].displayStyle == .native)
		#expect(toasts[2].displayStyle == .native) // automatic -> native
		#expect(toasts[3].displayStyle == .custom)
	}

	// MARK: - Display Style Sendable Conformance

	@Test("Display style is sendable")
	func displayStyleIsSendable() {
		// ToastDisplayStyle should be Sendable (as it's a String-based enum)
		let style: ToastDisplayStyle = .custom

		Task {
			let _ = style // Should compile without warnings
		}

		#expect(true)
	}

	// MARK: - Display Style in Different Contexts

	@Test("Display style in toast initializers")
	func displayStyleInToastInitializers() {
		// Test all different initializer overloads maintain display style

		let toast1 = Achtung.Toast(
			id: "test1",
			title: "Test 1",
			displayStyle: .custom
		)
		#expect(toast1.displayStyle == .custom)

		let toast2 = Achtung.Toast(
			title: "Test 2",
			displayStyle: .native,
			message: "Message"
		)
		#expect(toast2.displayStyle == .native)

		let toast3 = Achtung.Toast(
			title: "Test 3",
			displayStyle: .custom,
			error: NSError(domain: "Test", code: 1)
		)
		#expect(toast3.displayStyle == .custom)
	}
}
