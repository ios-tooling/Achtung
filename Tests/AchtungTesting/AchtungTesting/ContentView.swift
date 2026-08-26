//
//  ContentView.swift
//  AchtungTesting
//
//  Created by Ben Gottlieb on 1/27/26.
//

import SwiftUI
import Foundation
import Achtung

struct ContentView: View {
    @State private var alertFieldText = ""

	var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Toasts")
                        .font(.headline)

                    Button("Toast: Title Only") {
                        showToast(.init("Quick toast"))
                    }

						 Button("Toast: Title + Message") {
							  showToast(.init("Saved", message: "Your changes are now synced."))
						 }

						 Button("Toast: Title + Sharing") {
							  showToast(.init("I'm going to share this toast now", sharingTitle: "Share"))
						 }

                    Button("Toast: Error") {
                        let error = NSError(
                            domain: "AchtungTesting",
                            code: 404,
                            userInfo: [NSLocalizedDescriptionKey: "Could not find the requested item."]
                        )
                        showToast(.init("Error Occurred", error: error))
                    }

                    Button("Toast: Custom Colors") {
                        showToast(.init(
                            "Custom Colors",
                            foreground: .yellow,
                            border: .red,
                            background: .blue
                        ))
                    }

                    Button("Toast: Native Style") {
                        showToast(.init("Native Toast", .native))
                    }

                    Button("Toast: Custom Style") {
                        showToast(.init("Custom Toast", .custom))
                    }

                    Button("Toast: Tap Action") {
                        showToast(.init(
                            "Tap Me",
                            message: "Tapping will show another toast.",
                            tapAction: {
                                await Achtung.instance.show(toast: .init("Tapped"))
                            }
                        ))
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Alerts")
                        .font(.headline)

                    Button("Alert: Simple OK") {
                        showAlert(.init("Hello", buttons: [.ok()]))
                    }

                    Button("Alert: Message + Buttons") {
                        showAlert(.init(
                            "Confirm Delete",
                            message: Text("This action cannot be undone."),
                            buttons: [.cancel(), .destructive(Text("Delete"))]
                        ))
                    }

                    Button("Alert: Text Field") {
                        showAlert(.init(
                            "Enter Name",
                            fieldText: $alertFieldText,
                            fieldPlaceholder: "Type here",
                            buttons: [
                                .cancel(),
                                .ok(Text("Save")) {
                                    showToast(.init("Saved", message: alertFieldText))
                                }
                            ]
                        ))
                    }

                    Button("Alert: Colored") {
                        showAlert(.init(
                            "Custom Colors",
                            foreground: .white,
                            border: .blue,
                            background: .black,
                            buttons: [.ok()]
                        ))
                    }

                    Button("Alert: Tap Outside to Dismiss") {
                        showAlert(.init(
                            "Tap Outside",
                            tapOutsideToDismiss: true,
                            buttons: [.ok()]
                        ))
                    }
                }

                if #available(iOS 17.0, macOS 14.0, *) { BubbleButtons() }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Errors")
                        .font(.headline)

                    Button("Handle Error (Display)") {
                        Task {
                            let error = NSError(domain: "DisplayDomain", code: 1)
									Achtung.instance.configuration.errorDisplayLevel = .standard
                            Achtung.instance.configuration.filterError = { _ in .display }
                            await Achtung.instance.handle(error, level: .standard)
                        }
                    }

                    Button("Handle Error (Log Only)") {
                        Task {
                            let error = NSError(domain: "LogDomain", code: 2)
                            Achtung.instance.configuration.filterError = { _ in .log }
                            await Achtung.instance.handle(error, level: .standard)
                        }
                    }

                    Button("Handle Error (Ignore)") {
                        Task {
                            let error = NSError(domain: "IgnoreDomain", code: 3)
                            Achtung.instance.configuration.filterError = { _ in .ignore }
                            await Achtung.instance.handle(error, level: .standard)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .buttonStyle(.bordered)
	}

    private func showToast(_ toast: Achtung.Toast) {
        Task {
            await Achtung.instance.show(toast: toast)
        }
    }

    private func showAlert(_ alert: Achtung.Alert) {
        Achtung.instance.show(alert: alert)
    }
}

#Preview {
	ContentView()
}
