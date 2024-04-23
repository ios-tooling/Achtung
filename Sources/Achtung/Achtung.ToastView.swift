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
		var body: some View {
			ZStack(alignment: .top) {
				HStack() {
					if let leading = toast.leading {
						leading
					}
					VStack(alignment: .leading) {
						Text(toast.title)
						if let body = toast.body {
							Text(body)
								.multilineTextAlignment(.leading)
								.lineLimit(3)
								.font(toast.bodyFont)
								.opacity(0.8)
						}
					}
				}
				.font(toast.titleFont)
				.padding()
				.foregroundColor(toast.foregroundColor ?? Achtung.instance.toastForegroundColor)
				.background(backgroundView)
				.multilineTextAlignment(.center)
				.padding(4)
			}
			.frame(maxHeight: .infinity, alignment: .top)
			.transition(.move(edge: .top))
			.zIndex(100)
			.onTapGesture {
				if let action = toast.tapAction { action() }
				Achtung.instance.dismissCurrentToast()
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
	
	
}

struct ToastView_Previews: PreviewProvider {
	static var previews: some View {
		ZStack() {
			Color.gray.edgesIgnoringSafeArea(.all)
			Achtung.ToastView(toast: .sample)
		}
	}
}
