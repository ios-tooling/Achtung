//
//  Achtung.Errors.swift
//  
//
//  Created by Ben Gottlieb on 5/31/23.
//

import SwiftUI

public extension Achtung {
	enum ErrorLevel: Int, Comparable, Sendable { case debug, testing, standard
		public static func <(lhs: Self, rhs: Self) -> Bool { lhs.rawValue < rhs.rawValue }
	}
}


#if os(iOS)

public extension Achtung {
	// MARK: - Error Display Methods

	/// Async version - shows an error with leading and accessory views
	@MainActor static func show<Accessory: View, Leading: View>(_ error: Error?, level: ErrorLevel = .standard, title: String? = nil, localized: LocalizedStringKey? = nil, file: StaticString = #file, function: StaticString = #function, line: UInt = #line, @ViewBuilder leading: @escaping () -> Leading, @ViewBuilder accessory: @escaping () -> Accessory) async {
		guard let error else { return }

		if level >= Achtung.instance.configuration.errorDisplayLevel {
			let toast = Toast(title ?? "An error occurred", localized: localized, message: nil, error: error, file: file, function: function, line: line, leading: leading, accessory: accessory)
			await Achtung.instance.show(toast: toast)
		}
		print("⚠️ \(title ?? "Achtung") (\(fileDescription(file, function, line))): \(error.achtungDescription)")
	}

	/// Non-async wrapper
	static func show<Accessory: View, Leading: View>(_ error: Error?, level: ErrorLevel = .standard, title: String? = nil, localized: LocalizedStringKey? = nil, file: StaticString = #file, function: StaticString = #function, line: UInt = #line, @ViewBuilder leading: @escaping () -> Leading, @ViewBuilder accessory: @escaping () -> Accessory) {
		Task { @MainActor in
			await show(error, level: level, title: title, localized: localized, file: file, function: function, line: line, leading: leading, accessory: accessory)
		}
	}

	/// Async version - shows error with accessory view
	@MainActor static func show<Accessory: View>(_ error: Error?, level: ErrorLevel = .standard, title: LocalizedStringKey? = nil, file: StaticString = #file, function: StaticString = #function, line: UInt = #line, @ViewBuilder accessory: @escaping () -> Accessory) async {
		await show(error, level: level, file: file, function: function, line: line, leading: { EmptyView() }, accessory: accessory)
	}

	/// Non-async wrapper
	static func show<Accessory: View>(_ error: Error?, level: ErrorLevel = .standard, title: LocalizedStringKey? = nil, file: StaticString = #file, function: StaticString = #function, line: UInt = #line, @ViewBuilder accessory: @escaping () -> Accessory) {
		Task { @MainActor in
			await show(error, level: level, title: title, file: file, function: function, line: line, accessory: accessory)
		}
	}

	/// Async version - shows error with leading view
	@MainActor static func show<Leading: View>(_ error: Error?, level: ErrorLevel = .standard, title: LocalizedStringKey? = nil, file: StaticString = #file, function: StaticString = #function, line: UInt = #line, @ViewBuilder leading: @escaping () -> Leading) async {
		await show(error, level: level, file: file, function: function, line: line, leading: leading, accessory: { EmptyView() })
	}

	/// Non-async wrapper
	static func show<Leading: View>(_ error: Error?, level: ErrorLevel = .standard, title: LocalizedStringKey? = nil, file: StaticString = #file, function: StaticString = #function, line: UInt = #line, @ViewBuilder leading: @escaping () -> Leading) {
		Task { @MainActor in
			await show(error, level: level, title: title, file: file, function: function, line: line, leading: leading)
		}
	}

	/// Async version - shows error with String title
	nonisolated static func show(_ error: Error?, level: ErrorLevel = .standard, title: String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) async {
		await show(error, level: level, title: title, file: file, function: function, line: line, leading: { EmptyView() }, accessory: { EmptyView() })
	}

	/// Non-async wrapper
	nonisolated static func show(_ error: Error?, level: ErrorLevel = .standard, title: String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
		Task { @MainActor in
			await show(error, level: level, title: title, file: file, function: function, line: line)
		}
	}

	/// Async version - shows error with LocalizedStringKey title
	nonisolated static func show(_ error: Error?, level: ErrorLevel = .standard, title: LocalizedStringKey? = nil, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) async {
		await show(error, level: level, file: file, function: function, line: line, leading: { EmptyView() }, accessory: { EmptyView() })
	}

	/// Non-async wrapper
	nonisolated static func show(_ error: Error?, level: ErrorLevel = .standard, title: LocalizedStringKey? = nil, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
		Task { @MainActor in
			await show(error, level: level, title: title, file: file, function: function, line: line)
		}
	}

	// MARK: - Do Method (Error Handling Wrapper)

	/// Async do - handles synchronous throwing blocks
	@MainActor static func `do`(level: ErrorLevel = .testing, title: LocalizedStringKey? = nil, file: StaticString = #file, function: StaticString = #function, line: UInt = #line, _ block: () throws -> Void) async {
		do {
			try block()
		} catch {
			await recordError(error, title: title, file: String(describing: file), function: String(describing: function), line: Int(line))
			await show(error, level: level, title: title, file: file, function: function, line: line)
		}
	}

	/// Non-async wrapper - handles synchronous throwing blocks
	nonisolated static func `do`(level: ErrorLevel = .testing, title: LocalizedStringKey? = nil, file: StaticString = #file, function: StaticString = #function, line: UInt = #line, _ block: @escaping () throws -> Void) {
		Task { @MainActor in
			await `do`(level: level, title: title, file: file, function: function, line: line, block)
		}
	}

	/// Async do - handles asynchronous throwing blocks
	nonisolated static func `do`(level: ErrorLevel = .testing, title: LocalizedStringKey? = nil, file: StaticString = #file, function: StaticString = #function, line: UInt = #line, _ block: @escaping () async throws -> Void) async {
		do {
			try await block()
		} catch {
			await recordError(error, title: title, file: String(describing: file), function: String(describing: function), line: Int(line))
			await show(error, level: level, title: title, file: file, function: function, line: line)
		}
	}

	/// Non-async wrapper - handles asynchronous throwing blocks
	nonisolated static func `do`(level: ErrorLevel = .testing, title: LocalizedStringKey? = nil, file: StaticString = #file, function: StaticString = #function, line: UInt = #line, _ block: @escaping () async throws -> Void) {
		Task { @MainActor in
			await `do`(level: level, title: title, file: file, function: function, line: line, block)
		}
	}
}
#else
public extension Achtung {
	nonisolated static func show(_ error: Error?, level: ErrorLevel = .standard, title: LocalizedStringKey? = nil, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) async {
		guard let error else { return }

		print("⚠️ \(title ?? "") (\(fileDescription(file, function, line))): \(error)")
	}

	@MainActor static func show(_ error: Error?, level: ErrorLevel = .standard, title: LocalizedStringKey? = nil, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
		guard let error else { return }

		print("⚠️ \(title ?? "") (\(fileDescription(file, function, line))): \(error)")
	}

	static func `do`(level: ErrorLevel = .testing, message: String? = nil, file: StaticString = #file, function: StaticString = #function, line: UInt = #line, _ block: () throws -> Void) {
		do {
			try block()
		} catch {
			print("\(message ?? "") (\(fileDescription(file, function, line))): \(error)")
		}
	}
	
	static func `do`(level: ErrorLevel = .testing, message: String? = nil, file: StaticString = #file, function: StaticString = #function, line: UInt = #line, _ block: @escaping () async throws -> Void) {
		Task {
			do {
				try await block()
			} catch {
				print("\(message ?? "") (\(fileDescription(file, function, line))): \(error)")
			}
		}
	}
}
#endif
