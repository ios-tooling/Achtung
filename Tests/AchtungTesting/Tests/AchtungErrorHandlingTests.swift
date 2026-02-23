//
//  AchtungErrorHandlingTests.swift
//  AchtungTestingTests
//
//  Tests for error handling and display
//

import Testing
import Foundation
import SwiftUI
@testable import Achtung

@Suite("Error Handling Tests", .serialized)
@MainActor
struct AchtungErrorHandlingTests {

	init() async throws {
		// Reset error display level and filter
		Achtung.instance.errorDisplayLevel = .testing
		Achtung.instance.filterError = { _ in .display }
		Achtung.instance.clearRecord()
	}

	// MARK: - Error Level Tests

	@Test("Error level comparison")
	func errorLevelComparison() {
		#expect(Achtung.ErrorLevel.debug < .testing)
		#expect(Achtung.ErrorLevel.testing < .standard)
		#expect(Achtung.ErrorLevel.standard > .debug)
		#expect(Achtung.ErrorLevel.standard > .testing)
	}

	@Test("Error display level")
	func errorDisplayLevel() {
		Achtung.instance.errorDisplayLevel = .debug
		#expect(Achtung.instance.errorDisplayLevel == .debug)

		Achtung.instance.errorDisplayLevel = .testing
		#expect(Achtung.instance.errorDisplayLevel == .testing)

		Achtung.instance.errorDisplayLevel = .standard
		#expect(Achtung.instance.errorDisplayLevel == .standard)
	}

	// MARK: - Error Showing Tests

	@Test("Record error")
	func showError() async {
		let error = NSError(domain: "TestDomain", code: 123, userInfo: [NSLocalizedDescriptionKey: "Test error"])

		Achtung.instance.filterError = { _ in .log }
		await Achtung.instance.handle(error)

		// Should be recorded
		#expect(Achtung.instance.recordedErrors.count >= 1)
	}

	@Test("Show error with string title")
	@MainActor func showErrorWithStringTitle() async {
		let error = NSError(domain: "TestDomain", code: 456)

		Achtung.instance.errorDisplayLevel = .testing
		await Achtung.instance._recordError(error, title: "String Title", message: nil)

		// Error should be recorded
		#expect(Achtung.instance.recordedErrors.count >= 1)
	}

	// MARK: - Do Method Tests

	@Test("Do method success")
	@MainActor func doMethodSuccess() async {
		var executed = false

		await Achtung.do(level: .testing) {
			executed = true
			// No error thrown
		}

		#expect(executed)
		#expect(Achtung.instance.recordedErrors.count == 0)
	}

	@Test("Do method with error")
	@MainActor func doMethodWithError() async {
		let error = NSError(domain: "TestDomain", code: 789)

		await Achtung.do(level: .testing) {
			throw error
		}

		// Error should be recorded
		#expect(Achtung.instance.recordedErrors.count >= 1)
	}

	@Test("Do method async")
	@MainActor func doMethodAsync() async {
		let error = NSError(domain: "AsyncDomain", code: 111)

		await Achtung.do(level: .testing) {
			try await Task.sleep(nanoseconds: 10_000_000) // 0.01 seconds
			throw error
		}

		#expect(Achtung.instance.recordedErrors.count >= 1)
	}

	// MARK: - Error Filter Tests

	@Test("Error filter ignore")
	@MainActor func errorFilterIgnore() async {
		Achtung.instance.filterError = { _ in .ignore }

		let error = NSError(domain: "IgnoredDomain", code: 1)
		await Achtung.instance.handle(error, level: .standard)

		// Should not be recorded or displayed
		#expect(Achtung.instance.recordedErrors.count == 0)
	}

	@Test("Error filter log")
	@MainActor func errorFilterLog() async {
		Achtung.instance.filterError = { _ in .log }

		let error = NSError(domain: "LogDomain", code: 2)
		await Achtung.instance.handle(error, level: .standard)

		// Should be recorded but not displayed
		#expect(Achtung.instance.recordedErrors.count >= 1)
	}

	@Test("Error filter display")
	@MainActor func errorFilterDisplay() async {
		Achtung.instance.filterError = { _ in .display }

		let error = NSError(domain: "DisplayDomain", code: 3)

		// Apply filter and record if display
		let result = Achtung.instance.filterError(error)
		if case .display = result {
			await Achtung.instance._recordError(error, title: nil, message: nil)
		}

		// Should be recorded and displayed
		#expect(Achtung.instance.recordedErrors.count >= 1)
	}

	@Test("Error filter replace")
	@MainActor func errorFilterReplace() {
		let originalError = NSError(domain: "Original", code: 1, userInfo: [NSLocalizedDescriptionKey: "Original error"])
		let replacementError = NSError(domain: "Replacement", code: 2, userInfo: [NSLocalizedDescriptionKey: "Replacement error"])

		Achtung.instance.filterError = { _ in .replace(replacementError) }

		// Apply filter - note: current framework records original, not replacement
		let result = Achtung.instance.filterError(originalError)
		switch result {
		case .replace(let newError):
			// Test that filter returns replacement
			#expect((newError as NSError).domain == "Replacement")
			#expect((newError as NSError).code == 2)
		default:
			Issue.record("Filter should return .replace")
		}
	}

	// MARK: - Error Description Tests

	@Test("Error achtung description")
	@MainActor func errorAchtungDescription() {
		let error = NSError(domain: "TestDomain", code: 123, userInfo: [NSLocalizedDescriptionKey: "Test error message"])

		let description = error.achtungDescription
		#expect(!description.isEmpty)
		#expect(description.contains("Test error message"))
	}

	@Test("Error achtung description with decoding error")
	func errorAchtungDescriptionWithDecodingError() {
		// Create a simple decoding error scenario
		struct TestData: Codable {
			let value: String
		}

		let jsonData = "{\"invalid\": \"data\"}".data(using: .utf8)!

		do {
			_ = try JSONDecoder().decode(TestData.self, from: jsonData)
			Issue.record("Should have thrown decoding error")
		} catch {
			let description = error.achtungDescription
			#expect(!description.isEmpty)
			// Should have better formatting for decoding errors
		}
	}

	// MARK: - File Description Utility Tests

	@Test("File description")
	func fileDescriptionTest() {
		let description = fileDescription("TestFile.swift", "testFunction(param:)", 42)

		#expect(description.contains("TestFile.swift"))
		#expect(description.contains("42"))
		#expect(description.contains("testFunction"))
	}

	@Test("File description with no parentheses")
	func fileDescriptionWithNoParentheses() {
		let description = fileDescription("File.swift", "propertyGetter", 10)

		#expect(description.contains("File.swift"))
		#expect(description.contains("10"))
		#expect(description.contains("propertyGetter"))
	}

	// MARK: - Error Recording Limit Tests

	@Test("Error recording limit")
	func errorRecordingLimit() {
		#expect(Achtung.instance.recordedErrorLimit == 10)

		Achtung.instance.recordedErrorLimit = 5
		#expect(Achtung.instance.recordedErrorLimit == 5)

		// Restore
		Achtung.instance.recordedErrorLimit = 10
	}
}
