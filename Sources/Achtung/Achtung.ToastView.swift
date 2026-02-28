//
//  Achtung.ToastView.swift
//
//
//  Created by Ben Gottlieb on 12/7/21.
//

import SwiftUI

extension Achtung {
	@MainActor struct ToastView: View {
		let toast: Achtung.Toast
		@State private var dragOffset: CGFloat = 0
		@State private var baseFrame: CGRect = .zero
		
		private let flickThreshold: CGFloat = 60
		private let flickPredictedThreshold: CGFloat = 140

		var body: some View {
			ToastBodyView(toast: toast)
				.transition(.move(edge: .top))
				.zIndex(100)
				.offset(y: dragOffset)
				.contentShape(Rectangle())
				.onTapGesture {
					if let action = toast.tapAction {
						Task { await action() }
					} else if toast.sharingTitle != nil {
						toast.share()
					}
					Achtung.instance.dismissToast(toast)
				}
				.background(
					GeometryReader { geometry in
						Color.clear
							.onAppear {
								#if os(iOS)
									baseFrame = geometry.frame(in: .global)
									print("Setting toast frame to \(baseFrame)")
									Achtung.instance.hostWindow?.activeToastFrame = baseFrame
								#endif
							}
					}
				)
				.frame(maxHeight: .infinity, alignment: .top)
				.onDisappear {
					#if os(iOS)
						Achtung.instance.hostWindow?.activeToastFrame = .zero
					#endif
				}
				.simultaneousGesture(
					DragGesture(minimumDistance: 20, coordinateSpace: .global)
						.onChanged { value in
							Achtung.instance.clearDismissTimer()
							dragOffset = value.translation.height//min(40, value.translation.height)
						}
						.onEnded { value in
							let translation = value.translation.height
							let predicted = value.predictedEndTranslation.height
							
							if translation < -flickThreshold || predicted < -flickPredictedThreshold {
								withAnimation(.easeIn(duration: Achtung.hideToastDuration)) {
									dragOffset = -200
								}
								Achtung.instance.dismissToast(toast)
							} else {
								withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
									dragOffset = 0
								}
							}
						}
				)
		}
	}
}

struct ToastView_Previews: PreviewProvider {
	static var previews: some View {
		ZStack() {
			Color.gray.ignoresSafeArea(.all)
			Achtung.ToastView(toast: .sample)
		}
	}
}
