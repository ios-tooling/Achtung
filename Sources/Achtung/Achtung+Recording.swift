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
	}
	
	nonisolated static func recordError(_ error: Error, title: LocalizedStringKey? = nil, message: String? = nil) {
		Task { @MainActor in
			Achtung.instance._recordError(error, title: title, message: message)
		}
	}
	
	func _recordError(_ error: Error, title: LocalizedStringKey?, message: String?) {
		print("⛔️\(title ?? "") \(message ?? "") : \(error.localizedDescription)")
		recordedErrors.append(.init(error: error, title: title, message: message))
		while recordedErrors.count > recordedErrorLimit {
			recordedErrors.removeFirst()
		}
	}
	
	func clearRecord() {
		recordedErrors = []
	}
}
