//
//  ErrorRecordingTests.swift
//  AchtungTests
//
//  Tests for error recording and filtering
//

import XCTest
import SwiftUI
@testable import Achtung

@available(macOS 10.15, iOS 14.0, *)
@MainActor
final class ErrorRecordingTests: XCTestCase {

	override func setUp() async throws {
		try await super.setUp()
		// Clear recorded errors before each test
		Achtung.instance.clearRecord()
	}

	func testRecordedErrorLimit() {
		let instance = Achtung.instance
		XCTAssertEqual(instance.recordedErrorLimit, 10, "Default recordedErrorLimit should be 10")
	}

	func testRecordedErrorLimitConfigurable() {
		let instance = Achtung.instance
		instance.recordedErrorLimit = 5
		XCTAssertEqual(instance.recordedErrorLimit, 5, "recordedErrorLimit should be configurable")

		// Reset to default
		instance.recordedErrorLimit = 10
	}

	func testRecordError() async {
		let testError = NSError(domain: "TestDomain", code: 123, userInfo: [NSLocalizedDescriptionKey: "Test error"])

		Achtung.recordError(testError, title: "Test Error", message: "This is a test")

		// Wait a bit for the async recording to complete
		try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

		let recorded = Achtung.instance.recordedErrors
		XCTAssertGreaterThanOrEqual(recorded.count, 1, "Error should be recorded")

		if let lastError = recorded.last {
			XCTAssertEqual((lastError.error as NSError).code, 123)
			XCTAssertNotNil(lastError.date)
		}
	}

	func testClearRecord() async {
		let testError = NSError(domain: "TestDomain", code: 456)
		Achtung.recordError(testError)

		// Wait for recording
		try? await Task.sleep(nanoseconds: 100_000_000)

		Achtung.instance.clearRecord()
		XCTAssertEqual(Achtung.instance.recordedErrors.count, 0, "Recorded errors should be cleared")
	}

	func testErrorFilterIgnore() {
		let instance = Achtung.instance

		// Set filter to ignore all errors
		instance.filterError = { _ in .ignore }

		let testError = NSError(domain: "TestDomain", code: 789)
		instance.handle(testError, level: .standard)

		// Error should be ignored, not recorded
		XCTAssertEqual(instance.recordedErrors.count, 0)
	}

	func testErrorFilterLog() async {
		let instance = Achtung.instance

		// Set filter to log but not display
		instance.filterError = { _ in .log }

		let testError = NSError(domain: "TestDomain", code: 101)
		instance.handle(testError, level: .standard)

		// Wait for recording
		try? await Task.sleep(nanoseconds: 100_000_000)

		// Error should be recorded but not displayed
		XCTAssertGreaterThanOrEqual(instance.recordedErrors.count, 1)
	}

	func testErrorFilterReplace() async {
		let instance = Achtung.instance

		let originalError = NSError(domain: "Original", code: 1)
		let replacementError = NSError(domain: "Replacement", code: 2)

		// Set filter to replace errors
		instance.filterError = { _ in .replace(replacementError) }

		instance.handle(originalError, level: .standard)

		// Wait for recording
		try? await Task.sleep(nanoseconds: 100_000_000)

		// Recorded error should be the replacement
		if let lastError = instance.recordedErrors.last {
			XCTAssertEqual((lastError.error as NSError).domain, "Replacement")
		}
	}

	func testRecordedErrorStructure() {
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

		XCTAssertNotNil(recorded.id)
		XCTAssertEqual((recorded.error as NSError).code, 999)
		XCTAssertEqual(recorded.file, "Test.swift")
		XCTAssertEqual(recorded.function, "testFunction()")
		XCTAssertEqual(recorded.line, 42)
		XCTAssertNotNil(recorded.date)
	}
}
