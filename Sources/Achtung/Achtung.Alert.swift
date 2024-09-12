//
//  Achtung+Alert.swift
//  
//
//  Created by Ben Gottlieb on 12/6/21.
//

#if canImport(Combine)
import SwiftUI
import Combine

@available(OSX 10.15, iOS 13.0, *)
extension Achtung {
	public struct Alert: Identifiable, Equatable, Sendable {
		public let id = UUID()
		var tag: String?
		var title: Text?
		var message: Text?
		let buttons: [Achtung.Button]
		let fieldInfo: FieldInfo?
		let foregroundColor: Color?
		let backgroundColor: Color?
		let borderColor: Color?
		let tapOutsideToDismiss: Bool
		
		@MainActor func buttonPressed() {
			Achtung.instance.remove(self)
		}
		
		public struct FieldInfo: Sendable {
			let text: Binding<String>
			let limit: Int?
			let placeholder: String
			
			public init(text: Binding<String>, limit: Int? = nil, placeholder: String = "") {
				self.text = text
				self.limit = limit
				self.placeholder = placeholder
			}
		}
		
		public init(_ title: String? = nil, text: Text? = nil, message: Text? = nil, fieldText: Binding<String>? = nil, fieldInfo: FieldInfo? = nil, fieldPlaceholder: String = "", tag: String? = nil, foreground: Color? = nil, border: Color? = nil, background: Color? = nil, tapOutsideToDismiss: Bool = false, buttons: [Achtung.Button]) {
			self.title = Text(text, title)
			self.message = message
			self.tag = tag
			self.buttons = buttons
			if let fieldText {
				self.fieldInfo = .init(text: fieldText, limit: nil, placeholder: fieldPlaceholder)
			} else {
				self.fieldInfo = fieldInfo
			}
			self.foregroundColor = foreground
			self.backgroundColor = background
			self.borderColor = border
			self.tapOutsideToDismiss = tapOutsideToDismiss
		}
		
		public init(_ title: String? = nil, text: Text? = nil, message: Text? = nil, fieldText: Binding<String>? = nil, fieldInfo: FieldInfo? = nil, fieldPlaceholder: String = "", tag: String? = nil, foreground: Color? = nil, border: Color? = nil, background: Color? = nil, tapOutsideToDismiss: Bool = false, primaryButton: Achtung.Button? = nil, secondaryButton: Achtung.Button? = nil, dismissButton: Achtung.Button? = nil) {
			self.title = Text(text, title)
			self.message = message
			self.tag = tag
			self.buttons = [primaryButton, secondaryButton, dismissButton].compactMap { $0 }
			if let fieldText {
				self.fieldInfo = .init(text: fieldText, limit: nil, placeholder: fieldPlaceholder)
			} else {
				self.fieldInfo = fieldInfo
			}
			self.foregroundColor = foreground
			self.backgroundColor = background
			self.borderColor = border
			self.tapOutsideToDismiss = tapOutsideToDismiss
		}
		
		public static func ==(lhs: Achtung.Alert, rhs: Achtung.Alert) -> Bool { lhs.id == rhs.id }
	}
}

extension Text {
	init?(_ text: Text?, _ string: String?) {
		if let text {
			self = text
		} else if let string {
			self.init(string)
		} else {
			return nil
		}
	}
}

#endif
