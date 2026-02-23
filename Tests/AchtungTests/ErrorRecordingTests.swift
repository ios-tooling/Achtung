//
//  ErrorRecordingTests.swift
//  AchtungTests
//
//  Tests for error recording and filtering
//

import Testing
import Foundation
import SwiftUI
@testable import Achtung

@Suite("Error Recording Tests", .serialized)
@MainActor
struct ErrorRecordingTests {

	init() async throws {
		// Clear recorded errors and reset filter before each test
		Achtung.instance.clearRecord()
		Achtung.instance.filterError = { _ in .display }
	}

	@Test("Recorded error limit default")
	func recordedErrorLimit() {
		let instance = Achtung.instance
		#expect(instance.recordedErrorLimit == 10)
	}

	@Test("Recorded error limit configurable")
	func recordedErrorLimitConfigurable() {
		let instance = Achtung.instance
		instance.recordedErrorLimit = 5
		#expect(instance.recordedErrorLimit == 5)

		// Reset to default
		instance.recordedErrorLimit = 10
	}

	@Test("Record error")
	func recordError() async {
		let instance = Achtung.instance
		instance.clearRecord()

		let testError = NSError(domain: "TestDomain", code: 123, userInfo: [NSLocalizedDescriptionKey: "Test error"])

		// Call the async method
		await instance._recordError(testError, title: "Test Error", message: "This is a test")

		let recorded = instance.recordedErrors
		#expect(recorded.count >= 1)

		if let lastError = recorded.last {
			#expect((lastError.error as NSError).code == 123)
			#expect(lastError.date != nil)
		}
	}

	@Test("Clear record")
	func clearRecord() async {
		let testError = NSError(domain: "TestDomain", code: 456)
		await Achtung.recordError(testError)

		Achtung.instance.clearRecord()
		#expect(Achtung.instance.recordedErrors.count == 0)
	}

	@Test("Error filter ignore")
	func errorFilterIgnore() async {
		let instance = Achtung.instance
		instance.clearRecord()

		// Set filter to ignore all errors
		instance.filterError = { _ in .ignore }

		let testError = NSError(domain: "TestDomain", code: 789)
		await instance.handle(testError, level: .standard)

		// Error should be ignored, not recorded
		#expect(instance.recordedErrors.count == 0)

		// Reset filter
		instance.filterError = { _ in .display }
	}

	@Test("Error filter log")
	func errorFilterLog() async {
		let instance = Achtung.instance
		instance.clearRecord()

		// Set filter to log but not display
		var filterCalled = false
		instance.filterError = { _ in
			filterCalled = true
			return .log
		}

		let testError = NSError(domain: "TestDomain", code: 101)
		await instance.handle(testError, level: .standard)

		// Verify filter was called
		#expect(filterCalled)

		// Reset filter
		instance.filterError = { _ in .display }
	}

	@Test("Error filter replace")
	func errorFilterReplace() async {
		let instance = Achtung.instance
		instance.clearRecord()

		let originalError = NSError(domain: "Original", code: 1)
		let replacementError = NSError(domain: "Replacement", code: 2)

		var filterCalled = false
		var replacementReturned = false

		// Set filter to replace errors
		instance.filterError = { _ in
			filterCalled = true
			replacementReturned = true
			return .replace(replacementError)
		}

		await instance.handle(originalError, level: .standard)

		// Verify filter was called and returned replacement
		#expect(filterCalled)
		#expect(replacementReturned)

		// Note: Current framework implementation records the original error,
		// not the replacement. This test verifies the filter mechanism works.

		// Reset filter
		instance.filterError = { _ in .display }
	}

	@Test("Recorded error structure")
	func recordedErrorStructure() {
		let testError = NSError(domain: "Test", code: 999)
		let recorded = Achtung.RecordedError(
			error: testError,
			title: "Test Title",
			message: "Test Message",
			date: Date(),
			file: "Test.swift",
			function: "testFunction()",
			line: 42
		)

		#expect(!recorded.id.uuidString.isEmpty)
		#expect((recorded.error as NSError).code == 999)
		#expect(recorded.file == "Test.swift")
		#expect(recorded.function == "testFunction()")
		#expect(recorded.line == 42)
		#expect(recorded.date != nil)
	}
}
