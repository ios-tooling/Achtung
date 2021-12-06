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
	struct Container: View {
		@ObservedObject var achtung = Achtung.instance

		var alerts: some View {
			let count = achtung.pendingAlerts.count - 1
			return ForEach(achtung.pendingAlerts.indices, id: \.self) { index in
				Achtung.Alert.AlertView(alert: achtung.pendingAlerts[count - index])
					.offset(x: -CGFloat(count - index) * 10, y: -CGFloat(count - index) * 10)
			}
		}
		
		public var body: some View {
			Group() {
				if !achtung.pendingAlerts.isEmpty {
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
