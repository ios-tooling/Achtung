//
//  Achtung+Recording.swift
//
//
//  Created by Ben Gottlieb on 4/23/24.
//

import Foundation

public extension Achtung {
	enum ErrorFilterResult { case ignore, log, display, replace(Error) }
	struct RecordedError: Identifiable {
		public let id = UUID()
		public let error: Error
		public let message: String?
	}
    
    nonisolated static func recordError(_ error: Error, message: String?) {
        Task { @MainActor in
            Achtung.instance._recordError(error, message: message)
        }
    }
	
	func _recordError(_ error: Error, message: String?) {
        print("⛔️\(message ?? ""): \(error.localizedDescription)")
		recordedErrors.append(.init(error: error, message: message))
		while recordedErrors.count > recordedErrorLimit {
			recordedErrors.removeFirst()
		}
	}
	
	func clearRecord() {
		recordedErrors = []
	}
}
