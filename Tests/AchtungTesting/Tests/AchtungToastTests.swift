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

@Suite("Toast Tests")
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
		let toast = Achtung.Toast(title: "Test Title")

		#expect(!toast.id.isEmpty)
		#expect(toast.title == "Test Title")
		#expect(toast.message == nil)
		#expect(toast.error == nil)
		#expect(toast.displayStyle == .native) // automatic converts to native
	}

	@Test("Toast creation with title and message")
	func toastCreationWithTitleAndMessage() {
		let toast = Achtung.Toast(
			title: "Title",
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
			title: "Error Occurred",
			error: error
		)

		#expect(toast.title == "Error Occurred")
		#expect(toast.message != nil)
		#expect((toast.error as? NSError) == error)
	}

	@Test("Toast creation with custom duration")
	func toastCreationWithCustomDuration() {
		let toast = Achtung.Toast(
			title: "Custom",
			duration: 15.0
		)

		#expect(toast.duration == 15.0)
	}

	@Test("Toast display style options")
	func toastDisplayStyleOptions() {
		let customToast = Achtung.Toast(title: "Custom", displayStyle: .custom)
		#expect(customToast.displayStyle == .custom)

		let nativeToast = Achtung.Toast(title: "Native", displayStyle: .native)
		#expect(nativeToast.displayStyle == .native)

		let automaticToast = Achtung.Toast(title: "Auto", displayStyle: .automatic)
		#expect(automaticToast.displayStyle == .native) // automatic converts to native
	}

	@Test("Toast with colors")
	func toastWithColors() {
		let toast = Achtung.Toast(
			title: "Colored",
			foregroundColor: .red,
			borderColor: .blue,
			backgroundColor: .green
		)

		#expect(toast.foregroundColor == .red)
		#expect(toast.borderColor == .blue)
		#expect(toast.backgroundColor == .green)
	}

	@Test("Toast file metadata")
	func toastFileMetadata() {
		let toast = Achtung.Toast(
			title: "Test",
			file: "TestFile.swift",
			function: "testFunction()",
			line: 42
		)

		#expect(toast.file.description == "TestFile.swift")
		#expect(toast.function.description == "testFunction()")
		#expect(toast.line == 42)
	}

	// MARK: - Toast Queue Management Tests

	@Test("Max pending toasts default")
	func maxPendingToastsDefault() {
		#expect(Achtung.instance.maxPendingToasts == 10)
	}

	@Test("Max pending toasts configurable")
	func maxPendingToastsConfigurable() {
		let originalLimit = Achtung.instance.maxPendingToasts

		Achtung.instance.maxPendingToasts = 5
		#expect(Achtung.instance.maxPendingToasts == 5)

		// Restore original
		Achtung.instance.maxPendingToasts = originalLimit
	}

	@Test("Toast queue adds toasts")
	func toastQueueAddsToasts() async {
		let toast1 = Achtung.Toast(title: "Toast 1", displayStyle: .custom)
		let toast2 = Achtung.Toast(title: "Toast 2", displayStyle: .custom)

		await Achtung.instance.show(toast: toast1)
		await Achtung.instance.show(toast: toast2)

		// Toasts should be queued (first one may be shown, others queued)
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
		let longToast = Achtung.Toast(title: "Title", message: "Message")
		#expect(longToast.duration == Achtung.longOnScreenTime)

		// Toast with only title uses onScreenTime
		let shortToast = Achtung.Toast(title: "Title Only")
		#expect(shortToast.duration == Achtung.onScreenTime)
	}

	// MARK: - Toast Sharing Tests

	@Test("Toast with sharing title")
	func toastWithSharingTitle() {
		let toast = Achtung.Toast(
			title: "Share This",
			sharingTitle: "Shared Content"
		)

		#expect(toast.sharingTitle == "Shared Content")
	}

	// MARK: - Toast Tap Action Tests

	@Test("Toast with tap action")
	func toastWithTapAction() async {
		var tapped = false

		let toast = Achtung.Toast(
			title: "Tappable",
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
