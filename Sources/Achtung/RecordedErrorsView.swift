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
							if let message = error.message {
								Text(message)
							}
							
							Text(error.error.localizedDescription)
								.font(.caption)
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
