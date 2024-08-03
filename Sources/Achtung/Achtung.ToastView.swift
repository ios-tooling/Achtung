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
			ToastBodyView(toast: toast)
			.frame(maxHeight: .infinity, alignment: .top)
			.transition(.move(edge: .top))
			.zIndex(100)
			.onTapGesture {
				if let action = toast.tapAction { action() }
				Achtung.instance.dismissCurrentToast()
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
