//
//  AchtungView.swift
//  
//
//  Created by ben on 8/13/20.
//

#if canImport(Combine)
import SwiftUI
import Combine

@available(OSX 10.15, iOS 13.0, *)
public struct Achtung: Identifiable, Equatable {
	public let id = UUID()
	var tag: String?
	var title: Text?
	var message: Text?
	let buttons: [Achtung.Button]
	
	func buttonPressed() {
		Achtung.manager.remove(self)
	}
	
	public init(title: Text? = nil, message: Text? = nil, tag: String? = nil, buttons: [Achtung.Button]) {
		self.title = title
		self.message = message
		self.tag = tag
		self.buttons = buttons
	}

	public init(title: Text? = nil, message: Text? = nil, tag: String? = nil, primaryButton: Achtung.Button? = nil, secondaryButton: Achtung.Button? = nil, dismissButton: Achtung.Button? = nil) {
		self.title = title
		self.message = message
		self.tag = tag
		self.buttons = [primaryButton, secondaryButton, dismissButton].compactMap { $0 }
	}

	public static func ==(lhs: Achtung, rhs: Achtung) -> Bool { lhs.id == rhs.id }
}

@available(OSX 10.15, iOS 13.0, *)
public extension View {
	func achtung<Item: Identifiable>(item target: Binding<Item?>, content: (Item) -> Achtung?) -> some View {
		if let item = target.wrappedValue, let alert = content(item) {
			Achtung.manager.show(title: alert.title, message: alert.message, tag: alert.tag, buttons: alert.buttons)
			DispatchQueue.main.async { target.wrappedValue = nil }
		}
		return self
	}
}

@available(OSX 10.15, iOS 13.0, *)
extension Achtung {
	struct AlertView: View {
		let alert: Achtung
		
		let radius: CGFloat = 8
		
		public var body: some View {
			ZStack() {
				RoundedRectangle(cornerRadius: radius)
					.fill(Color.black.opacity(0.9))
				
				RoundedRectangle(cornerRadius: radius)
					.stroke(Color.white.opacity(0.9))
				
				VStack() {
					if alert.title != nil {
						alert.title!
							.font(.headline)
							.multilineTextAlignment(.center)
							.lineLimit(nil)
							.foregroundColor(.white)
							.padding(3)
							.frame(maxWidth: 250)
					}

					if alert.message != nil {
						alert.message!
							.font(.body)
							.multilineTextAlignment(.center)
							.lineLimit(nil)
							.foregroundColor(.white)
							.padding(3)
							.frame(maxWidth: 250)
					}
					
					ForEach(alert.buttons) { button in
						SwiftUI.Button(action: {
							button.pressed()
							self.alert.buttonPressed()
						}) {
							ZStack() {
								RoundedRectangle(cornerRadius: self.radius)
									.fill(Color.black.opacity(0.9))
								
								RoundedRectangle(cornerRadius: self.radius)
									.stroke(Color.white.opacity(0.9))
								
								button.label
									.font(.callout)
									.multilineTextAlignment(.center)
									.foregroundColor(.white)
									.padding(.vertical, 3)
									.frame(minWidth: 220)
									.layoutPriority(1)
							}
						}
					}
				}
				.padding(10)
				.layoutPriority(1)
			}
			.transition(AnyTransition.scale)
		}
	}
}


@available(OSX 10.15, iOS 13.0, *)
struct Achtung_Previews: PreviewProvider {
	static var previews: some View {
		Achtung.container()
	}
}
#endif
