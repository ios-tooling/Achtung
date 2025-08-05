//
//  Achtung+Setup.swift
//  
//
//  Created by Ben Gottlieb on 12/6/21.
//

#if canImport(Combine)
#if os(iOS)

import SwiftUI
import Combine
import UIKit

@available(OSX 10.15, iOS 13.0, *)
public extension Achtung {
	static var isInPreview: Bool { ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" }

	
	var isSetup: Bool {
		if hostWindow == nil {
			if !Self.isInPreview {
				print("#### Achtung was not successfully set up. Please call Achtung.instance.setup(scene:) at init time ###")
			}
			return false
		}
		return true
	}
	
	@MainActor func add(toScene: UIWindowScene?) {
		if hostWindow != nil { return }				 // already added
		guard let scene = toScene ?? firstWindowScene else {
			if !Self.isInPreview {
				print("#### Unable to find a window scene, no Achtung for you! ####")
			}
			return
		}
		
		let window = HostWindow(windowScene: scene)
		window.windowLevel = .statusBar
		window.rootViewController = UIHostingController(rootView: Achtung.Container())
		window.rootViewController?.view.backgroundColor = .clear
		window.isHidden = false
//		window.rootViewController?.view.isUserInteractionEnabled = true
		self.hostWindow = window
	}

	var firstWindowScene: UIWindowScene? {
		UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first
	}

	class HostWindow: UIWindow {
		var isEnabled = false
		var activeToastFrame = CGRect.zero
		
		public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
			guard let hitView = super.hitTest(point, with: event) else { return nil }
			if isEnabled { return hitView }
			if activeToastFrame.contains(point) { return hitView }
			return rootViewController?.view == hitView ? nil : hitView
		}
	}
}
#else
@available(OSX 10.15, iOS 13.0, *)
public extension Achtung {
	func setup() { }
	var isSetup: Bool { false }
}
#endif
#endif
