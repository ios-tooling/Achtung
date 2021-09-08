//
//  View+Achtung.swift
//  
//
//  Created by Ben Gottlieb on 9/8/21.
//

import SwiftUI


@available(OSX 10.15, iOS 13.0, *)
public extension View {
	func achtung<Item: Identifiable>(achtung manager: Achtung.Manager? = nil, item target: Binding<Item?>, content: (Item, Achtung.Manager) -> Achtung?) -> some View {
		let achtung = manager ?? Achtung.manager
		if let item = target.wrappedValue, let alert = content(item, achtung) {
			achtung.show(title: alert.title, message: alert.message, tag: alert.tag, buttons: alert.buttons)
			DispatchQueue.main.async { target.wrappedValue = nil }
		}
		return self
	}
}

