//
//  View+Achtung.swift
//  
//
//  Created by Ben Gottlieb on 9/8/21.
//

import SwiftUI


@available(OSX 10.15, iOS 13.0, *)
public extension View {
	@MainActor func achtung<Item: Identifiable>(item target: Binding<Item?>, content: (Item) -> Achtung.Alert?) -> some View {
		if let item = target.wrappedValue, let alert = content(item) {
			Achtung.show(title: alert.title, message: alert.message, tag: alert.tag, buttons: alert.buttons)
			DispatchQueue.main.async { target.wrappedValue = nil }
		}
		return self
	}
}

