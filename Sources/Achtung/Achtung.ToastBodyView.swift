//
//  ToastBodyView.swift
//  Achtung
//
//  Created by Ben Gottlieb on 8/3/24.
//

import SwiftUI

@MainActor struct ToastBodyView: View {
	let toast: Achtung.Toast
	
	var body: some View {
		ZStack(alignment: .top) {
			HStack() {
				if let leading = toast.leading as? AnyView {
					leading
				}
				VStack() {
					VStack(alignment: .leading) {
						if let title = toast.title {
							Text(title)
						}
						if let message = toast.message {
							Text(message)
						}
					}
					if let accessoryView = toast.accessoryView as? AnyView {
						accessoryView
					}
				}
				.multilineTextAlignment(.leading)
				.lineLimit(3)
				.font(toast.messageFont)
				.opacity(0.8)
			}
			.font(toast.titleFont)
			.padding()
			.foregroundColor(toast.foregroundColor ?? Achtung.instance.toastForegroundColor)
			.background(backgroundView)
			.multilineTextAlignment(.center)
			.padding(4)
			.background(
				GeometryReader { geometry in
					Color.clear
						.onAppear {
							Achtung.instance.hostWindow?.activeToastFrame = geometry.frame(in: .global)
						}
				}
			)
		}
	}
	
	var backgroundView: some View {
		ZStack() {
			RoundedRectangle(cornerRadius: toast.cornerRadius)
				.fill(toast.backgroundColor ?? Achtung.instance.toastBackgroundColor)
			RoundedRectangle(cornerRadius: toast.cornerRadius)
				.stroke(toast.borderColor ?? Achtung.instance.toastBorderColor, lineWidth: toast.borderWidth)
		}
	}

}
