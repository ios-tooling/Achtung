//
//  File.swift
//  
//
//  Created by Ben Gottlieb on 12/7/21.
//

import SwiftUI

extension Achtung {
	struct ToastView: View {
		let toast: Achtung.Toast
		var body: some View {
			ZStack(alignment: .top) {
				Text(toast.title)
					.font(toast.titleFont)
					.padding(.horizontal, 16)
					.padding(.vertical, 8)
					.foregroundColor(toast.textColor)
					.background(backgroundView)
					.padding()
			}
			.frame(maxHeight: .infinity, alignment: .top)
			.transition(.move(edge: .top))
			.zIndex(100)
			.onTapGesture {
				Achtung.instance.dismissCurrentToast()
			}
		}
		
		var backgroundView: some View {
			ZStack() {
				RoundedRectangle(cornerRadius: toast.cornerRadius)
					.fill(toast.backgroundColor)
				RoundedRectangle(cornerRadius: toast.cornerRadius)
					.stroke(toast.borderColor, lineWidth: toast.borderWidth)
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
