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
	
	nonisolated static func recordError(_ error: Error, title: LocalizedStringKey? = nil, message: String? = nil, date: Date = Date(), file: String = #file, function: String = #function, line: Int = #line) {
		Task { @MainActor in
			Achtung.instance._recordError(error, title: title, message: message, date: date, file: file, function: function, line: line)
		}
	}
	
	func _recordError(_ error: Error, title: LocalizedStringKey?, message: String?, date: Date = Date(), file: String = #file, function: String = #function, line: Int = #line) {
		print("⛔️\(title ?? "") \(message ?? "") : \(error.localizedDescription)")
		recordedErrors.append(.init(error: error, title: title, message: message, date: date, file: file, function: function, line: line))
		while recordedErrors.count > recordedErrorLimit {
			recordedErrors.removeFirst()
		}
	}
	
	func clearRecord() {
		recordedErrors = []
	}
}
