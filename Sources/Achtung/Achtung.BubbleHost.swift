//
//  Achtung.BubbleHost.swift
//
//
//  Created by Ben Gottlieb on 8/26/26.
//

import SwiftUI
#if os(iOS)
	import UIKit
#elseif os(macOS)
	import AppKit
#endif

/// Where bubbles are drawn. On iOS they ride along in Achtung's existing overlay
/// window; the Mac has no such window, so one is built on demand and thrown away
/// when the last bubble pops.
@available(iOS 17.0, macOS 14.0, watchOS 10.0, *)
@MainActor enum BubbleHost {
	static var canShow: Bool {
		#if os(iOS)
			Achtung.instance.hostWindow != nil && UIApplication.shared.applicationState == .active
		#elseif os(macOS)
			NSApplication.shared.isActive && BubbleOverlayWindow.instance.hasTargetWindow
		#else
			false
		#endif
	}

	/// Callers hand over positions in their own window's coordinate space, whose
	/// top edge is the top of the window's *content*. The Mac overlay spans the
	/// whole window frame, title bar included, so those positions sit that much
	/// lower in it. iOS has no such gap.
	static var originOffset: CGSize {
		#if os(macOS)
			BubbleOverlayWindow.instance.titleBarInset
		#else
			.zero
		#endif
	}

	static func prepare() {
		#if os(macOS)
			BubbleOverlayWindow.instance.open()
		#endif
	}

	static func finish() {
		#if os(macOS)
			BubbleOverlayWindow.instance.close()
		#endif
	}
}
