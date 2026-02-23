//
//  AchtungTests.swift
//  AchtungTests
//
//  Basic tests for Achtung framework
//

import Testing
import Foundation
@testable import Achtung

@Suite("Basic Tests")
struct AchtungTests {

	@Test("Error level comparison")
	func errorLevelComparison() {
		#expect(Achtung.ErrorLevel.debug < .testing)
		#expect(Achtung.ErrorLevel.testing < .standard)
		#expect(Achtung.ErrorLevel.standard > .debug)
	}

	@Test("File description with simple function")
	func fileDescriptionWithSimpleFunction() {
		let result = fileDescription("Test.swift", "myFunction()", 42)
		#expect(result.contains("Test.swift"))
		#expect(result.contains("42"))
		#expect(result.contains("myFunction"))
	}

	@Test("File description with complex function")
	func fileDescriptionWithComplexFunction() {
		let result = fileDescription("Complex.swift", "myFunction(param1:param2:)", 100)
		#expect(result.contains("Complex.swift"))
		#expect(result.contains("100"))
		#expect(result.contains("myFunction"))
	}

	@Test("File description with no parentheses")
	func fileDescriptionWithNoParentheses() {
		// This tests the fix for the force unwrap issue
		let result = fileDescription("NoParens.swift", "someProperty", 5)
		#expect(result.contains("NoParens.swift"))
		#expect(result.contains("5"))
		#expect(result.contains("someProperty"))
	}

	@Test("Toast nativity cases")
	func toastNativityCases() {
		// Test that ToastNativity works
		let _: ToastNativity = .custom
		let _: ToastNativity = .native
		let _: ToastNativity = .ifPossible

		#expect(ToastNativity.custom.rawValue == "custom")
		#expect(ToastNativity.native.rawValue == "native")
		#expect(ToastNativity.ifPossible.rawValue == "ifPossible")
	}

	@Test("Error filter results")
	func errorFilterResults() {
		let ignoreResult = Achtung.ErrorFilterResult.ignore
		let logResult = Achtung.ErrorFilterResult.log
		let displayResult = Achtung.ErrorFilterResult.display

		// Just ensure all cases compile and are accessible
		switch ignoreResult {
		case .ignore: break
		case .log: Issue.record("Should be .ignore")
		case .display: Issue.record("Should be .ignore")
		case .replace: Issue.record("Should be .ignore")
		}

		switch logResult {
		case .ignore: Issue.record("Should be .log")
		case .log: break
		case .display: Issue.record("Should be .log")
		case .replace: Issue.record("Should be .log")
		}

		switch displayResult {
		case .ignore: Issue.record("Should be .display")
		case .log: Issue.record("Should be .display")
		case .display: break
		case .replace: Issue.record("Should be .display")
		}
	}
}
