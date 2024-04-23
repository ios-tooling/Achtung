//
//  SwiftUIView.swift
//  
//
//  Created by Ben Gottlieb on 4/23/24.
//

import SwiftUI

public struct ShowAchtungReportedErrorsButton: View {
	@State private var showErrors = false
	@ObservedObject var achtung = Achtung.instance
	public init() {
		
	}
   
	public var body: some View {
		Button(action: { showErrors.toggle() }) {
			HStack(spacing: 3) {
				Image(systemName: "exclamationmark.triangle")
				if !achtung.recordedErrors.isEmpty {
					Text("\(achtung.recordedErrors.count)")
						.font(.caption).bold()
				}
			}
		}
		.sheet(isPresented: $showErrors, content: {
			RecordedErrorsView()
		})
    }
}

#Preview {
	ShowAchtungReportedErrorsButton()
}
