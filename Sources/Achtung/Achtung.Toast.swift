//
//  Achtung.Toast.swift
//  
//
//  Created by Ben Gottlieb on 12/7/21.
//

import SwiftUI

extension AnyView: @unchecked Sendable { }

public extension Achtung {
	static let onScreenTime: TimeInterval = 8
	static let longOnScreenTime: TimeInterval = 12
	static let showDuration: TimeInterval = 0.5
	static let hideDuration: TimeInterval = 0.4

	struct Toast: Sendable {

		public var title: String
		public var body: String?
		public var error: Error?
		public let leading: AnyView?
		
		public var duration: TimeInterval
		
		public var foregroundColor: Color?
		public var borderColor: Color?
		public var backgroundColor: Color?
		public var borderWidth: CGFloat = 2
		public var cornerRadius: CGFloat = 8
		public var titleFont = Font.system(size: 18, weight: .semibold)
		public var bodyFont = Font.system(size: 16, weight: .regular)
		public var tapAction: (@Sendable () -> Void)?
		public var accessoryView: AnyView?
		
		
		@MainActor public init<Leading: View>(title: String, body: String? = nil, error: Error? = nil, duration: TimeInterval? = nil, foreground: Color? = nil, border: Color? = nil, background: Color? = nil, @ViewBuilder leadingView: () -> Leading, tapAction: (@Sendable () -> Void)? = nil) {
			self.init(title: title, body: body, error: error, duration: duration, foreground: foreground, border: border, background: background, leading: AnyView(leadingView()), accessory: nil, tapAction: tapAction)
		}
		
		@MainActor public init<Accessory: View>(title: String, body: String? = nil, error: Error? = nil, duration: TimeInterval? = nil, foreground: Color? = nil, border: Color? = nil, background: Color? = nil, @ViewBuilder accessory: () -> Accessory, tapAction: (@Sendable () -> Void)? = nil) {
			self.init(title: title, body: body, error: error, duration: duration, foreground: foreground, border: border, background: background, leading: nil, accessory: AnyView(accessory()), tapAction: tapAction)
		}
		
		@MainActor public init(title: String, body: String? = nil, error: Error? = nil, duration: TimeInterval? = nil, foreground: Color? = nil, border: Color? = nil, background: Color? = nil, tapAction: (@Sendable () -> Void)? = nil) {
			self.init(title: title, body: body, error: error, duration: duration, foreground: foreground, border: border, background: background, leading: nil, accessory: nil, tapAction: tapAction)
		}
		
		@MainActor public init(title: String, body: String? = nil, error: Error? = nil, duration: TimeInterval? = nil, foreground: Color? = nil, border: Color? = nil, background: Color? = nil, leading: AnyView?, accessory: AnyView?, tapAction: (@Sendable () -> Void)? = nil) {
			self.title = title
			self.duration = duration ?? (body == nil ? Achtung.onScreenTime : Achtung.longOnScreenTime)
			self.body = error?.achtungDescription ?? body
			self.error = error
			self.leading = leading
			self.tapAction = tapAction
			self.foregroundColor = foreground
			self.borderColor = border
			self.backgroundColor = background
			self.accessoryView = accessory
		}
		
		@MainActor static let sample = Achtung.Toast(title: "Look at me!")
	}
}

extension Error {
	var achtungDescription: String {
		let localized = localizedDescription
		if !localized.contains("error 0.)") { return localized }
		
		let debug = (self as CustomDebugStringConvertible).debugDescription
		return debug.components(separatedBy: ".").joined(separator: ", ")
	}
}
