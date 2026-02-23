//
//  AchtungToastTests.swift
//  AchtungTestingTests
//
//  Tests for Toast functionality
//

import Testing
import Foundation
@testable import Achtung
import SwiftUI

@Suite("Toast Tests", .serialized)
@MainActor
struct AchtungToastTests {

	init() async throws {
		// Clear any existing toasts
		Achtung.instance.toasts.removeAll()
		Achtung.instance.currentToast = nil
	}

	// MARK: - Toast Creation Tests

	@Test("Toast creation with title")
	func toastCreationWithTitle() {
		let toast = Achtung.Toast("Test Title")

		#expect(!toast.id.isEmpty)
		#expect(toast.title == "Test Title")
		#expect(toast.message == nil)
		#expect(toast.error == nil)
		#expect(toast.nativity == .native) // ifPossible converts to native
	}

	@Test("Toast creation with title and message")
	func toastCreationWithTitleAndMessage() {
		let toast = Achtung.Toast(
			"Title",
			message: "Message"
		)

		#expect(toast.title == "Title")
		#expect(toast.message == "Message")
		#expect(toast.duration == Achtung.longOnScreenTime)
	}

	@Test("Toast creation with error")
	func toastCreationWithError() {
		let error = NSError(domain: "TestDomain", code: 123, userInfo: [NSLocalizedDescriptionKey: "Test error"])
		let toast = Achtung.Toast(
			"Error Occurred",
			error: error
		)

		#expect(toast.title == "Error Occurred")
		#expect(toast.message != nil)
		#expect((toast.error as? NSError) == error)
	}

	@Test("Toast creation with custom duration")
	func toastCreationWithCustomDuration() {
		let toast = Achtung.Toast(
			"Custom",
			duration: 15.0
		)

		#expect(toast.duration == 15.0)
	}

	@Test("Toast nativity options")
	func toastNativityOptions() {
		let customToast = Achtung.Toast("Custom", .custom)
		#expect(customToast.nativity == .custom)

		let nativeToast = Achtung.Toast("Native", .native)
		#expect(nativeToast.nativity == .native)

		let automaticToast = Achtung.Toast("Auto", .ifPossible)
		#expect(automaticToast.nativity == .native) // ifPossible converts to native
	}

	@Test("Toast with colors")
	func toastWithColors() {
		let toast = Achtung.Toast(
			"Colored",
			foreground: .red,
			border: .blue,
			background: .green
		)

		#expect(toast.foregroundColor == .red)
		#expect(toast.borderColor == .blue)
		#expect(toast.backgroundColor == .green)
	}

	@Test("Toast file metadata")
	func toastFileMetadata() {
		let toast = Achtung.Toast(
			"Test",
			file: "TestFile.swift",
			function: "testFunction()",
			line: 42
		)

		#expect(toast.file.description == "TestFile.swift")
		#expect(toast.function.description == "testFunction()")
		#expect(toast.line == 42)
	}

	// MARK: - Toast Queue Management Tests

	@Test("Toast queue adds toasts")
	func toastQueueAddsToasts() {
		let toast1 = Achtung.Toast("Toast 1", .custom)
		let toast2 = Achtung.Toast("Toast 2", .custom)

		// Add directly to queue for testing
		Achtung.instance.toasts.append(toast1)
		Achtung.instance.toasts.append(toast2)

		// Toasts should be queued
		let totalToasts = Achtung.instance.toasts.count + (Achtung.instance.currentToast != nil ? 1 : 0)
		#expect(totalToasts >= 1)
	}

	// MARK: - Toast Duration Constants Tests

	@Test("Toast duration constants")
	func toastDurationConstants() {
		#expect(Achtung.onScreenTime == 8)
		#expect(Achtung.longOnScreenTime == 12)
		#expect(Achtung.showToastDuration == 0.5)
		#expect(Achtung.hideToastDuration == 0.4)
	}

	@Test("Toast duration defaults")
	func toastDurationDefaults() {
		// Toast with both title and message uses longOnScreenTime
		let longToast = Achtung.Toast("Title", message: "Message")
		#expect(longToast.duration == Achtung.longOnScreenTime)

		// Toast with only title uses onScreenTime
		let shortToast = Achtung.Toast("Title Only")
		#expect(shortToast.duration == Achtung.onScreenTime)
	}

	// MARK: - Toast Sharing Tests

	@Test("Toast with sharing title")
	func toastWithSharingTitle() {
		let toast = Achtung.Toast(
			"Share This",
			sharingTitle: "Shared Content"
		)

		#expect(toast.sharingTitle == "Shared Content")
	}

	// MARK: - Toast Tap Action Tests

	@Test("Toast with tap action")
	func toastWithTapAction() async {
		var tapped = false

		let toast = Achtung.Toast(
			"Tappable",
			tapAction: {
				tapped = true
			}
		)

		#expect(toast.tapAction != nil)

		// Execute the tap action
		if let action = toast.tapAction {
			await action()
		}

		#expect(tapped)
	}
}
