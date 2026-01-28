//
//  AlertTests.swift
//  AchtungTests
//
//  Tests for alert creation and tag-based deduplication
//

import XCTest
import SwiftUI
@testable import Achtung

@available(macOS 10.15, iOS 14.0, *)
@MainActor
final class AlertTests: XCTestCase {

	func testAlertCreationWithStringTag() {
		let alert = Achtung.Alert(
			"Test Alert",
			message: Text("Test Message"),
			tag: "test-tag",
			buttons: [.ok()]
		)

		XCTAssertEqual(alert.tag, "test-tag")
		XCTAssertEqual(alert.buttons.count, 1)
	}

	func testAlertCreationWithEnumTag() {
		enum AlertTag: String {
			case networkError
			case validationError
		}

		let alert = Achtung.Alert(
			"Network Error",
			tag: AlertTag.networkError.rawValue,
			buttons: [.ok()]
		)

		XCTAssertEqual(alert.tag, AlertTag.networkError.rawValue)
	}

	func testAlertCreationWithoutTag() {
		let alert = Achtung.Alert(
			"No Tag Alert",
			buttons: [.ok()]
		)

		XCTAssertNil(alert.tag)
	}

	func testAlertEquality() {
		let alert1 = Achtung.Alert("Test 1", buttons: [.ok()])
		let alert2 = Achtung.Alert("Test 2", buttons: [.ok()])

		// Alerts with different IDs should not be equal
		XCTAssertNotEqual(alert1, alert2)

		// Alert should be equal to itself
		XCTAssertEqual(alert1, alert1)
	}

	func testButtonTypes() {
		let normalButton = Achtung.Button.default(Text("Normal"))
		XCTAssertEqual(normalButton.kind, .normal)

		let okButton = Achtung.Button.ok()
		XCTAssertEqual(okButton.kind, .normal)

		let cancelButton = Achtung.Button.cancel()
		XCTAssertEqual(cancelButton.kind, .cancel)

		let destructiveButton = Achtung.Button.destructive(Text("Delete"))
		XCTAssertEqual(destructiveButton.kind, .destructive)
	}

	func testAlertFieldInfo() {
		@State var text = "Initial"
		let binding = Binding(get: { text }, set: { text = $0 })

		let fieldInfo = Achtung.Alert.FieldInfo(
			text: binding,
			limit: 100,
			placeholder: "Enter text"
		)

		XCTAssertEqual(fieldInfo.limit, 100)
		XCTAssertEqual(fieldInfo.placeholder, "Enter text")
		XCTAssertEqual(fieldInfo.text.wrappedValue, "Initial")
	}

	func testAlertWithFieldText() {
		@State var text = ""
		let binding = Binding(get: { text }, set: { text = $0 })

		let alert = Achtung.Alert(
			"Enter Name",
			message: Text("Please enter your name"),
			fieldText: binding,
			fieldPlaceholder: "Name",
			buttons: [.ok(), .cancel()]
		)

		XCTAssertNotNil(alert.fieldInfo)
		XCTAssertEqual(alert.fieldInfo?.placeholder, "Name")
		XCTAssertEqual(alert.buttons.count, 2)
	}
}
