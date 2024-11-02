//
//  Achtung.AlertView.swift
//
//
//  Created by Ben Gottlieb on 12/7/21.
//

import SwiftUI

@available(OSX 10.15, iOS 14.0, *)
extension Achtung {
	@MainActor struct AlertView: View {
		let alert: Achtung.Alert
		var foreground: Color { alert.foregroundColor ?? Achtung.instance.alertForegroundColor }
		var borderColor: Color { alert.borderColor ?? Achtung.instance.alertBorderColor  }
		var backgroundColor: Color { alert.backgroundColor ?? Achtung.instance.alertBackgroundColor  }
		@State private var fieldText = ""
		
		var radius: CGFloat = 8
		
		public var body: some View {
			ZStack() {
				RoundedRectangle(cornerRadius: radius)
					.fill(backgroundColor)
				
				RoundedRectangle(cornerRadius: radius)
					.stroke(borderColor)
				
				VStack() {
					if alert.title != nil {
						alert.title!
							.font(.headline)
							.multilineTextAlignment(.center)
							.lineLimit(nil)
							.foregroundColor(foreground)
							.padding(5)
							.frame(maxWidth: 250)
					}
					
					if alert.message != nil {
						alert.message!
							.font(.body)
							.fixedSize(horizontal: false, vertical: true)
							.multilineTextAlignment(.center)
							.lineLimit(nil)
							.foregroundColor(foreground)
							.padding(5)
							.frame(maxWidth: 250)
					}
					
					if let fieldInfo = alert.fieldInfo {
						Group {
							if #available(iOS 15.0, macOS 12, *) {
								FocusedTextField(label: fieldInfo.placeholder, text: $fieldText, alert: alert)
							} else {
								TextField(fieldInfo.placeholder, text: $fieldText)
							}
						}
						.onChange(of: fieldText) { newValue in
							if let limit = fieldInfo.limit, newValue.count > limit {
								fieldText = fieldInfo.text.wrappedValue
							} else {
								fieldInfo.text.wrappedValue = newValue
							}
						}
						.foregroundColor(foreground)
						.font(.body)
						.padding()
						.background(RoundedRectangle(cornerRadius: 3).stroke(borderColor, lineWidth: 0.5))
						.padding()
						.frame(maxWidth: 300)
					}
					
					if alert.buttons.count <= 2 {
						HStack() { buttonViews(minWidth: 120) }
					} else {
						buttonViews(minWidth: 220)
					}
				}
				.padding(10)
				.layoutPriority(1)
			}
			.padding(20)
			.transition(AnyTransition.scale)
			.contentShape(.rect)
		}
		
		func buttonViews(minWidth: CGFloat) -> some View {
			ForEach(alert.buttons) { button in
				SwiftUI.Button(action: {
					button.pressed()
					self.alert.buttonPressed()
				}) {
					ZStack() {
						RoundedRectangle(cornerRadius: self.radius)
							.fill(backgroundColor)
						
						RoundedRectangle(cornerRadius: self.radius)
							.stroke(borderColor)
						
						button.label
							.font(.callout)
							.multilineTextAlignment(.center)
							.foregroundColor(foreground)
							.padding(.vertical, 5)
							.frame(minWidth: minWidth, minHeight: 40)
							.layoutPriority(1)
							.styled(for: button)
					}
					.padding(3)
				}
			}
		}
		
	}
}

@available(OSX 12, iOS 15.0, *)
struct FocusedTextField: View {
	let label: String
	@Binding var text: String
	@FocusState var isFocused: Bool
	let alert: Achtung.Alert
	
	var body: some View {
		TextField(label, text: $text)
			.focused($isFocused, equals: true)
			.onAppear {
				isFocused = true
			}
			.onSubmit {
				if let defaultButton = alert.buttons.first(where: { $0.kind == .normal })  {
					defaultButton.action?()
					alert.buttonPressed()
				}
			}
	}
}
