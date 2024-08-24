//
//  Achtung.Toast.swift
//  
//
//  Created by Ben Gottlieb on 12/7/21.
//

import SwiftUI

extension AnyView: @unchecked Sendable { }
extension LocalizedStringKey: @unchecked Sendable { }

public extension Achtung {
	static nonisolated let onScreenTime: TimeInterval = 8
	static nonisolated let longOnScreenTime: TimeInterval = 12
	static nonisolated let showToastDuration: TimeInterval = 0.5
	static nonisolated let hideToastDuration: TimeInterval = 0.4
	static nonisolated let showAlertDuration: TimeInterval = 0.2
	static nonisolated let hideAlertDuration: TimeInterval = 0.2

	struct Toast: Sendable {
		public var title: String?
		public var localizedTitle: LocalizedStringKey?
		public var message: String?
		public var error: Error?
		public let leading: (any Sendable)?
		
		public var duration: TimeInterval
		
		public var foregroundColor: Color?
		public var borderColor: Color?
		public var backgroundColor: Color?
		public var borderWidth: CGFloat = 2
		public var cornerRadius: CGFloat = 8
		public var titleFont = Font.system(size: 18, weight: .semibold)
		public var messageFont = Font.system(size: 16, weight: .regular)
		public var tapAction: (@Sendable () -> Void)?
		public var accessoryView: (any Sendable)?
		
		@MainActor public init<Leading: View>(_ title: String? = nil, localized: LocalizedStringKey? = nil, message: String? = nil, error: Error? = nil, duration: TimeInterval? = nil, foreground: Color? = nil, border: Color? = nil, background: Color? = nil, @ViewBuilder leadingView: @escaping () -> Leading, tapAction: (@Sendable () -> Void)? = nil) {
			self.init(title, localized: localized, message: message, error: error, duration: duration, foreground: foreground, border: border, background: background, leading: { AnyView(leadingView()) }, accessory: { EmptyView() }, tapAction: tapAction)
		}
		
		@MainActor public init<Accessory: View>(_ title: String? = nil, localized: LocalizedStringKey? = nil, message: String? = nil, error: Error? = nil, duration: TimeInterval? = nil, foreground: Color? = nil, border: Color? = nil, background: Color? = nil, @ViewBuilder accessory: @escaping  () -> Accessory, tapAction: (@Sendable () -> Void)? = nil) {
			self.init(title, localized: localized, message: message, error: error, duration: duration, foreground: foreground, border: border, background: background, leading: { EmptyView() }, accessory: { AnyView(accessory()) }, tapAction: tapAction)
		}
		
		@MainActor public init<Leading: View, Accessory: View>(_ title: String? = nil, localized: LocalizedStringKey? = nil, message: String? = nil, error: Error? = nil, duration: TimeInterval? = nil, foreground: Color? = nil, border: Color? = nil, background: Color? = nil, @ViewBuilder leading: @escaping () -> Leading, @ViewBuilder accessory: @escaping () -> Accessory, tapAction: (@Sendable () -> Void)? = nil) {
			self.init(title, localized: localized, message: message, error: error, duration: duration, foreground: foreground, border: border, background: background, leadingView: AnyView(leading()), accessoryView: AnyView(accessory()), tapAction: tapAction)
		}

		public init(_ title: String? = nil, localized: LocalizedStringKey? = nil, message: String? = nil, error: Error? = nil, duration: TimeInterval? = nil, foreground: Color? = nil, border: Color? = nil, background: Color? = nil, tapAction: (@Sendable () -> Void)? = nil) {
			self.init(title, localized: localized, message: message, error: error, duration: duration, foreground: foreground, border: border, background: background, leadingView: nil, accessoryView: nil, tapAction: tapAction)
		}

		public init(_ title: String? = nil, localized: LocalizedStringKey? = nil, message: String? = nil, error: Error? = nil, duration: TimeInterval? = nil, foreground: Color? = nil, border: Color? = nil, background: Color? = nil, leadingView: (any Sendable)?, accessoryView: (any Sendable)?, tapAction: (@Sendable () -> Void)? = nil) {
			self.title = title
			self.localizedTitle = localized
			self.duration = duration ?? ((message == nil || title == nil) ? Achtung.onScreenTime : Achtung.longOnScreenTime)
			self.message = error?.achtungDescription ?? message
			self.error = error
			self.tapAction = tapAction
			self.foregroundColor = foreground
			self.borderColor = border
			self.backgroundColor = background
			if let leading = leadingView as? AnyView {
				self.leading = leading
			} else {
				self.leading = nil
			}

			if let accessory = accessoryView as? AnyView {
				self.accessoryView = accessory
			} else {
				self.accessoryView = nil
			}
		}

		@MainActor static let sample = Achtung.Toast("Look at me!")
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
