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
	public struct Alert: Identifiable, Equatable {
		public let id = UUID()
		var tag: String?
		var title: Text?
		var message: Text?
		let buttons: [Achtung.Button]
		 let fieldText: Binding<String>?
		 let fieldPlaceholder: String
		
		func buttonPressed() {
			Achtung.instance.remove(self)
		}
		
		 public init(title: Text? = nil, message: Text? = nil, fieldText: Binding<String>? = nil, fieldPlaceholder: String = "", tag: String? = nil, buttons: [Achtung.Button]) {
			self.title = title
			self.message = message
			self.tag = tag
			self.buttons = buttons
			  self.fieldText = fieldText
			  self.fieldPlaceholder = fieldPlaceholder
		}

		public init(title: Text? = nil, message: Text? = nil, fieldText: Binding<String>? = nil, fieldPlaceholder: String = "", tag: String? = nil, primaryButton: Achtung.Button? = nil, secondaryButton: Achtung.Button? = nil, dismissButton: Achtung.Button? = nil) {
			self.title = title
			self.message = message
			self.tag = tag
			self.buttons = [primaryButton, secondaryButton, dismissButton].compactMap { $0 }
			  self.fieldText = fieldText
			  self.fieldPlaceholder = fieldPlaceholder
		}

		public static func ==(lhs: Achtung.Alert, rhs: Achtung.Alert) -> Bool { lhs.id == rhs.id }
	}
}

#endif
