//
//  BubbleButtons.swift
//  AchtungTesting
//
//  Created by Ben Gottlieb on 8/26/26.
//

import SwiftUI
import Achtung

@available(iOS 17.0, macOS 14.0, *)
struct BubbleButtons: View {
	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text("Bubbles")
				.font(.headline)

			Button("Bubble: One") {
				Achtung.show(bubble: .init(systemImage: "star.fill", tint: .orange), announcement: "One new thing")
			}

			Button("Bubble: A Handful") {
				Achtung.show(bubbles: (0..<6).map { _ in .init(systemImage: "square.grid.3x3.fill", tint: .accentColor) },
								 announcement: "6 new puzzles")
			}

			Button("Bubble: Capped With Overflow") {
				var bubbles: [Achtung.Bubble] = (0..<8).map { _ in .init(systemImage: "square.grid.3x3.fill", tint: .accentColor) }
				bubbles.append(.init("+22", tint: .accentColor))
				Achtung.show(bubbles: bubbles, announcement: "30 new puzzles")
			}

			Button("Bubble: Custom Content") {
				Achtung.show(bubble: .init(tint: .purple) {
					VStack(spacing: 0) {
						Text("🫧").font(.title3)
						Text("hi").font(.caption2)
					}
				})
			}

			Button("Bubble: From A Corner") {
				Achtung.show(bubbles: (0..<4).map { _ in .init("↑", origin: CGPoint(x: 60, y: 400), tint: .teal) })
			}
		}
	}
}
