//
//  Achtung.Errors.swift
//  
//
//  Created by Ben Gottlieb on 5/31/23.
//

import Foundation

public extension Achtung {
	func show(_ error: Error?, message: String? = nil) {
		guard let error else { return }
		
		let toast = Toast(title: message ?? "An error occurred", body: nil, error: error)
		show(toast: toast)
		print("⚠️ \(message ?? "Achtung"): \(error)")
	}
}
