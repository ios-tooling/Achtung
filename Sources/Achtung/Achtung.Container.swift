//
//  Achtung.Container.swift
//
//
//  Created by ben on 8/13/20.
//

#if canImport(Combine)

import SwiftUI
import Combine

@available(macOS 10.15, iOS 13.0, *)
extension Achtung {
	struct Container: View {
		@ObservedObject var achtung = Achtung.instance
		
		@ViewBuilder var alerts: some View {
			if #available(iOS 14.0, *) {
				let custom = achtung.customAlerts
				let count = custom.count - 1
				ForEach(custom.indices, id: \.self) { index in
					Achtung.AlertView(alert: custom[count - index])
						.offset(x: -CGFloat(count - index) * 10, y: -CGFloat(count - index) * 10)
				}
			}
		}
		
		public var body: some View {
			ZStack() {
				// native alerts dim the screen themselves; the scrim is for Achtung's own cards
				if !achtung.customAlerts.isEmpty {
					Rectangle()
						.fill(Color.black.opacity(0.5))
						.ignoresSafeArea(.all)
						.allowsHitTesting(true)
						.transition(.opacity)
						.onTapGesture {
							if let first = Achtung.instance.customAlerts.first, first.tapOutsideToDismiss {
								Achtung.instance.remove(first)
							}
						}
					
					alerts
				}
				
				if let toast = achtung.currentToast {
					ToastView(toast: toast)
						.zIndex(100)
				}

				if #available(iOS 17.0, macOS 14.0, watchOS 10.0, *) {
					Achtung.BubbleLayer()
						.zIndex(200)
				}
			}
			.modifier(NativeAlertHost())
			.onChange(of: achtung.pendingAlerts) { alerts in
				#if os(iOS)
					Achtung.instance.hostWindow?.isAlertVisible = !alerts.isEmpty
				#endif
			}
		}
	}
}

@available(macOS 10.15, iOS 13.0, *)
extension Achtung {
	/// The native presenter needs newer SwiftUI than the container's floor; older systems draw
	/// every alert as a card.
	struct NativeAlertHost: ViewModifier {
		func body(content: Content) -> some View {
			if #available(iOS 15.0, macOS 12, *) {
				content.modifier(NativeAlertPresenter())
			} else {
				content
			}
		}
	}
}
#endif
