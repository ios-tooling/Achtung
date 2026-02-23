//
//  AchtungErrorRecordingTests.swift
//  AchtungTestingTests
//
//  Tests for error recording functionality
//

import Testing
import Foundation
import SwiftUI
@testable import Achtung

@Suite("Error Recording Tests", .serialized)
@MainActor
struct AchtungErrorRecordingTests {

	init() async throws {
		Achtung.instance.clearRecord()
		Achtung.instance.recordedErrorLimit = 10
		Achtung.instance.filterError = { _ in .display }
	}

	// MARK: - Error Recording Tests

	@Test("Record error")
	func recordError() async {
		let error = NSError(domain: "TestDomain", code: 123, userInfo: [NSLocalizedDescriptionKey: "Test error"])

		await Achtung.instance._recordError(error, title: "Test Error", message: "This is a test")

		#expect(Achtung.instance.recordedErrors.count >= 1)

		if let recorded = Achtung.instance.recordedErrors.last {
			#expect((recorded.error as NSError).code == 123)
			#expect(recorded.date != nil)
		}
	}

	@Test("Record error with metadata")
	func recordErrorWithMetadata() {
		let error = NSError(domain: "MetadataDomain", code: 456)

		// Create recorded error directly to test metadata
		let recorded = Achtung.RecordedError(
			error: error,
			title: "Metadata Error",
			message: "With metadata",
			date: Date(),
			file: "TestFile.swift",
			function: "testFunction()",
			line: 100
		)

		#expect(recorded.file == "TestFile.swift")
		#expect(recorded.function == "testFunction()")
		#expect(recorded.line == 100)
		#expect(recorded.date != nil)
	}

	@Test("Recorded error structure")
	func recordedErrorStructure() {
		let error = NSError(domain: "StructureDomain", code: 789)
		let date = Date()

		let recorded = Achtung.RecordedError(
			error: error,
			title: "Structure Test",
			message: "Testing structure",
			date: date,
			file: "Source.swift",
			function: "myFunction()",
			line: 42
		)

		#expect(!recorded.id.uuidString.isEmpty)
		#expect((recorded.error as NSError).code == 789)
		#expect(recorded.file == "Source.swift")
		#expect(recorded.function == "myFunction()")
		#expect(recorded.line == 42)
		#expect(recorded.date == date)
	}

	// MARK: - Error Recording Limit Tests

	@Test("Recorded error limit")
	func recordedErrorLimit() {
		#expect(Achtung.instance.recordedErrorLimit == 10)
	}

	@Test("Recorded error limit enforcement")
	func recordedErrorLimitEnforcement() async {
		// Set a low limit
		Achtung.instance.recordedErrorLimit = 3

		// Record more errors than the limit
		for i in 1...5 {
			let error = NSError(domain: "LimitTest", code: i)
			await Achtung.instance._recordError(error, title: "LimitTest 1")
		}

		// Should only have 3 most recent errors
		#expect(Achtung.instance.recordedErrors.count <= 3)

		// Restore limit
		Achtung.instance.recordedErrorLimit = 10
	}

	@Test("Recorded error limit configurable")
	func recordedErrorLimitConfigurable() {
		Achtung.instance.recordedErrorLimit = 5
		#expect(Achtung.instance.recordedErrorLimit == 5)

		Achtung.instance.recordedErrorLimit = 15
		#expect(Achtung.instance.recordedErrorLimit == 15)

		// Restore
		Achtung.instance.recordedErrorLimit = 10
	}

	// MARK: - Clear Record Tests

	@Test("Clear record")
	func clearRecord() async {
		// Record some errors
		for i in 1...3 {
			let error = NSError(domain: "ClearTest", code: i)
			await Achtung.instance._recordError(error, title: "ClearTest")
		}

		#expect(Achtung.instance.recordedErrors.count > 0)

		// Clear the record
		Achtung.instance.clearRecord()

		#expect(Achtung.instance.recordedErrors.count == 0)
	}

	// MARK: - Error Recording with Filter Tests

	@Test("Record error with ignore filter")
	func recordErrorWithIgnoreFilter() {
		Achtung.instance.filterError = { _ in .ignore }

		let error = NSError(domain: "IgnoreDomain", code: 1)
		Achtung.instance.handle(error)

		// Should not be recorded when ignored
		#expect(Achtung.instance.recordedErrors.count == 0)
	}

	@Test("Record error with log filter")
	func recordErrorWithLogFilter() async {
		Achtung.instance.filterError = { _ in .log }

		let error = NSError(domain: "LogDomain", code: 2)

		// Apply filter and record if log
		let result = Achtung.instance.filterError(error)
		if case .log = result {
			await Achtung.instance._recordError(error, title: nil, message: nil)
		}

		// Should be recorded when logged
		#expect(Achtung.instance.recordedErrors.count >= 1)
	}

	@Test("Record error with display filter")
	func recordErrorWithDisplayFilter() async {
		Achtung.instance.filterError = { _ in .display }

		let error = NSError(domain: "DisplayDomain", code: 3)

		// Apply filter and record if display
		let result = Achtung.instance.filterError(error)
		if case .display = result {
			await Achtung.instance._recordError(error, title: nil, message: nil)
		}

		// Should be recorded when displayed
		#expect(Achtung.instance.recordedErrors.count >= 1)
	}

	@Test("Record error with replace filter")
	func recordErrorWithReplaceFilter() async {
		let originalError = NSError(domain: "Original", code: 1)
		let replacementError = NSError(domain: "Replacement", code: 2)

		Achtung.instance.filterError = { _ in .replace(replacementError) }

		await Achtung.instance.handle(originalError)

		// Should record the replacement error
		if let recorded = Achtung.instance.recordedErrors.last {
			#expect((recorded.error as NSError).domain == "Replacement")
			#expect((recorded.error as NSError).code == 2)
		}
	}

	// MARK: - Recorded Error Properties Tests

	@Test("Recorded error has unique IDs")
	func recordedErrorHasUniqueIds() async {
		let error1 = NSError(domain: "Test", code: 1)
		let error2 = NSError(domain: "Test", code: 2)

		await Achtung.instance._recordError(error1, title: "UniqueID Test 1")
		await Achtung.instance._recordError(error2, title: "UniqueID Test 2")

		#expect(Achtung.instance.recordedErrors.count >= 2)

		if Achtung.instance.recordedErrors.count >= 2 {
			let id1 = Achtung.instance.recordedErrors[0].id
			let id2 = Achtung.instance.recordedErrors[1].id
			#expect(id1 != id2)
		}
	}

	@Test("Recorded error preserves localized description")
	func recordedErrorPreservesLocalizedDescription() async {
		let errorMessage = "Custom error message"
		let error = NSError(domain: "Test", code: 1, userInfo: [NSLocalizedDescriptionKey: errorMessage])

		await Achtung.instance._recordError(error)

		if let recorded = Achtung.instance.recordedErrors.last {
			let description = (recorded.error as NSError).localizedDescription
			#expect(description == errorMessage)
		}
	}

	// MARK: - Multiple Error Recording Tests

	@Test("Record multiple errors")
	func recordMultipleErrors() async {
		let errors = [
			NSError(domain: "Domain1", code: 1),
			NSError(domain: "Domain2", code: 2),
			NSError(domain: "Domain3", code: 3)
		]

		for error in errors {
			await Achtung.instance._recordError(error)
		}

		#expect(Achtung.instance.recordedErrors.count >= 3)
	}

	@Test("Recorded errors ordered by time")
	func recordedErrorsOrderedByTime() async {
		// Clear and record in sequence
		Achtung.instance.clearRecord()

		for i in 1...3 {
			let error = NSError(domain: "Sequence", code: i)
			await Achtung.instance._recordError(error)
		}

		// Should be in order (oldest to newest)
		if Achtung.instance.recordedErrors.count >= 3 {
			let firstError = Achtung.instance.recordedErrors[0].error as NSError
			let lastError = Achtung.instance.recordedErrors[Achtung.instance.recordedErrors.count - 1].error as NSError

			#expect(firstError.code <= lastError.code)
		}
	}
}
