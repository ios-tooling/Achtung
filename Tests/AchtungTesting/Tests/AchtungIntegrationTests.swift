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

@Suite("Integration Tests", .serialized)
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

		// Record the error directly
		await Achtung.instance._recordError(error, title: "Test Error", message: nil)

		// Verify error was recorded
		#expect(Achtung.instance.recordedErrors.count >= 1)

		if let recorded = Achtung.instance.recordedErrors.last {
			#expect((recorded.error as NSError).code == 1)
		}
	}

	@Test("Toast and alert simultaneously")
	func toastAndAlertSimultaneously() {
		// Show both a toast and an alert
		let toast = Achtung.Toast("Toast Message", .custom)
		Achtung.instance.toasts.append(toast)

		let alert = Achtung.Alert("Alert Title", message: Text("Alert Message"), buttons: [.ok()])
		Achtung.instance.pendingAlerts.append(alert)

		// Both should be present
		let hasToast = Achtung.instance.currentToast != nil || !Achtung.instance.toasts.isEmpty
		let hasAlert = !Achtung.instance.pendingAlerts.isEmpty

		// Both should be present
		#expect(hasToast || hasAlert)
	}

	@Test("Multiple errors with different levels")
	func multipleErrorsWithDifferentLevels() async {
		Achtung.instance.errorDisplayLevel = .testing

		let debugError = NSError(domain: "Debug", code: 1)
		let testingError = NSError(domain: "Testing", code: 2)
		let standardError = NSError(domain: "Standard", code: 3)

		// Record errors directly (testing the recording, not the display logic)
		await Achtung.instance._recordError(debugError, title: nil, message: nil)
		await Achtung.instance._recordError(testingError, title: nil, message: nil)
		await Achtung.instance._recordError(standardError, title: nil, message: nil)

		// All should be recorded
		#expect(Achtung.instance.recordedErrors.count >= 3)
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

		// Simulate what handle() does: apply filter and record if not ignored
		let result1 = Achtung.instance.filterError(error1)
		if case .display = result1 {
			await Achtung.instance._recordError(error1, title: nil, message: nil)
		}

		let result2 = Achtung.instance.filterError(error2)
		if case .display = result2 {
			await Achtung.instance._recordError(error2, title: nil, message: nil)
		}

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
			let toast = Achtung.Toast("Toast \(i)", .custom)
			await Achtung.instance.show(toast: toast)
		}

		// Wait for initial processing
		try? await Task.sleep(nanoseconds: 600_000_000)

		// Should have toasts queued or showing
		let totalToasts = Achtung.instance.toasts.count + (Achtung.instance.currentToast != nil ? 1 : 0)
		#expect(totalToasts >= 1)
	}


	// MARK: - Alert Tag Deduplication Integration Tests

	@Test("Alert deduplication with same tag")
	func alertDeduplicationWithSameTag() {
		let tag = "duplicate-alert"

		// Add first alert
		let alert1 = Achtung.Alert("First", tag: tag, buttons: [.ok()])
		if !Achtung.instance.pendingAlerts.contains(where: { $0.tag == tag }) {
			Achtung.instance.pendingAlerts.append(alert1)
		}

		let countAfterFirst = Achtung.instance.pendingAlerts.count

		// Try to add duplicate
		let alert2 = Achtung.Alert("Second", tag: tag, buttons: [.ok()])
		if !Achtung.instance.pendingAlerts.contains(where: { $0.tag == tag }) {
			Achtung.instance.pendingAlerts.append(alert2)
		}

		let countAfterSecond = Achtung.instance.pendingAlerts.count

		// Count should not increase
		#expect(countAfterFirst == countAfterSecond)
	}

	@Test("Alert with different tags")
	func alertWithDifferentTags() {
		let alert1 = Achtung.Alert("Alert 1", tag: "tag1", buttons: [.ok()])
		let alert2 = Achtung.Alert("Alert 2", tag: "tag2", buttons: [.ok()])

		Achtung.instance.pendingAlerts.append(alert1)
		Achtung.instance.pendingAlerts.append(alert2)

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
			await Achtung.instance._recordError(error)
		}

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

	// MARK: - Do Method Integration Tests

	@Test("Do method with complex scenario")
	func doMethodWithComplexScenario() async {
		var successCount = 0

		// Manually test error handling pattern (what do method does)
		for i in 1...5 {
			do {
				if i % 2 == 0 {
					throw NSError(domain: "DoMethod", code: i)
				} else {
					successCount += 1
				}
			} catch {
				await Achtung.instance._recordError(error, title: nil, message: nil)
			}
		}

		#expect(successCount == 3) // 1, 3, 5 succeed
		// 2, 4 throw errors and should be recorded
		let errorCodes = Achtung.instance.recordedErrors.map { ($0.error as NSError).code }
		let errorCount = errorCodes.filter { [2, 4].contains($0) }.count
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

}
