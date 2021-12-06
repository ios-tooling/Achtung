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
public class Achtung: ObservableObject {
	public static let instance = Achtung()
	var hostWindow: UIWindow?
	@Published var pendingAlerts: [Achtung.Alert] = []

	private init() {
		
	}
	
	public func setup(in scene: UIWindowScene? = nil) {
		DispatchQueue.main.async {
			self.add(toScene: scene)
		}
	}
}

//@available(OSX 10.15, iOS 13.0, *)
//public extension AchtungAlertableView {
//	func achtung<Item: Identifiable>(item target: Binding<Item?>, content: (Item) -> Achtung.Alert?) -> some View {
//		if let item = target.wrappedValue, let alert = content(item) {
//			achtung(title: alert.title, message: alert.message, tag: alert.tag, buttons: alert.buttons)
//			DispatchQueue.main.async { target.wrappedValue = nil }
//		}
//		return self
//	}
//}

@available(OSX 10.15, iOS 13.0, *)
extension Achtung.Alert {
	struct AlertView: View {
		let alert: Achtung.Alert
		let foreground: Color = .white
		let borderColor: Color = .white
		
		let radius: CGFloat = 8
		
		public var body: some View {
			ZStack() {
				RoundedRectangle(cornerRadius: radius)
					.fill(Color.black.opacity(0.9))
				
				RoundedRectangle(cornerRadius: radius)
					.stroke(borderColor.opacity(0.9))
				
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
                    
                    if let text = alert.fieldText {
                        TextField(alert.fieldPlaceholder, text: text)
                            .foregroundColor(foreground)
                            .font(.body)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 3).stroke(borderColor, lineWidth: 0.5))
                            .padding()
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
		}

        func buttonViews(minWidth: CGFloat) -> some View {
            ForEach(alert.buttons) { button in
                SwiftUI.Button(action: {
                    button.pressed()
                    self.alert.buttonPressed()
                }) {
                    ZStack() {
                        RoundedRectangle(cornerRadius: self.radius)
                            .fill(Color.black.opacity(0.9))
                        
                        RoundedRectangle(cornerRadius: self.radius)
                            .stroke(borderColor.opacity(0.9))
                        
                        button.label
                            .font(.callout)
                            .multilineTextAlignment(.center)
                            .foregroundColor(foreground)
                            .padding(.vertical, 5)
                            .frame(minWidth: minWidth, minHeight: 40)
                            .layoutPriority(1)
                    }
                    .padding(3)
                }
            }
        }
        
    }
}
#endif
