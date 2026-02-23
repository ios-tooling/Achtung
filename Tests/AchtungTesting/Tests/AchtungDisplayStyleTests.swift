//
//  AchtungDisplayStyleTests.swift
//  AchtungTestingTests
//
//  Tests for Toast Nativity
//

import Testing
import Foundation
import SwiftUI
@testable import Achtung

@Suite("Toast Nativity Tests", .serialized)
struct AchtungDisplayStyleTests {

	// MARK: - Nativity Enum Tests

	@Test("Nativity cases")
	func nativityCases() {
		let custom: ToastNativity = .custom
		let native: ToastNativity = .native
		let ifPossible: ToastNativity = .ifPossible

		#expect(custom.rawValue == "custom")
		#expect(native.rawValue == "native")
		#expect(ifPossible.rawValue == "ifPossible")
	}

	@Test("Nativity from raw value")
	func nativityFromRawValue() {
		#expect(ToastNativity(rawValue: "custom") == .custom)
		#expect(ToastNativity(rawValue: "native") == .native)
		#expect(ToastNativity(rawValue: "ifPossible") == .ifPossible)
	}

	// MARK: - Toast Nativity Behavior Tests

	@Test("Toast with custom nativity")
	func toastWithCustomNativity() {
		let toast = Achtung.Toast("Custom", .custom)
		#expect(toast.nativity == .custom)
	}

	@Test("Toast with native nativity")
	func toastWithNativeNativity() {
		let toast = Achtung.Toast("Native", .native)
		#expect(toast.nativity == .native)
	}

	@Test("Toast with if possible nativity")
	func toastWithIfPossibleNativity() {
		let toast = Achtung.Toast("If Possible", .ifPossible)

		// .ifPossible converts to .native internally
		#expect(toast.nativity == .native)
	}

	@Test("Toast default nativity")
	func toastDefaultNativity() {
		// When not specified, should default to .ifPossible (which becomes .native)
		let toast = Achtung.Toast("Default")

		#expect(toast.nativity == .native)
	}

	// MARK: - Nativity with Different Toast Types

	@Test("Nativity with error")
	func nativityWithError() {
		let error = NSError(domain: "Test", code: 1)

		let customToast = Achtung.Toast(
			"Error",
			.custom,
			error: error
		)
		#expect(customToast.nativity == .custom)
		#expect(customToast.error != nil)

		let nativeToast = Achtung.Toast(
			"Error",
			.native,
			error: error
		)
		#expect(nativeToast.nativity == .native)
	}

	@Test("Nativity with message")
	func nativityWithMessage() {
		let toast = Achtung.Toast(
			"Title",
			.custom,
			message: "Message"
		)

		#expect(toast.nativity == .custom)
		#expect(toast.message == "Message")
	}

	@Test("Nativity with custom duration")
	func nativityWithCustomDuration() {
		let toast = Achtung.Toast(
			"Timed",
			.custom,
			duration: 20.0
		)

		#expect(toast.nativity == .custom)
		#expect(toast.duration == 20.0)
	}

	// MARK: - Nativity Consistency Tests

	@Test("Multiple toasts with different nativity")
	func multipleToastsWithDifferentNativity() {
		let toasts = [
			Achtung.Toast("Custom 1", .custom),
			Achtung.Toast("Native 1", .native),
			Achtung.Toast("IfPossible 1", .ifPossible),
			Achtung.Toast("Custom 2", .custom),
		]

		#expect(toasts[0].nativity == .custom)
		#expect(toasts[1].nativity == .native)
		#expect(toasts[2].nativity == .native) // ifPossible -> native
		#expect(toasts[3].nativity == .custom)
	}

	// MARK: - Nativity Sendable Conformance

	@Test("Nativity is sendable")
	func nativityIsSendable() {
		// ToastNativity should be Sendable (as it's a String-based enum)
		let nativity: ToastNativity = .custom

		Task {
			let _ = nativity // Should compile without warnings
		}

		#expect(true)
	}

	// MARK: - Nativity in Different Contexts

	@Test("Nativity in toast initializers")
	func nativityInToastInitializers() {
		// Test all different initializer overloads maintain nativity

		let toast1 = Achtung.Toast(
			id: "test1",
			"Test 1",
			.custom
		)
		#expect(toast1.nativity == .custom)

		let toast2 = Achtung.Toast(
			"Test 2",
			.native,
			message: "Message"
		)
		#expect(toast2.nativity == .native)

		let toast3 = Achtung.Toast(
			"Test 3",
			.custom,
			error: NSError(domain: "Test", code: 1)
		)
		#expect(toast3.nativity == .custom)
	}
}
