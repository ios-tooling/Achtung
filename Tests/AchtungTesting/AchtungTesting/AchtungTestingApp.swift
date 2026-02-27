//
//  AchtungTestingApp.swift
//  AchtungTesting
//
//  Created by Ben Gottlieb on 1/27/26.
//

import SwiftUI
import Achtung

@main
struct AchtungTestingApp: App {
	init() {
		Achtung.instance.setup()
		
	}
	
	var body: some Scene {
		WindowGroup {
			ContentView()
		}
	}
}
