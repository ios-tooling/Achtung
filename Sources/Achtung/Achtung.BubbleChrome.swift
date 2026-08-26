//
//  Achtung.BubbleChrome.swift
//
//
//  Created by Ben Gottlieb on 8/26/26.
//

import SwiftUI

@available(iOS 17.0, macOS 14.0, watchOS 10.0, *)
extension Achtung {
	/// The standard bubble surround. Callers supply the interior; this keeps
	/// bubbles recognizable as bubbles wherever they're used. A capsule with a
	/// square minimum reads as a circle for a lone glyph and stretches for text.
	struct BubbleChrome: View {
		let bubble: Bubble

		@ScaledMetric private var minimumSize = 40

		private var tint: Color { bubble.tint ?? .primary }

		var body: some View {
			bubble.content
				.foregroundStyle(tint)
				.padding(.horizontal, 10)
				.padding(.vertical, 6)
				.frame(minWidth: minimumSize, minHeight: minimumSize)
				.background(.regularMaterial, in: Capsule())
				.overlay(Capsule().strokeBorder(tint.opacity(0.25), lineWidth: 1))
				.shadow(color: .black.opacity(0.18), radius: 6, y: 3)
		}
	}

	/// Hosts every bubble in flight. Sized by whatever it's dropped into — the
	/// overlay window on iOS, the child window on the Mac — so origins and rise
	/// distances are all relative to that.
	struct BubbleLayer: View {
		private var bubbles = Achtung.Bubbles.instance

		init() { }

		var body: some View {
			GeometryReader { proxy in
				ForEach(bubbles.live) { live in
					BubbleView(live: live, container: proxy.size)
				}
			}
			.allowsHitTesting(false)
			.accessibilityHidden(true)
			.ignoresSafeArea()
		}
	}
}

@available(iOS 17.0, macOS 14.0, watchOS 10.0, *)
#Preview {
	ZStack {
		Color.gray.ignoresSafeArea()
		Achtung.BubbleChrome(bubble: .init(systemImage: "square.grid.3x3.fill", tint: .blue))
		Achtung.BubbleChrome(bubble: .init("+22", tint: .blue)).offset(y: 60)
	}
}
