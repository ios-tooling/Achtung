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
@MainActor public class Achtung: ObservableObject {
	public static let instance = Achtung()
#if os(iOS)
	var hostWindow: HostWindow?
#endif
	var toasts: [Toast] = []
	var isSettingUp = false
	weak var nextToastTimer: Timer?
	public var errorDisplayLevel = ErrorLevel.standard
	
	
	@Published var currentToast: Toast?
	@Published var pendingAlerts: [Achtung.Alert] = []
	@Published public internal(set) var recordedErrors: [RecordedError] = []
	public var recordedErrorLimit = 10
	
	@Published public var alertBackgroundColor = Color.black
	@Published public var alertForegroundColor = Color.white
	@Published public var alertBorderColor = Color.white.opacity(0.9)
	
	@Published public var toastBackgroundColor = Color.black
	@Published public var toastForegroundColor = Color.white
	@Published public var toastBorderColor = Color.white.opacity(0.9)
	
	public var filterError: (Error) -> ErrorFilterResult = { _ in .display }
	
	public func handle(_ error: Error, level: ErrorLevel? = nil, title: LocalizedStringKey? = nil) {
		var displayed = error
		
		switch filterError(error) {
		case .ignore: return
		case .log:
			Self.recordError(error, title: title)
			print("Achtung recorded: \(error)")
			return
			
		case .display: break
		case .replace(let err): displayed = err
		}
		
		Self.recordError(error, title: title)
		Self.show(displayed, level: level ?? .testing, title: title)
	}
	
	private init() { }
	
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
			withAnimation(.easeOut(duration: Achtung.showToastDuration)) {
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
			#if os(iOS)
				Achtung.instance.hostWindow?.activeToastFrame = .zero
			#endif
			
			withAnimation(.easeIn(duration: Achtung.hideToastDuration)) {
				currentToast = nil
			}
			nextToastTimer = Timer.scheduledTimer(withTimeInterval: Achtung.hideToastDuration, repeats: false) { _ in
				Task { @MainActor in self.showNextToast() }
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

