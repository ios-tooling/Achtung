//
//  Achtung.AlertStyle.swift
//  Achtung
//
//  Created by Ben Gottlieb on 9/17/26.
//

import SwiftUI

extension Achtung {
	/// How an alert is drawn: Achtung's own card, or the platform's standard alert.
	public enum AlertStyle: Sendable, Equatable {
		/// Achtung's card, in the configured colors, stacked in its own window.
		case custom
		/// The system alert — the same one SwiftUI's `.alert` shows. Text fields are supported
		/// on iOS 16 and macOS 13; the field's character limit is not enforced there.
		case native
	}
}

@available(macOS 10.15, iOS 13.0, *)
extension Achtung {
	/// An alert's own style, else the configuration's.
	func style(of alert: Alert) -> AlertStyle {
		alert.style ?? configuration.alertStyle
	}

	/// The pending alerts drawn as Achtung's cards.
	var customAlerts: [Alert] { pendingAlerts.filter { style(of: $0) == .custom } }

	/// The pending alert the system is asked to show; they take turns, oldest first.
	var nativeAlert: Alert? { pendingAlerts.first { style(of: $0) == .native } }
}
