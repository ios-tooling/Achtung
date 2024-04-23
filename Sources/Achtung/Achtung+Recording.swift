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
	
	func recordError(_ error: Error, message: String?) {
		recordedErrors.append(.init(error: error, message: message))
		while recordedErrors.count > recordedErrorLimit {
			recordedErrors.removeFirst()
		}
	}
	
	func clearRecord() {
		recordedErrors = []
	}
}
