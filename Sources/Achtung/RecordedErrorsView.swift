//
//  RecordedErrorsView.swift
//
//
//  Created by Ben Gottlieb on 4/23/24.
//

import SwiftUI

public struct RecordedErrorsView: View {
	@ObservedObject private var achtung = Achtung.instance
	
	public init() {}
	
	public var body: some View {
		if achtung.recordedErrors.isEmpty {
			VStack {
				Spacer()
				if #available(iOS 17.0, macOS 14.0, *) {
					ContentUnavailableView(label: {
						Label("No Reported Errors", systemImage: "exclamationmark.triangle")
					}, description: {
						Text("As the application reports errors, they will be displayed here.")
					})
				} else {
					Text("No Reported Errors")
				}
				Spacer()
			}
		} else {
			VStack {
				List {
					ForEach(achtung.recordedErrors) { error in
						VStack(alignment: .leading) {
							if let message = error.title {
								Text(message)
							}
							
							Text(error.error.localizedDescription)
								.font(.caption)
							
							if #available(iOS 15.0, macOS 13, watchOS 10, *) {
								HStack(alignment: .bottom) {
									HStack(spacing: 0) {
										if let file = error.file { Text((file as NSString).lastPathComponent) }
										if let line = error.line { Text(":\(line)") }
									}
									if let function = error.function { Text(function) }
									
									Spacer()
									
									if let date = error.date {
										Text(date.formatted(date: .numeric, time: .complete))
											.multilineTextAlignment(.trailing)
									}
								}
								.font(.caption)
								.foregroundStyle(.secondary)
							}
						}
					}
				}
				Button("Clear Log") {
					achtung.clearRecord()
				}
			}
		}
	}
}

#Preview {
	RecordedErrorsView()
}
