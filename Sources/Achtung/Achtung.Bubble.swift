//
//  Achtung.Bubble.swift
//
//
//  Created by Ben Gottlieb on 8/26/26.
//

import SwiftUI

@available(iOS 17.0, macOS 14.0, watchOS 10.0, *)
public extension Achtung {
	/// A small view that rises through the app's UI and fades away — ambient
	/// feedback for something that arrived and needs no response. Bubbles are
	/// purely decorative: they never receive touches or clicks.
	struct Bubble: Identifiable {
		public let id = UUID()
		/// Where the bubble starts, in the host layer's coordinate space. `nil`
		/// spawns it at a random point along the bottom edge.
		public var origin: CGPoint?
		public var tint: Color?
		let content: AnyView

		public init<Content: View>(origin: CGPoint? = nil, tint: Color? = nil, @ViewBuilder content: () -> Content) {
			self.origin = origin
			self.tint = tint
			self.content = AnyView(content())
		}

		/// A few characters, optionally led by a symbol.
		public init(_ text: String = "", systemImage: String? = nil, origin: CGPoint? = nil, tint: Color? = nil) {
			self.init(origin: origin, tint: tint) {
				HStack(spacing: 3) {
					if let systemImage { Image(systemName: systemImage) }
					if !text.isEmpty { Text(text) }
				}
				.font(.system(.headline, design: .rounded).weight(.semibold))
			}
		}

		public init(systemImage: String, origin: CGPoint? = nil, tint: Color? = nil) {
			self.init("", systemImage: systemImage, origin: origin, tint: tint)
		}

		/// Moves an explicitly placed bubble into the host layer's own space. A
		/// bubble with no origin has nothing to move — it's placed relative to the
		/// layer's bottom edge wherever that turns out to be.
		func offsetting(by offset: CGSize) -> Bubble {
			guard let origin, offset != .zero else { return self }
			var moved = self
			moved.origin = CGPoint(x: origin.x + offset.width, y: origin.y + offset.height)
			return moved
		}
	}

	/// A bubble plus the randomized flight it was given when it spawned. The
	/// randomness is decided once, here, so the views that draw it stay pure.
	struct LiveBubble: Identifiable {
		public var id: UUID { bubble.id }
		let bubble: Bubble
		let delay: TimeInterval
		let duration: TimeInterval
		let xFraction: CGFloat
		let wobble: CGFloat
		let phase: CGFloat
		let cycles: CGFloat
		let scale: CGFloat

		var lifetime: TimeInterval { delay + duration }

		init(bubble: Bubble, delay: TimeInterval) {
			self.bubble = bubble
			self.delay = delay
			duration = .random(in: 2.5...3.5)
			xFraction = .random(in: 0.15...0.85)
			wobble = .random(in: 8...20)
			phase = .random(in: 0...(.pi * 2))
			cycles = .random(in: 1.5...2.5)
			scale = .random(in: 0.85...1.1)
		}
	}
}
