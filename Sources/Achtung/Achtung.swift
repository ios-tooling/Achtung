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
	#if os(iOS)
		var hostWindow: UIWindow?
	#endif
	var toasts: [Toast] = []
	var isSettingUp = false
	weak var nextToastTimer: Timer?
	public var errorDisplayLevel = ErrorLevel.standard
	
	
	@Published var currentToast: Toast?
	@Published var pendingAlerts: [Achtung.Alert] = []

	private init() {
		
	}
	
	#if os(macOS)
		public func setup(level: ErrorLevel = .standard) {
			errorDisplayLevel = level
		}
	#else
		public func setup(in scene: UIWindowScene? = nil, level: ErrorLevel? = nil) {
			if let level { errorDisplayLevel = level }
			if let scene = scene {
				self.add(toScene: scene)
			} else {
				isSettingUp = true
				Task {
					try await Task.sleep(nanoseconds: 500_000_000)
					await MainActor.run {
						self.add(toScene: nil)
						self.isSettingUp = false
					}
				}
			}
		}
	#endif
	
	func showNextToast() {
		if currentToast == nil, let next = toasts.first {
			withAnimation(.easeOut(duration: Achtung.showDuration)) {
				currentToast = next
			}
			Task {
				try await Task.sleep(nanoseconds: UInt64(500_000_000 * next.duration))
				await MainActor.run {
					self.dismissCurrentToast()
				}
			}
			toasts.removeFirst()
		}
	}
	
	func dismissCurrentToast() {
		if currentToast != nil {
			withAnimation(.easeIn(duration: Achtung.hideDuration)) {
				currentToast = nil
			}
			nextToastTimer = Timer.scheduledTimer(withTimeInterval: Achtung.hideDuration, repeats: false) { _ in
				self.showNextToast()
			}
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

#endif

