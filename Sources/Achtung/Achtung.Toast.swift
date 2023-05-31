//
//  Achtung.Toast.swift
//  
//
//  Created by Ben Gottlieb on 12/7/21.
//

#if os(iOS)

import SwiftUI

public extension Achtung {
	static let onScreenTime: TimeInterval = 4
	static let showDuration: TimeInterval = 0.5
	static let hideDuration: TimeInterval = 0.4

	struct Toast {

		public var title: String
		public var body: String?
		public var error: Error?
		public let leading: AnyView?
		
		public var duration: TimeInterval
		
		public var backgroundColor = Color.black
		public var textColor = Color.white
		public var borderColor = Color.white
		public var borderWidth: CGFloat = 2
		public var cornerRadius: CGFloat = 8
		public var titleFont = Font.system(size: 14, weight: .semibold)
		public var bodyFont = Font.system(size: 12, weight: .regular)
		public var tapAction: (() -> Void)?
		
		
		public init<Leading: View>(title: String, body: String? = nil, error: Error? = nil, duration: TimeInterval? = nil, leadingView: () -> Leading, tapAction: (() -> Void)? = nil) {
			self.init(title: title, body: body, error: error, duration: duration, leading: AnyView(leadingView()), tapAction: tapAction)
		}
		
		public init(title: String, body: String? = nil, error: Error? = nil, duration: TimeInterval? = nil, tapAction: (() -> Void)? = nil) {
			self.init(title: title, body: body, error: error, duration: duration, leading: nil, tapAction: tapAction)
		}
		
		public init(title: String, body: String? = nil, error: Error? = nil, duration: TimeInterval? = nil, leading: AnyView?, tapAction: (() -> Void)? = nil) {
			self.title = title
			self.duration = duration ?? Achtung.onScreenTime
			self.body = error?.localizedDescription ?? body
			self.error = error
			self.leading = leading
			self.tapAction = tapAction
		}
		
		static let sample = Achtung.Toast(title: "Look at me!")
	}
}
#endif
