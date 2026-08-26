//
//  Achtung.BubbleOverlayWindow.swift
//
//
//  Created by Ben Gottlieb on 8/26/26.
//

#if os(macOS)
import SwiftUI
import AppKit

/// A transparent, click-through window parented to whichever window the user is
/// working in. Being a child window means it rides along when that window moves
/// and orders above it — including over the title bar, which a view inside the
/// window could never reach.
@available(macOS 14.0, *)
@MainActor final class BubbleOverlayWindow {
	static let instance = BubbleOverlayWindow()

	private var overlay: NSWindow?
	private var resizeObserver: (any NSObjectProtocol)?

	private init() { }

	/// The window the user is looking at. Chosen only when an overlay is built,
	/// so bubbles already in flight aren't yanked to a newly focused window.
	private var targetWindow: NSWindow? { NSApplication.shared.keyWindow ?? NSApplication.shared.mainWindow }

	var hasTargetWindow: Bool { overlay != nil || targetWindow != nil }

	func open() {
		// The window we were riding on closed out from under us; start over
		// against whatever the user is looking at now.
		if overlay != nil, overlay?.parent == nil { close() }
		if overlay != nil { return }
		guard let parent = targetWindow else { return }

		let window = NSWindow(contentRect: parent.frame, styleMask: .borderless, backing: .buffered, defer: false)
		window.isOpaque = false
		window.backgroundColor = .clear
		window.hasShadow = false
		window.ignoresMouseEvents = true
		window.collectionBehavior = [.transient, .ignoresCycle, .fullScreenAuxiliary]
		window.contentView = NSHostingView(rootView: Achtung.BubbleLayer())
		window.setFrame(parent.frame, display: false)
		parent.addChildWindow(window, ordered: .above)
		overlay = window

		resizeObserver = NotificationCenter.default.addObserver(forName: NSWindow.didResizeNotification, object: parent, queue: .main) { _ in
			Task { @MainActor in BubbleOverlayWindow.instance.matchParentFrame() }
		}
	}

	func close() {
		if let resizeObserver { NotificationCenter.default.removeObserver(resizeObserver) }
		resizeObserver = nil
		guard let overlay else { return }
		overlay.parent?.removeChildWindow(overlay)
		overlay.orderOut(nil)
		self.overlay = nil
	}

	/// How much taller the parent's frame is than the content it hosts. Zero for
	/// a window drawing its content full-size behind the title bar.
	var titleBarInset: CGSize {
		guard let parent = overlay?.parent ?? targetWindow else { return .zero }
		let content = parent.contentRect(forFrameRect: parent.frame)
		return CGSize(width: 0, height: max(0, parent.frame.height - content.height))
	}

	private func matchParentFrame() {
		guard let overlay, let parent = overlay.parent else { return }
		overlay.setFrame(parent.frame, display: true)
	}
}
#endif
