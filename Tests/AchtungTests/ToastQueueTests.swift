//
//  ToastQueueTests.swift
//  AchtungTests
//
//  Tests for toast queue management and limits
//

import XCTest
@testable import Achtung

@available(macOS 10.15, iOS 14.0, *)
@MainActor
final class ToastQueueTests: XCTestCase {

	func testMaxPendingToastsDefault() {
		let instance = Achtung.instance
		XCTAssertEqual(instance.maxPendingToasts, 10, "Default maxPendingToasts should be 10")
	}

	func testMaxPendingToastsConfigurable() {
		let instance = Achtung.instance
		instance.maxPendingToasts = 5
		XCTAssertEqual(instance.maxPendingToasts, 5, "maxPendingToasts should be configurable")

		// Reset to default
		instance.maxPendingToasts = 10
	}

	func testToastInitializerWithAllParameters() {
		let toast = Achtung.Toast(
			id: "test-id",
			title: "Test Title",
			localizedTitle: nil,
			displayStyle: .custom,
			message: "Test Message",
			error: nil,
			duration: 5.0,
			foregroundColor: nil,
			borderColor: nil,
			backgroundColor: nil,
			sharingTitle: nil,
			leadingView: nil,
			accessoryView: nil,
			tapAction: nil,
			file: "Test.swift",
			function: "testFunction()",
			line: 42
		)

		XCTAssertEqual(toast.id, "test-id")
		XCTAssertEqual(toast.title, "Test Title")
		XCTAssertEqual(toast.message, "Test Message")
		XCTAssertEqual(toast.duration, 5.0)
		XCTAssertEqual(toast.displayStyle, .custom)
		XCTAssertEqual(toast.file.description, "Test.swift")
		XCTAssertEqual(toast.line, 42)
	}

	func testToastDurationDefaults() {
		// Toast with both title and message should use longOnScreenTime
		let longToast = Achtung.Toast(
			title: "Title",
			message: "Message"
		)
		XCTAssertEqual(longToast.duration, Achtung.longOnScreenTime)

		// Toast with only title should use onScreenTime
		let shortToast = Achtung.Toast(
			title: "Title Only"
		)
		XCTAssertEqual(shortToast.duration, Achtung.onScreenTime)
	}

	func testToastDisplayStyleConversion() {
		// .automatic should be converted to .native internally
		let autoToast = Achtung.Toast(
			title: "Auto",
			displayStyle: .automatic
		)
		XCTAssertEqual(autoToast.displayStyle, .native)

		// .custom should remain .custom
		let customToast = Achtung.Toast(
			title: "Custom",
			displayStyle: .custom
		)
		XCTAssertEqual(customToast.displayStyle, .custom)

		// .native should remain .native
		let nativeToast = Achtung.Toast(
			title: "Native",
			displayStyle: .native
		)
		XCTAssertEqual(nativeToast.displayStyle, .native)
	}
}
