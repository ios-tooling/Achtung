//
//  Achtung+Recording.swift
//
//
//  Created by Ben Gottlieb on 4/23/24.
//

import Foundation
import SwiftUI

public extension Achtung {
	enum ErrorFilterResult { case ignore, log, display, replace(Error) }
	struct RecordedError: Identifiable {
		public let id = UUID()
		public let error: Error
		public let title: LocalizedStringKey?
		public let message: String?
		public var date: Date?
		public var file: String?
		public var function: String?
		public var line: Int?
	}
	
	/// Async version - records an error
	@MainActor static func recordError(_ error: Error, title: LocalizedStringKey? = nil, message: String? = nil, date: Date = Date(), file: String = #file, function: String = #function, line: Int = #line) async {
		await Achtung.instance._recordError(error, title: title, message: message, date: date, file: file, function: function, line: line)
	}

	/// Non-async wrapper
	static func recordError(_ error: Error, title: LocalizedStringKey? = nil, message: String? = nil, date: Date = Date(), file: String = #file, function: String = #function, line: Int = #line) {
		Task { @MainActor in
			await recordError(error, title: title, message: message, date: date, file: file, function: function, line: line)
		}
	}

	/// Async version - internal recording implementation
	@MainActor func _recordError(_ error: Error, title: LocalizedStringKey? = nil, message: String? = nil, date: Date = Date(), file: String = #file, function: String = #function, line: Int = #line) async {
		print("⛔️\(title ?? "") \(message ?? "") : \(error.decodingDescription ?? error.localizedDescription)")
		recordedErrors.append(.init(error: error, title: title, message: message, date: date, file: file, function: function, line: line))
		while recordedErrors.count > configuration.recordedErrorLimit {
			recordedErrors.removeFirst()
		}
	}

	/// Non-async wrapper for internal method
	func _recordError(_ error: Error, title: LocalizedStringKey? = nil, message: String? = nil, date: Date = Date(), file: String = #file, function: String = #function, line: Int = #line) {
		Task { @MainActor in
			await _recordError(error, title: title, message: message, date: date, file: file, function: function, line: line)
		}
	}
	
	func clearRecord() {
		recordedErrors = []
	}
}
