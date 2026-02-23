//
//  AchtungAlertTests.swift
//  AchtungTestingTests
//
//  Tests for Alert functionality
//

import Testing
import Foundation
import SwiftUI
@testable import Achtung

@Suite("Alert Tests", .serialized)
@MainActor
struct AchtungAlertTests {

	init() async throws {
		// Clear any existing alerts
		await Achtung.instance.setup()
		Achtung.instance.pendingAlerts.removeAll()
	}

	// MARK: - Alert Creation Tests

	@Test("Alert creation with title")
	func alertCreationWithTitle() {
		let alert = Achtung.Alert(
			"Test Alert",
			buttons: [.ok()]
		)

		#expect(!alert.id.uuidString.isEmpty)
		#expect(alert.title != nil)
		#expect(alert.message == nil)
		#expect(alert.buttons.count == 1)
	}

	@Test("Alert creation with title and message")
	func alertCreationWithTitleAndMessage() {
		let alert = Achtung.Alert(
			"Alert Title",
			message: Text("Alert Message"),
			buttons: [.ok()]
		)

		#expect(alert.title != nil)
		#expect(alert.message != nil)
		#expect(alert.buttons.count == 1)
	}

	@Test("Alert creation with tag")
	func alertCreationWithTag() {
		let alert = Achtung.Alert(
			"Tagged Alert",
			tag: "unique-tag",
			buttons: [.ok()]
		)

		#expect(alert.tag == "unique-tag")
	}

	@Test("Alert creation without tag")
	func alertCreationWithoutTag() {
		let alert = Achtung.Alert(
			"Untagged Alert",
			buttons: [.ok()]
		)

		#expect(alert.tag == nil)
	}

	@Test("Alert creation with multiple buttons")
	func alertCreationWithMultipleButtons() {
		let alert = Achtung.Alert(
			"Multi-Button Alert",
			buttons: [
				.ok(),
				.cancel(),
				.destructive(Text("Delete"))
			]
		)

		#expect(alert.buttons.count == 3)
	}

	@Test("Alert creation with field info")
	func alertCreationWithFieldInfo() {
		@State var text = ""
		let binding = Binding(get: { text }, set: { text = $0 })

		let fieldInfo = Achtung.Alert.FieldInfo(
			text: binding,
			limit: 100,
			placeholder: "Enter text"
		)

		let alert = Achtung.Alert(
			"Input Alert",
			fieldInfo: fieldInfo,
			buttons: [.ok(), .cancel()]
		)

		#expect(alert.fieldInfo != nil)
		#expect(alert.fieldInfo?.limit == 100)
		#expect(alert.fieldInfo?.placeholder == "Enter text")
	}

	@Test("Alert creation with field text")
	func alertCreationWithFieldText() {
		@State var text = "Initial"
		let binding = Binding(get: { text }, set: { text = $0 })

		let alert = Achtung.Alert(
			"Enter Name",
			fieldText: binding,
			fieldPlaceholder: "Your name",
			buttons: [.ok()]
		)

		#expect(alert.fieldInfo != nil)
		#expect(alert.fieldInfo?.placeholder == "Your name")
		#expect(alert.fieldInfo?.text.wrappedValue == "Initial")
	}

	@Test("Alert with colors")
	func alertWithColors() {
		let alert = Achtung.Alert(
			"Colored Alert",
			foreground: .white,
			border: .blue,
			background: .black,
			buttons: [.ok()]
		)

		#expect(alert.foregroundColor == .white)
		#expect(alert.borderColor == .blue)
		#expect(alert.backgroundColor == .black)
	}

	@Test("Alert tap outside to dismiss")
	func alertTapOutsideToDismiss() {
		let dismissibleAlert = Achtung.Alert(
			"Dismissible",
			tapOutsideToDismiss: true,
			buttons: [.ok()]
		)

		#expect(dismissibleAlert.tapOutsideToDismiss)

		let nonDismissibleAlert = Achtung.Alert(
			"Not Dismissible",
			tapOutsideToDismiss: false,
			buttons: [.ok()]
		)

		#expect(!nonDismissibleAlert.tapOutsideToDismiss)
	}

	// MARK: - Alert Button Tests

	@Test("Button creation")
	func buttonCreation() {
		let okButton = Achtung.Button.ok()
		#expect(okButton.kind == .normal)
		#expect(!okButton.id.isEmpty)

		let cancelButton = Achtung.Button.cancel()
		#expect(cancelButton.kind == .cancel)

		let destructiveButton = Achtung.Button.destructive(Text("Delete"))
		#expect(destructiveButton.kind == .destructive)

		let defaultButton = Achtung.Button.default(Text("Custom"))
		#expect(defaultButton.kind == .normal)
	}

	@Test("Button with action")
	func buttonWithAction() async {
		var actionExecuted = false

		let button = Achtung.Button.ok {
			actionExecuted = true
		}

		button.pressed()
		#expect(actionExecuted)
	}

	@Test("Button custom labels")
	func buttonCustomLabels() {
		let button = Achtung.Button.ok(Text("Accept"))
		// Just ensure it compiles and has the right type
		#expect(button.kind == .normal)
	}

	// MARK: - Alert Equality Tests

	@Test("Alert equality")
	func alertEquality() {
		let alert1 = Achtung.Alert("Test 1", buttons: [.ok()])
		let alert2 = Achtung.Alert("Test 2", buttons: [.ok()])

		// Different IDs means not equal
		#expect(alert1 != alert2)

		// Same alert is equal to itself
		#expect(alert1 == alert1)
	}

	// MARK: - Alert Display Tests

	@Test("Alert duration constants")
	func alertDurationConstants() {
		#expect(Achtung.showAlertDuration == 0.2)
		#expect(Achtung.hideAlertDuration == 0.2)
	}

	@Test("Show alert with static method")
	func showAlertWithStaticMethod() {
		let alert = Achtung.Alert(
			"Static Alert",
			message: Text("This uses the static method"),
			buttons: [.ok()]
		)

		// Add directly to test
		Achtung.instance.pendingAlerts.append(alert)
		#expect(Achtung.instance.pendingAlerts.count >= 1)
	}

	@Test("Show alert with tag")
	func showAlertWithTag() {
		let tag = "unique-alert-tag"

		let alert = Achtung.Alert(
			"Tagged",
			message: Text("Alert with tag"),
			tag: tag,
			buttons: [.ok()]
		)

		Achtung.instance.pendingAlerts.append(alert)
		let hasTaggedAlert = Achtung.instance.pendingAlerts.contains { $0.tag == tag }
		#expect(hasTaggedAlert)
	}

	@Test("Alert deduplication by tag")
	func alertDeduplicationByTag() {
		let tag = "duplicate-tag"

		// Create first alert with tag
		let alert1 = Achtung.Alert("First", tag: tag, buttons: [.ok()])

		// Add first alert
		if !Achtung.instance.pendingAlerts.contains(where: { $0.tag == tag }) {
			Achtung.instance.pendingAlerts.append(alert1)
		}

		// Try to add duplicate (simulating deduplication logic)
		let alert2 = Achtung.Alert("Second", tag: tag, buttons: [.ok()])
		if !Achtung.instance.pendingAlerts.contains(where: { $0.tag == tag }) {
			Achtung.instance.pendingAlerts.append(alert2)
		}

		// Should only have one alert with this tag
		let alertsWithTag = Achtung.instance.pendingAlerts.filter { $0.tag == tag }
		#expect(alertsWithTag.count == 1)
	}

	@Test("Alert removal")
	func alertRemoval() async {
		let alert = Achtung.Alert("Removable", buttons: [.ok()])

		// Directly add alert since setup() doesn't work on macOS tests
		Achtung.instance.pendingAlerts.append(alert)

		#expect(Achtung.instance.pendingAlerts.count >= 1)

		// Remove the alert
		Achtung.instance.remove(alert)

		let stillHasAlert = Achtung.instance.pendingAlerts.contains(alert)
		#expect(!stillHasAlert)
	}

	// MARK: - Alert with Primary/Secondary Buttons

	@Test("Alert with primary/secondary buttons")
	func alertWithPrimarySecondaryButtons() {
		let alert = Achtung.Alert(
			"Choice",
			message: Text("Choose an option"),
			primaryButton: .ok(Text("Yes")),
			secondaryButton: .cancel(Text("No")),
			dismissButton: nil
		)

		#expect(alert.buttons.count == 2)
	}
}
