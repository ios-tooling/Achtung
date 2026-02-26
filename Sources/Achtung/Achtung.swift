//
//  AchtungView.swift
//
//
//  Created by ben on 8/13/20.
//

#if canImport(Combine)

import SwiftUI
import Combine

@available(macOS 10.15, iOS 13.0, *)
@MainActor public class Achtung: ObservableObject {
	public static let instance = Achtung()
#if os(iOS)
	var hostWindow: HostWindow?
#endif
	var toasts: [Toast] = []
	var isSettingUp = false
	var nextToastTimer: Timer?
	var lastToast: Toast?
	var lastToastTime: Date?
	@Published var currentToast: Toast?
	@Published var pendingAlerts: [Achtung.Alert] = []


	@Published public var configuration = Configuration()
	@Published public internal(set) var recordedErrors: [RecordedError] = []
	
	/// Async version - handles an error with filtering
	@MainActor public func handle(_ error: Error, level: ErrorLevel? = nil, title: LocalizedStringKey? = nil) async {
		var displayed = error

		switch configuration.filterError(error) {
		case .ignore: return
		case .log:
			await Self.recordError(error, title: title)
			print("Achtung recorded: \(error)")
			return

		case .display: break
		case .replace(let err): displayed = err
		}

		await Self.recordError(displayed, title: title)
		await Self.show(displayed, level: level ?? .testing, title: title)
	}

	/// Non-async wrapper
	public func handle(_ error: Error, level: ErrorLevel? = nil, title: LocalizedStringKey? = nil) {
		Task { @MainActor in
			await handle(error, level: level, title: title)
		}
	}
	
	private init() { }
	
	public func load(configuration: Configuration) {
		self.configuration = configuration
	}
	
	#if os(macOS)
		public func setup(level: ErrorLevel = .standard) {
			errorDisplayLevel = level
		}
	#else
		public func setup(in scene: UIWindowScene? = nil) {
			if let scene = scene {
				self.add(toScene: scene)
			} else {
				isSettingUp = true
				Task {
					if #available(iOS 16.0, *) {
						await AchtungNotifications.instance.setup()
					}
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
					self.currentToast = toasts.first
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
				Task { @MainActor [weak self] in self?.showNextToast() }
			}
		} else {
			nextToastTimer = nil
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

