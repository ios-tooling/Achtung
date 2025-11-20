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
	nonisolated static func `do`(level: ErrorLevel = .testing, title: LocalizedStringKey? = nil, file: StaticString = #file, function: StaticString = #function, line: UInt = #line, _ block: () throws -> Void) {
		do {
			try block()
		} catch {
			Task {
				show(error, level: level, title: title, file: file, function: function, line: line)
			}
		}
	}
	
	nonisolated static func `do`(level: ErrorLevel = .testing, title: LocalizedStringKey? = nil, file: StaticString = #file, function: StaticString = #function, line: UInt = #line, _ block: @escaping () async throws -> Void) {
		Task {
			do {
				try await block()
			} catch {
				show(error, level: level, title: title, file: file, function: function, line: line)
			}
		}
	}
	
	nonisolated static func show(_ error: Error?, level: ErrorLevel = .standard, title: LocalizedStringKey? = nil, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
		Task {
			await show(error, level: level, file: file, function: function, line: line, leading: { EmptyView() }, accessory: { EmptyView() })
		}
	}
	
	nonisolated static func show(_ error: Error?, level: ErrorLevel = .standard, title: String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
		Task {
			await show(error, level: level, title: title, file: file, function: function, line: line, leading: { EmptyView() }, accessory: { EmptyView() })
		}
	}
	
	static func show<Accessory: View>(_ error: Error?, level: ErrorLevel = .standard, title: LocalizedStringKey? = nil, file: StaticString = #file, function: StaticString = #function, line: UInt = #line, @ViewBuilder accessory: @escaping () -> Accessory) {
		show(error, level: level, file: file, function: function, line: line, leading: { EmptyView() }, accessory: accessory)
	}
	
	static func show<Leading: View>(_ error: Error?, level: ErrorLevel = .standard, title: LocalizedStringKey? = nil, file: StaticString = #file, function: StaticString = #function, line: UInt = #line, @ViewBuilder leading: @escaping () -> Leading) {
		show(error, level: level, file: file, function: function, line: line, leading: leading, accessory: { EmptyView() })
	}

	static func show<Accessory: View, Leading: View>(_ error: Error?, level: ErrorLevel = .standard, title: String? = nil, localized: LocalizedStringKey? = nil, file: StaticString = #file, function: StaticString = #function, line: UInt = #line, @ViewBuilder leading: @escaping () -> Leading, @ViewBuilder accessory: @escaping () -> Accessory) {
		guard let error else { return }
		
		if level >= Achtung.instance.errorDisplayLevel {
			let toast = Toast(title ?? "An error occurred", localized: localized, message: nil, error: error, file: file, function: function, line: line, leading: leading, accessory: accessory)
			Achtung.instance.show(toast: toast)
		}
		print("⚠️ \(title ?? "Achtung") (\(fileDescription(file, function, line))): \(error.achtungDescription)")
	}
}
#else
public extension Achtung {
	static func show(_ error: Error?, level: ErrorLevel = .standard, title: LocalizedStringKey? = nil, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
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
