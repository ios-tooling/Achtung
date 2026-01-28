//
//  AchtungTests.swift
//  AchtungTests
//
//  Basic tests for Achtung framework
//

import XCTest
@testable import Achtung

@available(macOS 10.15, iOS 14.0, *)
final class AchtungTests: XCTestCase {

	func testErrorLevelComparison() {
		XCTAssertLessThan(Achtung.ErrorLevel.debug, .testing)
		XCTAssertLessThan(Achtung.ErrorLevel.testing, .standard)
		XCTAssertGreaterThan(Achtung.ErrorLevel.standard, .debug)
	}

	func testFileDescriptionWithSimpleFunction() {
		let result = fileDescription("Test.swift", "myFunction()", 42)
		XCTAssertTrue(result.contains("Test.swift"))
		XCTAssertTrue(result.contains("42"))
		XCTAssertTrue(result.contains("myFunction"))
	}

	func testFileDescriptionWithComplexFunction() {
		let result = fileDescription("Complex.swift", "myFunction(param1:param2:)", 100)
		XCTAssertTrue(result.contains("Complex.swift"))
		XCTAssertTrue(result.contains("100"))
		XCTAssertTrue(result.contains("myFunction"))
	}

	func testFileDescriptionWithNoParentheses() {
		// This tests the fix for the force unwrap issue
		let result = fileDescription("NoParens.swift", "someProperty", 5)
		XCTAssertTrue(result.contains("NoParens.swift"))
		XCTAssertTrue(result.contains("5"))
		XCTAssertTrue(result.contains("someProperty"))
	}

	func testToastDisplayStyleDeprecatedAlias() {
		// Test that the deprecated ToastNativity alias still works
		let _: ToastNativity = .custom
		let _: ToastNativity = .native
		let _: ToastNativity = .automatic

		// Test deprecated .ifPossible still maps to .automatic
		XCTAssertEqual(ToastDisplayStyle.ifPossible, .automatic)
	}

	func testErrorFilterResults() {
		let ignoreResult = Achtung.ErrorFilterResult.ignore
		let logResult = Achtung.ErrorFilterResult.log
		let displayResult = Achtung.ErrorFilterResult.display

		// Just ensure all cases compile and are accessible
		switch ignoreResult {
		case .ignore: break
		case .log: XCTFail()
		case .display: XCTFail()
		case .replace: XCTFail()
		}

		switch logResult {
		case .ignore: XCTFail()
		case .log: break
		case .display: XCTFail()
		case .replace: XCTFail()
		}

		switch displayResult {
		case .ignore: XCTFail()
		case .log: XCTFail()
		case .display: break
		case .replace: XCTFail()
		}
	}
}
