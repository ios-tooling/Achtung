//
//  File.swift
//  Achtung
//
//  Created by Ben Gottlieb on 11/19/25.
//

import Foundation

public extension Error {
	var decodingDescription: String? {
		guard let error = self as? DecodingError else { return nil }
		
		return switch error {
		case .typeMismatch(let key, let context):
			"Type Mismatch \(key), path: \(context.pathDescription)"
		case .valueNotFound(let key, let context):
			"Value not Found error \(key), path: \(context.pathDescription)"
		case .keyNotFound(let key, let context):
			"Key not Found error \(key), path: \(context.pathDescription)"
		case .dataCorrupted(let key):
			"error \(key): \(error.localizedDescription)"
		default:
			"ERROR: \(error.localizedDescription)"
		}
	}
}

extension DecodingError.Context {
	var pathDescription: String {
		return codingPath.map( {
			if let index = $0.intValue {
				"[\(index)]"
			} else {
				$0.stringValue
			}
		}).joined(separator: ", ")
	}
}
