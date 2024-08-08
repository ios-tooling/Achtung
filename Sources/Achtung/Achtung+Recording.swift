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
	}
	
	nonisolated static func recordError(_ error: Error, title: LocalizedStringKey?) {
		Task { @MainActor in
			Achtung.instance._recordError(error, title: title)
		}
	}
	
	func _recordError(_ error: Error, title: LocalizedStringKey?) {
		print("⛔️\(title ?? ""): \(error.localizedDescription)")
		recordedErrors.append(.init(error: error, title: title))
		while recordedErrors.count > recordedErrorLimit {
			recordedErrors.removeFirst()
		}
	}
	
	func clearRecord() {
		recordedErrors = []
	}
}
