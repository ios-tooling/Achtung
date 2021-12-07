//
//  Achtung.Toast.swift
//  
//
//  Created by Ben Gottlieb on 12/7/21.
//

import SwiftUI

public extension Achtung {
	struct Toast {
		static let onScreenTime: TimeInterval = 4
		static let showDuration: TimeInterval = 0.5
		static let hideDuration: TimeInterval = 0.4

		public var title: String
		public var body: String?
		public var error: Error?
		
		public var duration: TimeInterval
		
		public var backgroundColor = Color.black
		public var textColor = Color.white
		public var borderColor = Color.white
		public var borderWidth: CGFloat = 2
		public var cornerRadius: CGFloat = 8
		public var titleFont = Font.system(size: 14, weight: .semibold)
		
		
		public init(title: String, body: String? = nil, error: Error? = nil, duration: TimeInterval? = nil) {
			self.title = title
			self.duration = duration ?? Achtung.Toast.onScreenTime
			self.body = error?.localizedDescription ?? body
			self.error = error
		}
		
		static let sample = Achtung.Toast(title: "Look at me!")
	}
}
