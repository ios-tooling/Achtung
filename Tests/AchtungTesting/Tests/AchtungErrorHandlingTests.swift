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

@Suite("Error Handling Tests")
@MainActor
struct AchtungErrorHandlingTests {

	init() async throws {
		// Reset error display level and filter
		Achtung.instance.errorDisplayLevel = .standard
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
		Achtung.instance.handle(error)
		// Give it time to process
		try? await Task.sleep(nanoseconds: 200_000_000)

		// Should be recorded
		#expect(Achtung.instance.recordedErrors.count >= 1)
	}

	@Test("Show error with string title")
	@MainActor func showErrorWithStringTitle() async {
		let error = NSError(domain: "TestDomain", code: 456)

		Achtung.instance.errorDisplayLevel = .testing
		Achtung.show(error, level: .testing, title: "String Title")

		try? await Task.sleep(nanoseconds: 1_000_000_000)
		#expect(Achtung.instance.toasts.count >= 1)
	}

	// MARK: - HandleErrors Tests

	@Test("HandleErrors success")
	@MainActor func handleErrorsSuccess() {
		var executed = false

		Achtung.handleErrors(level: .testing) {
			executed = true
			// No error thrown
		}

		#expect(executed)
		#expect(Achtung.instance.recordedErrors.count == 0)
	}

	@Test("HandleErrors with error")
	@MainActor func handleErrorsWithError() async throws {
		let error = NSError(domain: "TestDomain", code: 789)

		try Achtung.handleErrors(level: .testing) {
			throw error
		}

		try? await Task.sleep(nanoseconds: 200_000_000)

		// Error should be recorded
		#expect(Achtung.instance.recordedErrors.count >= 1)
	}

	@Test("HandleErrors with rethrow")
	@MainActor func handleErrorsWithRethrow() {
		let error = NSError(domain: "TestDomain", code: 999)
		var errorCaught = false

		do {
			try Achtung.handleErrors(level: .testing, rethrow: true) {
				throw error
			}
		} catch {
			errorCaught = true
			#expect((error as NSError).code == 999)
		}

		#expect(errorCaught)
	}

	@Test("HandleErrors async")
	@MainActor func handleErrorsAsync() async {
		let error = NSError(domain: "AsyncDomain", code: 111)

		Achtung.handleErrors(level: .testing) {
			try await Task.sleep(nanoseconds: 10_000_000) // 0.01 seconds
			throw error
		}

		try? await Task.sleep(nanoseconds: 500_000_000)
		#expect(Achtung.instance.recordedErrors.count >= 1)
	}

	// MARK: - Deprecated do Method Tests

	@Test("Deprecated do method")
	@MainActor func deprecatedDoMethod() {
		// Test the deprecated do method (suppressing deprecation warning)
		var executed = false

		// Note: This tests the backward compatibility of the deprecated `do` method
		// In production code, use `handleErrors` instead
		Achtung.do(level: .testing) {
			executed = true
		}

		#expect(executed)
	}

	// MARK: - Error Filter Tests

	@Test("Error filter ignore")
	@MainActor func errorFilterIgnore() {
		Achtung.instance.filterError = { _ in .ignore }

		let error = NSError(domain: "IgnoredDomain", code: 1)
		Achtung.instance.handle(error, level: .standard)

		// Should not be recorded or displayed
		#expect(Achtung.instance.recordedErrors.count == 0)
	}

	@Test("Error filter log")
	@MainActor func errorFilterLog() async {
		Achtung.instance.filterError = { _ in .log }

		let error = NSError(domain: "LogDomain", code: 2)
		Achtung.instance.handle(error, level: .standard)

		// Wait for async recording
		try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds

		// Should be recorded but not displayed
		#expect(Achtung.instance.recordedErrors.count >= 1)
	}

	@Test("Error filter display")
	@MainActor func errorFilterDisplay() async {
		Achtung.instance.filterError = { _ in .display }

		let error = NSError(domain: "DisplayDomain", code: 3)
		Achtung.instance.handle(error, level: .standard)

		// Wait for async recording
		try? await Task.sleep(nanoseconds: 200_000_000)

		// Should be recorded and displayed
		#expect(Achtung.instance.recordedErrors.count >= 1)
	}

	@Test("Error filter replace")
	@MainActor func errorFilterReplace() async {
		let originalError = NSError(domain: "Original", code: 1, userInfo: [NSLocalizedDescriptionKey: "Original error"])
		let replacementError = NSError(domain: "Replacement", code: 2, userInfo: [NSLocalizedDescriptionKey: "Replacement error"])

		Achtung.instance.filterError = { _ in .replace(replacementError) }

		Achtung.instance.handle(originalError, level: .standard)

		// Wait for async recording
		try? await Task.sleep(nanoseconds: 200_000_000)

		// Should record the replacement error
		if let recorded = Achtung.instance.recordedErrors.last {
			#expect((recorded.error as NSError).domain == "Replacement")
			#expect((recorded.error as NSError).code == 2)
		} else {
			Issue.record("No error was recorded")
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
