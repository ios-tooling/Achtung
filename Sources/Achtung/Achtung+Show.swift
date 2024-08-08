//
//  Achtung+Show.swift
//  
//
//  Created by ben on 8/13/20.
//

#if canImport(Combine)

import SwiftUI
import Combine

@available(OSX 10.15, iOS 13.0, *)
extension Achtung {
	nonisolated static public func show(toast: Toast) {
		Task { @MainActor in
			Achtung.instance.show(toast: toast)
		}
	}
	
	nonisolated public func show(toast: Toast) {
		Task { @MainActor in
			if isSettingUp {
				try? await Task.sleep(nanoseconds: 500_000_000)
			}
			if !isSetup { return }
			toasts.append(toast)
			if nextToastTimer == nil { showNextToast() }
		}
	}

	public static func show(title: String, error: Error, foreground: Color? = nil, border: Color? = nil, background: Color? = nil, tapOutsideToDismiss: Bool = false, buttons: [Achtung.Button]? = nil) {
		show(title: Text(title), message: Text(error.achtungDescription), foreground: foreground, border: border, background: background, tapOutsideToDismiss: tapOutsideToDismiss, buttons: buttons ?? [.ok()])
	}

	public static func show(title: String, message: String? = nil, foreground: Color? = nil, border: Color? = nil, background: Color? = nil, tapOutsideToDismiss: Bool = false, buttons: [Achtung.Button]? = nil) {
		show(title: Text(title), message: message == nil ? nil : Text(message!), foreground: foreground, border: border, background: background, tapOutsideToDismiss: tapOutsideToDismiss, buttons: buttons ?? [.ok()])
	}


	public static func show(title: Text? = nil, message: Text? = nil, fieldText: Binding<String>? = nil, fieldPlaceholder: String = "", tag: String? = nil, foreground: Color? = nil, border: Color? = nil, background: Color? = nil, tapOutsideToDismiss: Bool = false, buttons: [Achtung.Button]) {
		guard title != nil || message != nil || buttons.isEmpty == false else { return }
		
		Task { @MainActor in
			if let tag = tag, instance.pendingAlerts.first(where: { $0.tag == tag }) != nil { return }
			
			let alert = Achtung.Alert(title: title, message: message, fieldText: fieldText, fieldPlaceholder: fieldPlaceholder, tag: tag, foreground: foreground, border: border, background: background, tapOutsideToDismiss: tapOutsideToDismiss, buttons: buttons)
			Task {
				await MainActor.run {
					if instance.pendingAlerts.isEmpty {
						withAnimation(.linear(duration: Achtung.showAlertDuration)) {
							instance.pendingAlerts.append(alert)
						}
					} else {
						instance.pendingAlerts.append(alert)
					}
					instance.hostWindow?.isEnabled = !instance.pendingAlerts.isEmpty
				}
			}
		}
	}
	
	func remove(_ pending: Achtung.Alert?) {
		guard let pending = pending ?? pendingAlerts.first else { return }
		if let index = self.pendingAlerts.firstIndex(of: pending) {
			withAnimation(.linear(duration: Achtung.hideAlertDuration)) {
				self.pendingAlerts.remove(at: index)
				hostWindow?.isEnabled = !pendingAlerts.isEmpty
			}
		}
	}

	
	public struct Button: Identifiable, Sendable {
		public enum Kind: Sendable { case normal, cancel, destructive }
		public let id: String = UUID().uuidString
		public let label: Text
		public let kind: Kind
		public let action: (@Sendable () -> Void)?
		
		func pressed() {
			self.action?()
		}
		
		public static func `default`(_ label: Text, action: (@Sendable () -> Void)? = {}) -> Button {
			Button(label: label, kind: .normal, action: action)
		}
		
        public static func ok(_ label: Text = Text("OK"), action: (@Sendable () -> Void)? = {}) -> Button {
            Button(label: label, kind: .normal, action: action)
        }
        
        public static func cancel(_ label: Text = Text("Cancel"), action: (@Sendable () -> Void)? = {}) -> Button {
            Button(label: label, kind: .cancel, action: action)
        }
        
		public static func destructive(_ label: Text, _ action: (@Sendable () -> Void)? = {}) -> Button {
			Button(label: label, kind: .destructive, action: action)
		}
		
	}
}

@available(OSX 10.15, iOS 13.0, *)
extension View {
	@MainActor public func achtung(title: Text? = nil, message: Text? = nil, tag: String? = nil, buttons: [Achtung.Button]) {
		Achtung.instance.show(title: title, message: message, tag: tag, buttons: buttons)
	}
}

#endif
