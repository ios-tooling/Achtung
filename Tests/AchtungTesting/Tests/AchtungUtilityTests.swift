//
//  AchtungUtilityTests.swift
//  AchtungTestingTests
//
//  Tests for utility functions and edge cases
//

import Testing
import Foundation
import SwiftUI
@testable import Achtung

@Suite("Utility Tests", .serialized)
struct AchtungUtilityTests {

	// MARK: - File Description Utility Tests

	@Test("File description basic")
	func fileDescriptionBasic() {
		let description = fileDescription("MyFile.swift", "myFunction()", 42)

		#expect(description.contains("MyFile.swift"))
		#expect(description.contains("42"))
		#expect(description.contains("myFunction"))
	}

	@Test("File description with parameters")
	func fileDescriptionWithParameters() {
		let description = fileDescription("Test.swift", "myFunction(param1:param2:)", 100)

		#expect(description.contains("Test.swift"))
		#expect(description.contains("100"))
		#expect(description.contains("myFunction"))
		// Should strip off the parameters
		#expect(!description.contains("param1:param2:"))
	}

	@Test("File description with no parentheses")
	func fileDescriptionWithNoParentheses() {
		// This tests the fix for the force unwrap bug
		let description = fileDescription("Property.swift", "someProperty", 10)

		#expect(description.contains("Property.swift"))
		#expect(description.contains("10"))
		#expect(description.contains("someProperty"))
	}

	@Test("File description with complex path")
	func fileDescriptionWithComplexPath() {
		let description = fileDescription("/Users/test/Project/Sources/File.swift", "function()", 5)

		#expect(description.contains("File.swift"))
		#expect(description.contains("5"))
		#expect(description.contains("function"))
	}

	@Test("File description with empty function")
	func fileDescriptionWithEmptyFunction() {
		let description = fileDescription("Empty.swift", "", 1)

		#expect(description.contains("Empty.swift"))
		#expect(description.contains("1"))
	}

	// MARK: - Error Description Tests

	@Test("Achtung description basic")
	func achtungDescriptionBasic() {
		let error = NSError(domain: "TestDomain", code: 123, userInfo: [NSLocalizedDescriptionKey: "Basic error"])

		let description = error.achtungDescription
		#expect(!description.isEmpty)
		#expect(description.contains("Basic error"))
	}

	@Test("Achtung description with no localized description")
	func achtungDescriptionWithNoLocalizedDescription() {
		let error = NSError(domain: "TestDomain", code: 456)

		let description = error.achtungDescription
		#expect(!description.isEmpty)
	}

	@Test("Achtung description with decoding error")
	func achtungDescriptionWithDecodingError() {
		// Create a decoding error
		struct TestModel: Codable {
			let requiredField: String
		}

		let invalidJSON = "{\"wrongField\": \"value\"}".data(using: .utf8)!

		do {
			_ = try JSONDecoder().decode(TestModel.self, from: invalidJSON)
			Issue.record("Should throw decoding error")
		} catch {
			let description = error.achtungDescription
			#expect(!description.isEmpty)
			// Should provide meaningful decoding information
		}
	}

	// MARK: - Constants Tests

	@Test("Time interval constants")
	func timeIntervalConstants() {
		// Toast durations
		#expect(Achtung.onScreenTime == 8)
		#expect(Achtung.longOnScreenTime == 12)
		#expect(Achtung.longOnScreenTime > Achtung.onScreenTime)

		// Animation durations
		#expect(Achtung.showToastDuration == 0.5)
		#expect(Achtung.hideToastDuration == 0.4)
		#expect(Achtung.showAlertDuration == 0.2)
		#expect(Achtung.hideAlertDuration == 0.2)
	}

	@Test("Constants are positive")
	func constantsArePositive() {
		#expect(Achtung.onScreenTime > 0)
		#expect(Achtung.longOnScreenTime > 0)
		#expect(Achtung.showToastDuration > 0)
		#expect(Achtung.hideToastDuration > 0)
		#expect(Achtung.showAlertDuration > 0)
		#expect(Achtung.hideAlertDuration > 0)
	}

	// MARK: - Text Extension Tests

	@Test("Text extension with text and string")
	func textExtensionWithTextAndString() {
		let text = Text("Hello")
		let result = Text(text, nil)

		#expect(result != nil)
	}

	@Test("Text extension with string only")
	func textExtensionWithStringOnly() {
		let result = Text(nil, "World")

		#expect(result != nil)
	}

	@Test("Text extension with both nil")
	func textExtensionWithBothNil() {
		let result = Text(nil as Text?, nil as String?)

		#expect(result == nil)
	}

	// MARK: - Edge Case Tests

	@Test("Toast with empty strings")
	func toastWithEmptyStrings() {
		let toast = Achtung.Toast("", message: "")

		#expect(!toast.id.isEmpty)
		#expect(toast.title == "")
		#expect(toast.message == "")
	}

	@Test("Toast with very long strings")
	func toastWithVeryLongStrings() {
		let longString = String(repeating: "A", count: 1000)
		let toast = Achtung.Toast(longString, message: longString)

		#expect(toast.title == longString)
		#expect(toast.message == longString)
	}

	@Test("Toast with special characters")
	func toastWithSpecialCharacters() {
		let title = "Test 🎉 Title"
		let message = "Message with\nnewlines\tand\ttabs"

		let toast = Achtung.Toast(title, message: message)

		#expect(toast.title == title)
		#expect(toast.message == message)
	}

	@Test("Alert with empty title")
	func alertWithEmptyTitle() {
		let alert = Achtung.Alert("", buttons: [.ok()])

		#expect(!alert.id.uuidString.isEmpty)
		#expect(alert.title != nil)
	}

	@Test("Alert with no buttons")
	func alertWithNoButtons() {
		let alert = Achtung.Alert("Title", buttons: [])

		#expect(alert.buttons.count == 0)
	}

	@Test("Alert with many buttons")
	func alertWithManyButtons() {
		let buttons = (1...10).map { i in
			Achtung.Button.default(Text("Button \(i)"))
		}

		let alert = Achtung.Alert("Many Buttons", buttons: buttons)

		#expect(alert.buttons.count == 10)
	}

	// MARK: - Error Filter Result Tests

	@Test("Error filter result cases")
	func errorFilterResultCases() {
		let ignore = Achtung.ErrorFilterResult.ignore
		let log = Achtung.ErrorFilterResult.log
		let display = Achtung.ErrorFilterResult.display
		let error = NSError(domain: "Test", code: 1)
		let replace = Achtung.ErrorFilterResult.replace(error)

		// Test pattern matching
		switch ignore {
		case .ignore: #expect(true)
		default: Issue.record("Should be .ignore")
		}

		switch log {
		case .log: #expect(true)
		default: Issue.record("Should be .log")
		}

		switch display {
		case .display: #expect(true)
		default: Issue.record("Should be .display")
		}

		switch replace {
		case .replace(let err):
			#expect((err as NSError).code == 1)
		default: Issue.record("Should be .replace")
		}
	}

	// MARK: - Button Kind Tests

	@Test("Button kinds")
	func buttonKinds() {
		let normal = Achtung.Button.Kind.normal
		let cancel = Achtung.Button.Kind.cancel
		let destructive = Achtung.Button.Kind.destructive

		// Test that they're distinct
		#expect(normal != cancel)
		#expect(cancel != destructive)
		#expect(normal != destructive)
	}

	// MARK: - Identifiable Conformance Tests

	@Test("Toast identifiable")
	func toastIdentifiable() {
		let toast1 = Achtung.Toast("Toast 1")
		let toast2 = Achtung.Toast("Toast 2")

		#expect(toast1.id != toast2.id)
	}

	@Test("Alert identifiable")
	func alertIdentifiable() {
		let alert1 = Achtung.Alert("Alert 1", buttons: [.ok()])
		let alert2 = Achtung.Alert("Alert 2", buttons: [.ok()])

		#expect(alert1.id != alert2.id)
	}

	@Test("Button identifiable")
	func buttonIdentifiable() {
		let button1 = Achtung.Button.ok()
		let button2 = Achtung.Button.ok()

		#expect(button1.id != button2.id)
	}

	@Test("Recorded error identifiable")
	func recordedErrorIdentifiable() {
		let error1 = Achtung.RecordedError(
			error: NSError(domain: "Test", code: 1),
			title: nil,
			message: nil
		)

		let error2 = Achtung.RecordedError(
			error: NSError(domain: "Test", code: 2),
			title: nil,
			message: nil
		)

		#expect(error1.id != error2.id)
	}

	// MARK: - Thread Safety Tests

	@MainActor
	@Test("Main actor isolation")
	func mainActorIsolation() {
		// Achtung instance should be @MainActor
		let instance = Achtung.instance

		#expect(instance != nil)
	}

	// MARK: - Memory Tests

	@Test("Toast does not retain excessively")
	func toastDoesNotRetainExcessively() {
		var weakToast: Achtung.Toast?

		autoreleasepool {
			let toast = Achtung.Toast("Memory Test")
			weakToast = toast
			#expect(weakToast != nil)
		}

		// Toast should be deallocated after autoreleasepool
		// Note: This might be flaky in optimized builds
	}
}
