//
//  String.swift
//  Achtung
//
//  Created by Ben Gottlieb on 10/27/25.
//

import Foundation


public func fileDescription(_ file: StaticString, _ function: StaticString, _ line: UInt) -> String {
	let fileName = NSString(string: file.description).lastPathComponent
	let funcName = function.description.split(separator: "(").first!
	
	return "\(fileName):\(line) - \(funcName)"
}
