//
//  Achtung.Errors.swift
//  
//
//  Created by Ben Gottlieb on 5/31/23.
//

import Foundation

public extension Achtung {
	enum ErrorLevel: Int, Comparable { case debug, testing, standard
		public static func <(lhs: Self, rhs: Self) -> Bool { lhs.rawValue < rhs.rawValue }
	}
}

public extension Achtung {
	static func `do`(level: ErrorLevel = .testing, message: String? = nil, _ block: () throws -> Void) {
		do {
			try block()
		} catch {
			instance.show(error, level: level, message: message)
		}
	}
	
	func show(_ error: Error?, level: ErrorLevel = .standard, message: String? = nil) {
		guard let error else { return }
		
		if level >= errorDisplayLevel {
			let toast = Toast(title: message ?? "An error occurred", body: nil, error: error)
			show(toast: toast)
		}
		print("⚠️ \(message ?? "Achtung"): \(error)")
	}
}
