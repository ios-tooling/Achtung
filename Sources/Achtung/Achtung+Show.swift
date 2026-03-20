//
//  Achtung+Show.swift
//  
//
//  Created by ben on 8/13/20.
//

#if canImport(Combine)

import SwiftUI
import Combine

@available(macOS 10.15, iOS 13.0, *)
extension Achtung {
	// MARK: - Toast Methods

	/// Async version - shows a toast notification
	@MainActor public func show(toast: Toast) async {
		if let lastToast, lastToast.isEqual(to: toast), let lastToastTime, abs(lastToastTime.timeIntervalSinceNow) < configuration.duplicateToastTimeOut { return }
		
		lastToast = toast
		lastToastTime = Date()
		if let error = toast.error {
			await _recordError(error, title: toast.title)
		}
		if #available(iOS 16.0, macOS 13, *) {
			if toast.nativity == .native, await AchtungNotifications.instance.isAuthorized {
				await AchtungNotifications.instance.show(toast: toast)
				return
			}
		}

		if isSettingUp {
			try? await Task.sleep(nanoseconds: 500_000_000)
		}
		if !isSetup { return }
		toasts.append(toast)
		if nextToastTimer == nil { showNextToast() }
	}

	/// Non-async wrapper for instance method
	nonisolated public func show(toast: Toast) {
		Task { @MainActor in
			await show(toast: toast)
		}
	}

	/// Non-async wrapper for static method
	nonisolated static public func show(toast: Toast) {
		Task { @MainActor in
			await instance.show(toast: toast)
		}
	}

	// MARK: - Alert Methods

	/// Async version - shows an alert
	@MainActor public func show(alert: Achtung.Alert) async {
		if isSettingUp {
			try? await Task.sleep(nanoseconds: 500_000_000)
		}
		if !isSetup { return }
		if pendingAlerts.isEmpty {
			withAnimation(.linear(duration: Achtung.showAlertDuration)) {
				pendingAlerts.append(alert)
			}
		} else if let tag = alert.tag {
			if !pendingAlerts.contains(where: { $0.tag == tag }) {
				pendingAlerts.append(alert)
			}
		} else {
			pendingAlerts.append(alert)
		}
	}

	/// Non-async wrapper for instance method
	nonisolated public func show(alert: Achtung.Alert) {
		Task { @MainActor in
			await show(alert: alert)
		}
	}

	/// Non-async wrapper for static method
	nonisolated static public func show(alert: Achtung.Alert) {
		Task { @MainActor in
			await instance.show(alert: alert)
		}
	}

	// MARK: - Convenience Alert Methods

	/// Async version - shows an alert with title, message, and buttons
	@MainActor public static func show(title: Text? = nil, message: Text? = nil, fieldText: Binding<String>? = nil, fieldPlaceholder: String = "", tag: String? = nil, foreground: Color? = nil, border: Color? = nil, background: Color? = nil, tapOutsideToDismiss: Bool = false, buttons: [Achtung.Button]) async {
		guard title != nil || message != nil || buttons.isEmpty == false else { return }

		if let tag, instance.pendingAlerts.first(where: { $0.tag == tag }) != nil { return }

		let alert = Achtung.Alert(text: title, message: message, fieldText: fieldText, fieldPlaceholder: fieldPlaceholder, tag: tag, foreground: foreground, border: border, background: background, tapOutsideToDismiss: tapOutsideToDismiss, buttons: buttons)
		await instance.show(alert: alert)
	}

	/// Non-async wrapper
	public static func show(title: Text? = nil, message: Text? = nil, fieldText: Binding<String>? = nil, fieldPlaceholder: String = "", tag: String? = nil, foreground: Color? = nil, border: Color? = nil, background: Color? = nil, tapOutsideToDismiss: Bool = false, buttons: [Achtung.Button]) {
		Task { @MainActor in
			await show(title: title, message: message, fieldText: fieldText, fieldPlaceholder: fieldPlaceholder, tag: tag, foreground: foreground, border: border, background: background, tapOutsideToDismiss: tapOutsideToDismiss, buttons: buttons)
		}
	}

	/// Async version - shows an alert with String title and message
	@MainActor public static func show(title: String, message: String? = nil, foreground: Color? = nil, border: Color? = nil, background: Color? = nil, tapOutsideToDismiss: Bool = false, buttons: [Achtung.Button]? = nil) async {
		await show(title: Text(title), message: message == nil ? nil : Text(message!), foreground: foreground, border: border, background: background, tapOutsideToDismiss: tapOutsideToDismiss, buttons: buttons ?? [.ok()])
	}

	/// Non-async wrapper
	public static func show(title: String, message: String? = nil, foreground: Color? = nil, border: Color? = nil, background: Color? = nil, tapOutsideToDismiss: Bool = false, buttons: [Achtung.Button]? = nil) {
		Task { @MainActor in
			await show(title: title, message: message, foreground: foreground, border: border, background: background, tapOutsideToDismiss: tapOutsideToDismiss, buttons: buttons)
		}
	}

	/// Async version - shows an alert with error
	@MainActor public static func show(title: String, error: Error, foreground: Color? = nil, border: Color? = nil, background: Color? = nil, tapOutsideToDismiss: Bool = false, buttons: [Achtung.Button]? = nil) async {
		await show(title: Text(title), message: Text(error.achtungDescription), foreground: foreground, border: border, background: background, tapOutsideToDismiss: tapOutsideToDismiss, buttons: buttons ?? [.ok()])
	}

	/// Non-async wrapper
	public static func show(title: String, error: Error, foreground: Color? = nil, border: Color? = nil, background: Color? = nil, tapOutsideToDismiss: Bool = false, buttons: [Achtung.Button]? = nil) {
		Task { @MainActor in
			await show(title: title, error: error, foreground: foreground, border: border, background: background, tapOutsideToDismiss: tapOutsideToDismiss, buttons: buttons)
		}
	}
	
	func remove(_ pending: Achtung.Alert?) {
		guard let pending = pending ?? pendingAlerts.first else { return }
		if let index = self.pendingAlerts.firstIndex(of: pending) {
			withAnimation(.linear(duration: Achtung.hideAlertDuration)) {
				self.pendingAlerts.remove(at: index)
				return
			}
		}
	}

	
	public struct Button: Identifiable, Sendable {
		public enum Kind: Sendable { case normal, cancel, destructive }
		public let id: String = UUID().uuidString
		public let label: Text
		public let kind: Kind
		public let action: (@MainActor @Sendable () -> Void)?
		
		@MainActor func pressed() {
			self.action?()
		}
		
		public static func `default`(_ label: Text, action: (@MainActor @Sendable () -> Void)? = {}) -> Button {
			Button(label: label, kind: .normal, action: action)
		}
		
        public static func ok(_ label: Text = Text("OK"), action: (@MainActor @Sendable () -> Void)? = {}) -> Button {
            Button(label: label, kind: .normal, action: action)
        }
        
        public static func cancel(_ label: Text = Text("Cancel"), action: (@MainActor @Sendable () -> Void)? = {}) -> Button {
            Button(label: label, kind: .cancel, action: action)
        }
        
		public static func destructive(_ label: Text, _ action: (@MainActor @Sendable () -> Void)? = {}) -> Button {
			Button(label: label, kind: .destructive, action: action)
		}
		
	}
}

extension View {
	@ViewBuilder func styled(for button: Achtung.Button) -> some View {
		switch button.kind {
		case .cancel:
			self
			
		case .destructive:
			self
				.foregroundColor(.red)
			
		case .normal:
			
			if #available(iOS 16.0, macOS 13, *) {
				self
					.bold()
			} else {
				self
			}
		}
	}
}

@available(macOS 10.15, iOS 13.0, *)
extension View {
	@MainActor public func achtung(title: Text? = nil, message: Text? = nil, tag: String? = nil, buttons: [Achtung.Button]) {
		Achtung.show(title: title, message: message, tag: tag, buttons: buttons)
	}
}

#endif
