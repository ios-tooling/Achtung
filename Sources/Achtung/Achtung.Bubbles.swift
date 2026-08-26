//
//  Achtung.Bubbles.swift
//
//
//  Created by Ben Gottlieb on 8/26/26.
//

import SwiftUI

@available(iOS 17.0, macOS 14.0, watchOS 10.0, *)
public extension Achtung {
	/// Shows bubbles. Whatever it's handed is what rises — batching, capping and
	/// grouping are the caller's business; all this owns is the flight.
	@MainActor static func show(bubbles: [Bubble], announcement: String? = nil) {
		Bubbles.instance.show(bubbles, announcement: announcement)
	}

	@MainActor static func show(bubble: Bubble, announcement: String? = nil) {
		show(bubbles: [bubble], announcement: announcement)
	}
}

@available(iOS 17.0, macOS 14.0, watchOS 10.0, *)
public extension Achtung {
	@MainActor @Observable final class Bubbles {
		public static let instance = Bubbles()

		/// A backstop against a caller handing over an unbounded list; the
		/// interesting limits belong to whoever knows what the bubbles mean.
		static let maximumLive = 32

		private(set) var live: [LiveBubble] = []

		private init() { }

		func show(_ bubbles: [Bubble], announcement: String?) {
			// Bubbles are decoration, and decoration nobody is looking at is just
			// work: skip them outright when the app isn't frontmost.
			guard !bubbles.isEmpty, BubbleHost.canShow else { return }
			if let announcement { AccessibilityNotification.Announcement(announcement).post() }

			let room = Self.maximumLive - live.count
			guard room > 0 else { return }

			// Built before the bubbles so the coordinate space they're placed in
			// already exists, and so each one keeps the same origin for its whole
			// flight even if the window moves under it.
			BubbleHost.prepare()
			let offset = BubbleHost.originOffset

			var delay: TimeInterval = 0
			let spawned = bubbles.prefix(room).map { bubble in
				defer { delay += .random(in: 0.1...0.22) }
				return LiveBubble(bubble: bubble.offsetting(by: offset), delay: delay)
			}

			live += spawned
			scheduleExpiry(after: spawned.map(\.lifetime).max() ?? 0, ids: Set(spawned.map(\.id)))
		}

		private func scheduleExpiry(after lifetime: TimeInterval, ids: Set<UUID>) {
			Task {
				try? await Task.sleep(nanoseconds: UInt64((lifetime + 0.2) * 1_000_000_000))
				live.removeAll { ids.contains($0.id) }
				if live.isEmpty { BubbleHost.finish() }
			}
		}
	}
}
