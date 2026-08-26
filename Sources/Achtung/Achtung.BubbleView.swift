//
//  Achtung.BubbleView.swift
//
//
//  Created by Ben Gottlieb on 8/26/26.
//

import SwiftUI

@available(iOS 17.0, macOS 14.0, watchOS 10.0, *)
extension Achtung {
	/// One bubble in flight: rises, sways, and dissolves before it reaches the top.
	struct BubbleView: View {
		let live: LiveBubble
		let container: CGSize

		@Environment(\.accessibilityReduceMotion) private var reduceMotion
		@State private var progress: CGFloat = 0
		@State private var opacity: CGFloat = 0
		@State private var spawnScale: CGFloat = 0.01
		@State private var fadeScale: CGFloat = 1

		/// Quick enough to read as the bubble popping into being rather than as
		/// something growing.
		private static let spawnDuration: TimeInterval = 0.2

		/// How far above its origin a motionless bubble sits, so one spawned at
		/// the bottom edge is still fully on screen.
		private static let staticLift: CGFloat = 60

		private var origin: CGPoint {
			live.bubble.origin ?? CGPoint(x: container.width * live.xFraction, y: container.height + 24)
		}

		/// Short of the full height: bubbles are gone well before the top, where
		/// the status bar and toolbars live.
		private var rise: CGFloat { max(200, container.height * 0.75) }

		var body: some View {
			BubbleChrome(bubble: live.bubble)
				.scaleEffect(live.scale * spawnScale * fadeScale)
				.opacity(opacity)
				.modifier(BubbleRise(progress: progress, rise: rise, wobble: reduceMotion ? 0 : live.wobble, phase: live.phase, cycles: live.cycles))
				.position(origin)
				.onAppear(perform: launch)
		}

		private func launch() {
			guard !reduceMotion else {
				progress = Self.staticLift / rise
				spawnScale = 1
				withAnimation(.easeOut(duration: 0.3).delay(live.delay)) { opacity = 1 }
				withAnimation(.easeIn(duration: 0.5).delay(live.delay + live.duration - 0.5)) { opacity = 0 }
				return
			}

			withAnimation(.easeOut(duration: Self.spawnDuration).delay(live.delay)) {
				opacity = 1
				spawnScale = 1
			}
			withAnimation(.easeOut(duration: live.duration).delay(live.delay)) { progress = 1 }
			withAnimation(.easeIn(duration: live.duration * 0.4).delay(live.delay + live.duration * 0.6)) {
				opacity = 0
				fadeScale = 1.3
			}
		}
	}

	/// Rise plus a sine sway that eases in as the bubble climbs. A `GeometryEffect`
	/// rather than an offset so SwiftUI interpolates `progress` and lets us walk
	/// the curve, instead of interpolating start and end points in a straight line.
	struct BubbleRise: GeometryEffect {
		var progress: CGFloat
		let rise: CGFloat
		let wobble: CGFloat
		let phase: CGFloat
		let cycles: CGFloat

		var animatableData: CGFloat {
			get { progress }
			set { progress = newValue }
		}

		func effectValue(size: CGSize) -> ProjectionTransform {
			let dx = sin(progress * .pi * 2 * cycles + phase) * wobble * progress
			return ProjectionTransform(CGAffineTransform(translationX: dx, y: -rise * progress))
		}
	}
}
