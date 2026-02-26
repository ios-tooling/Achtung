//
//  Achtung.Configuration.swift
//  StretchWordsHarness
//
//  Created by Ben Gottlieb on 2/26/26.
//

import SwiftUI

extension Achtung {
	public struct Configuration: Equatable {
		public var errorDisplayLevel = ErrorLevel.standard
		
		public init() { }
		
		public internal(set) var recordedErrors: [RecordedError] = []
		public var recordedErrorLimit = 10
		
		public var alertBackgroundColor = Color.black
		public var alertForegroundColor = Color.white
		public var alertBorderColor = Color.white.opacity(0.9)
		
		public var toastBackgroundColor = Color.black
		public var toastForegroundColor = Color.white
		public var toastBorderColor = Color.white.opacity(0.9)
		public var duplicateToastTimeOut = 0.0
		
		public var filterError: (Error) -> ErrorFilterResult = { _ in .display }
		
		public static func ==(lhs: Self, rhs: Self) -> Bool {
			if lhs.errorDisplayLevel != rhs.errorDisplayLevel { return false }

			if lhs.alertBorderColor != rhs.alertBorderColor { return false }
			if lhs.alertBackgroundColor != rhs.alertBackgroundColor { return false }
			if lhs.alertForegroundColor != rhs.alertForegroundColor { return false }
			if lhs.toastBackgroundColor != rhs.toastBackgroundColor { return false }
			if lhs.toastBorderColor != rhs.toastBorderColor { return false }
			if lhs.toastForegroundColor != rhs.toastForegroundColor { return false }
			if lhs.duplicateToastTimeOut != rhs.duplicateToastTimeOut { return false }
			
			return true
		}
	}
}

public extension Achtung.Configuration {
	static let halloween: Achtung.Configuration = {
		var config = Achtung.Configuration()

		config.alertBackgroundColor = .orange
		config.alertForegroundColor = .black
		config.alertBorderColor = .black

		config.toastBackgroundColor = .orange
		config.toastForegroundColor = .black
		config.toastBorderColor = .black
		
		return config
	}()
}
