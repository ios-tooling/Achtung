//
//  AchtungIntegrationTests.swift
//  AchtungTestingTests
//
//  Integration tests for the Achtung framework
//

import Testing
import Foundation
import SwiftUI
@testable import Achtung

@Suite("Integration Tests")
@MainActor
struct AchtungIntegrationTests {

	init() async throws {
		Achtung.instance.clearRecord()
		Achtung.instance.pendingAlerts.removeAll()
		Achtung.instance.toasts.removeAll()
		Achtung.instance.currentToast = nil
		Achtung.instance.errorDisplayLevel = .standard
		Achtung.instance.filterError = { _ in .display }
	}

	// MARK: - Complete Error Flow Tests

	@Test("Complete error handling flow")
	func completeErrorHandlingFlow() async {
		// Create and show an error
		let error = NSError(domain: "IntegrationTest", code: 1, userInfo: [NSLocalizedDescriptionKey: "Integration test error"])

		Achtung.show(error, level: .standard, title: "Test Error")

		// Wait for processing
		try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds

		// Verify error was recorded
		#expect(Achtung.instance.recordedErrors.count >= 1)

		if let recorded = Achtung.instance.recordedErrors.last {
			#expect((recorded.error as NSError).code == 1)
		}
	}

	@Test("Toast and alert simultaneously")
	func toastAndAlertSimultaneously() async {
		// Show both a toast and an alert
		let toast = Achtung.Toast(title: "Toast Message", displayStyle: .custom)
		await Achtung.instance.show(toast: toast)

		Achtung.show(title: "Alert Title", message: "Alert Message", buttons: [.ok()])

		// Wait for processing
		try? await Task.sleep(nanoseconds: 200_000_000)

		// Both should be present in some form
		let hasToast = Achtung.instance.currentToast != nil || !Achtung.instance.toasts.isEmpty
		let hasAlert = !Achtung.instance.pendingAlerts.isEmpty

		// At least one should be present (timing dependent)
		#expect(hasToast || hasAlert)
	}

	@Test("Multiple errors with different levels")
	func multipleErrorsWithDifferentLevels() async {
		Achtung.instance.errorDisplayLevel = .testing

		let debugError = NSError(domain: "Debug", code: 1)
		let testingError = NSError(domain: "Testing", code: 2)
		let standardError = NSError(domain: "Standard", code: 3)

		// Show errors at different levels
		Achtung.show(debugError, level: .debug)
		Achtung.show(testingError, level: .testing)
		Achtung.show(standardError, level: .standard)

		try? await Task.sleep(nanoseconds: 300_000_000)

		// With errorDisplayLevel = .testing, debug errors won't show, but testing and standard will
		// All should be recorded though
		#expect(Achtung.instance.recordedErrors.count >= 2)
	}

	// MARK: - Error Filter Integration Tests

	@Test("Error filter with multiple errors")
	func errorFilterWithMultipleErrors() async {
		var filterCallCount = 0

		Achtung.instance.filterError = { error in
			filterCallCount += 1
			let nsError = error as NSError
			return nsError.code == 1 ? .ignore : .display
		}

		let error1 = NSError(domain: "Filter", code: 1)
		let error2 = NSError(domain: "Filter", code: 2)

		Achtung.instance.handle(error1)
		Achtung.instance.handle(error2)

		try? await Task.sleep(nanoseconds: 200_000_000)

		#expect(filterCallCount == 2)
		// Only error2 should be recorded (error1 was ignored)
		let recordedCodes = Achtung.instance.recordedErrors.map { ($0.error as NSError).code }
		#expect(!recordedCodes.contains(1))
		#expect(recordedCodes.contains(2))
	}

	// MARK: - Toast Queue Integration Tests

	@Test("Toast queue processing")
	func toastQueueProcessing() async {
		// Add multiple toasts
		for i in 1...3 {
			let toast = Achtung.Toast(title: "Toast \(i)", displayStyle: .custom)
			await Achtung.instance.show(toast: toast)
		}

		// Wait for initial processing
		try? await Task.sleep(nanoseconds: 100_000_000)

		// Should have toasts queued or showing
		let totalToasts = Achtung.instance.toasts.count + (Achtung.instance.currentToast != nil ? 1 : 0)
		#expect(totalToasts >= 1)
	}

	@Test("Toast queue limit enforcement")
	func toastQueueLimitEnforcement() async {
		// Set a low limit
		Achtung.instance.maxPendingToasts = 3

		// Try to add more toasts than the limit
		for i in 1...5 {
			let toast = Achtung.Toast(title: "Toast \(i)", displayStyle: .custom)
			await Achtung.instance.show(toast: toast)
		}

		// Should not exceed the limit
		#expect(Achtung.instance.toasts.count <= 3)

		// Restore
		Achtung.instance.maxPendingToasts = 10
	}

	// MARK: - Alert Tag Deduplication Integration Tests

	@Test("Alert deduplication with same tag")
	func alertDeduplicationWithSameTag() async {
		let tag = "duplicate-alert"

		// Show first alert
		Achtung.show(title: Text("First"), tag: tag, buttons: [.ok()])

		try? await Task.sleep(nanoseconds: 100_000_000)

		let countAfterFirst = Achtung.instance.pendingAlerts.count

		// Try to show duplicate
		Achtung.show(title: Text("Second"), tag: tag, buttons: [.ok()])

		try? await Task.sleep(nanoseconds: 100_000_000)

		let countAfterSecond = Achtung.instance.pendingAlerts.count

		// Count should not increase
		#expect(countAfterFirst == countAfterSecond)
	}

	@Test("Alert with different tags")
	func alertWithDifferentTags() async {
		Achtung.show(title: Text("Alert 1"), tag: "tag1", buttons: [.ok()])
		Achtung.show(title: Text("Alert 2"), tag: "tag2", buttons: [.ok()])

		try? await Task.sleep(nanoseconds: 200_000_000)

		// Should have multiple alerts with different tags
		#expect(Achtung.instance.pendingAlerts.count >= 2)
	}

	// MARK: - Error Recording Integration Tests

	@Test("Error recording with limit")
	func errorRecordingWithLimit() async {
		Achtung.instance.recordedErrorLimit = 3

		// Record more than the limit
		for i in 1...5 {
			let error = NSError(domain: "Limit", code: i)
			Achtung.recordError(error)
			try? await Task.sleep(nanoseconds: 50_000_000)
		}

		try? await Task.sleep(nanoseconds: 200_000_000)

		// Should only keep the most recent 3
		#expect(Achtung.instance.recordedErrors.count <= 3)

		// The most recent errors should be codes 3, 4, 5
		if Achtung.instance.recordedErrors.count == 3 {
			let codes = Achtung.instance.recordedErrors.map { ($0.error as NSError).code }
			#expect(codes.contains(3))
			#expect(codes.contains(4))
			#expect(codes.contains(5))
		}

		// Restore
		Achtung.instance.recordedErrorLimit = 10
	}

	// MARK: - HandleErrors Integration Tests

	@Test("HandleErrors with complex scenario")
	func handleErrorsWithComplexScenario() async throws {
		var successCount = 0
		var errorCount = 0

		// Multiple handleErrors calls
		for i in 1...5 {
			try Achtung.handleErrors(level: .testing) {
				if i % 2 == 0 {
					throw NSError(domain: "HandleErrors", code: i)
				} else {
					successCount += 1
				}
			}
		}

		try? await Task.sleep(nanoseconds: 300_000_000)

		#expect(successCount == 3) // 1, 3, 5 succeed
		// 2, 4 throw errors and should be recorded
		let errorCodes = Achtung.instance.recordedErrors.map { ($0.error as NSError).code }
		errorCount = errorCodes.filter { [2, 4].contains($0) }.count
		#expect(errorCount == 2)
	}

	// MARK: - Color Configuration Tests

	@Test("Default colors")
	func defaultColors() {
		// Alert colors
		#expect(Achtung.instance.alertBackgroundColor == .black)
		#expect(Achtung.instance.alertForegroundColor == .white)

		// Toast colors
		#expect(Achtung.instance.toastBackgroundColor == .black)
		#expect(Achtung.instance.toastForegroundColor == .white)
	}

	@Test("Custom color configuration")
	func customColorConfiguration() {
		// Change colors
		Achtung.instance.alertBackgroundColor = .blue
		Achtung.instance.alertForegroundColor = .yellow
		Achtung.instance.toastBackgroundColor = .green
		Achtung.instance.toastForegroundColor = .red

		#expect(Achtung.instance.alertBackgroundColor == .blue)
		#expect(Achtung.instance.alertForegroundColor == .yellow)
		#expect(Achtung.instance.toastBackgroundColor == .green)
		#expect(Achtung.instance.toastForegroundColor == .red)

		// Restore defaults
		Achtung.instance.alertBackgroundColor = .black
		Achtung.instance.alertForegroundColor = .white
		Achtung.instance.toastBackgroundColor = .black
		Achtung.instance.toastForegroundColor = .white
	}

	// MARK: - Singleton Pattern Tests

	@Test("Singleton instance")
	func singletonInstance() {
		let instance1 = Achtung.instance
		let instance2 = Achtung.instance

		// Should be the same instance
		#expect(instance1 === instance2)
	}

	// MARK: - Presentable Protocol Tests

	@Test("Presentable protocol conformance")
	func presentableProtocolConformance() {
		let presentable: AchtungPresentable = Achtung.instance

		// Should be able to call protocol methods
		#expect(presentable != nil)

		// Can configure through protocol
		presentable.maxPendingToasts = 5
		#expect(presentable.maxPendingToasts == 5)

		// Restore
		presentable.maxPendingToasts = 10
	}
}
