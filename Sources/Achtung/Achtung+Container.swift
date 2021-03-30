//
//  SwiftUIView.swift
//  
//
//  Created by ben on 8/13/20.
//

#if canImport(Combine)
import SwiftUI
import Combine

@available(OSX 10.15, iOS 13.0, *)
extension Achtung {
	public static func container(_ manager: Achtung.Manager? = nil) -> Container { Container(manager: manager) }
	
	public struct Container: View {
		@ObservedObject var alertive = Achtung.manager
		
		init(manager: Achtung.Manager? = nil) {
			self.alertive = manager ?? Achtung.manager
		}
		
		var alerts: some View {
			let count = alertive.pendingAlerts.count - 1
			return ForEach(alertive.pendingAlerts.indices, id: \.self) { index in
				Achtung.AlertView(alert: self.alertive.pendingAlerts[count - index], manager: alertive)
					.offset(x: -CGFloat(count - index) * 10, y: -CGFloat(count - index) * 10)
			}
		}
		
		public var body: some View {
			Group() {
				if alertive.pendingAlerts.isEmpty {
					EmptyView()
				} else {
					ZStack() {
						Rectangle()
							.fill(Color.black.opacity(0.5))
							.edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
							.transition(.opacity)
						
						alerts
					}
					.edgesIgnoringSafeArea(.all)
				}
			}
		}
	}
}
#endif
