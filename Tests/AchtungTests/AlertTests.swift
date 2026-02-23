//
//  AlertTests.swift
//  AchtungTests
//
//  Tests for alert creation and tag-based deduplication
//

import Testing
import Foundation
import SwiftUI
@testable import Achtung

@Suite("Alert Tests")
@MainActor
struct AlertTests {

	@Test("Alert creation with string tag")
	func alertCreationWithStringTag() {
		let alert = Achtung.Alert(
			"Test Alert",
			message: Text("Test Message"),
			tag: "test-tag",
			buttons: [.ok()]
		)

		#expect(alert.tag == "test-tag")
		#expect(alert.buttons.count == 1)
	}

	@Test("Alert creation with enum tag")
	func alertCreationWithEnumTag() {
		enum AlertTag: String {
			case networkError
			case validationError
		}

		let alert = Achtung.Alert(
			"Network Error",
			tag: AlertTag.networkError.rawValue,
			buttons: [.ok()]
		)

		#expect(alert.tag == AlertTag.networkError.rawValue)
	}

	@Test("Alert creation without tag")
	func alertCreationWithoutTag() {
		let alert = Achtung.Alert(
			"No Tag Alert",
			buttons: [.ok()]
		)

		#expect(alert.tag == nil)
	}

	@Test("Alert equality")
	func alertEquality() {
		let alert1 = Achtung.Alert("Test 1", buttons: [.ok()])
		let alert2 = Achtung.Alert("Test 2", buttons: [.ok()])

		// Alerts with different IDs should not be equal
		#expect(alert1 != alert2)

		// Alert should be equal to itself
		#expect(alert1 == alert1)
	}

	@Test("Button types")
	func buttonTypes() {
		let normalButton = Achtung.Button.default(Text("Normal"))
		#expect(normalButton.kind == .normal)

		let okButton = Achtung.Button.ok()
		#expect(okButton.kind == .normal)

		let cancelButton = Achtung.Button.cancel()
		#expect(cancelButton.kind == .cancel)

		let destructiveButton = Achtung.Button.destructive(Text("Delete"))
		#expect(destructiveButton.kind == .destructive)
	}

	@Test("Alert field info")
	func alertFieldInfo() {
		@State var text = "Initial"
		let binding = Binding(get: { text }, set: { text = $0 })

		let fieldInfo = Achtung.Alert.FieldInfo(
			text: binding,
			limit: 100,
			placeholder: "Enter text"
		)

		#expect(fieldInfo.limit == 100)
		#expect(fieldInfo.placeholder == "Enter text")
		#expect(fieldInfo.text.wrappedValue == "Initial")
	}

	@Test("Alert with field text")
	func alertWithFieldText() {
		@State var text = ""
		let binding = Binding(get: { text }, set: { text = $0 })

		let alert = Achtung.Alert(
			"Enter Name",
			message: Text("Please enter your name"),
			fieldText: binding,
			fieldPlaceholder: "Name",
			buttons: [.ok(), .cancel()]
		)

		#expect(alert.fieldInfo != nil)
		#expect(alert.fieldInfo?.placeholder == "Name")
		#expect(alert.buttons.count == 2)
	}
}
