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
	
	public func show(toast: Toast) {
		if !isSetup() { return }

		DispatchQueue.main.async {
			self.toasts.append(toast)
			if self.nextToastTimer == nil { self.showNextToast() }
		}
	}

    public func show(title: String, error: Error, buttons: [Achtung.Button]? = nil) {
        show(title: Text(title), message: Text(error.localizedDescription), buttons: buttons ?? [.ok()])
    }

    
	public func show(title: Text? = nil, message: Text? = nil, fieldText: Binding<String>? = nil, fieldPlaceholder: String = "", tag: String? = nil, buttons: [Achtung.Button]) {
		guard title != nil || message != nil || buttons.isEmpty == false else { return }
		if let tag = tag, pendingAlerts.first(where: { $0.tag == tag }) != nil { return }

		let alert = Achtung.Alert(title: title, message: message, fieldText: fieldText, fieldPlaceholder: fieldPlaceholder, tag: tag, buttons: buttons)
		DispatchQueue.main.async {
			if self.pendingAlerts.isEmpty {
				withAnimation() {
					self.pendingAlerts.append(alert)
				}
			} else {
				self.pendingAlerts.append(alert)
			}
		}
	}
	
	func remove(_ pending: Achtung.Alert) {
		if let index = self.pendingAlerts.firstIndex(of: pending) {
			_ = withAnimation() {
				self.pendingAlerts.remove(at: index)
			}
		}
	}

	
	public struct Button: Identifiable {
		public enum Kind { case normal, cancel, destructive }
		public let id: String = UUID().uuidString
		public let label: Text
		public let kind: Kind
		public let action: (() -> Void)?
		
		func pressed() {
			self.action?()
		}
		
		public static func `default`(_ label: Text, action: (() -> Void)? = {}) -> Button {
			Button(label: label, kind: .normal, action: action)
		}
		
        public static func ok(_ label: Text = Text("OK"), action: (() -> Void)? = {}) -> Button {
            Button(label: label, kind: .normal, action: action)
        }
        
        public static func cancel(_ label: Text = Text("Cancel"), action: (() -> Void)? = {}) -> Button {
            Button(label: label, kind: .cancel, action: action)
        }
        
		public static func destructive(_ label: Text, _ action: (() -> Void)? = {}) -> Button {
			Button(label: label, kind: .destructive, action: action)
		}
		
	}
}

@available(OSX 10.15, iOS 13.0, *)
extension View {
	public func achtung(title: Text? = nil, message: Text? = nil, tag: String? = nil, buttons: [Achtung.Button]) {
		Achtung.instance.show(title: title, message: message, tag: tag, buttons: buttons)
	}
}

#endif
