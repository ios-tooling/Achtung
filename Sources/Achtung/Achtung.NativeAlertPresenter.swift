//
//  Achtung.NativeAlertPresenter.swift
//  Achtung
//
//  Created by Ben Gottlieb on 9/17/26.
//

#if canImport(Combine)
import SwiftUI

@available(macOS 12, iOS 15.0, *)
extension Achtung {
	/// Presents the first pending `.native` alert as the platform's alert, over Achtung's window.
	struct NativeAlertPresenter: ViewModifier {
		@ObservedObject var achtung = Achtung.instance

		private var alert: Alert? { achtung.nativeAlert }

		private var isPresented: Binding<Bool> {
			Binding(
				get: { alert != nil },
				// the system dismisses on any button; the tap's own action has already run
				set: { shown in if !shown, let alert { achtung.remove(alert) } }
			)
		}

		func body(content: Content) -> some View {
			content
				.alert(alert?.title ?? Text(""), isPresented: isPresented, presenting: alert) { alert in
					if let fieldInfo = alert.fieldInfo {
						if #available(iOS 16.0, macOS 13.0, *) {
							TextField(fieldInfo.placeholder, text: fieldInfo.text)
						}
					}
					ForEach(alert.buttons) { button in
						SwiftUI.Button(role: button.role) { button.pressed() } label: { button.label }
					}
				} message: { alert in
					if let message = alert.message { message }
				}
		}
	}
}

extension Achtung.Button {
	var role: ButtonRole? {
		switch kind {
		case .cancel: .cancel
		case .destructive: .destructive
		case .normal: nil
		}
	}
}
#endif
