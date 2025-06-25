//
//  Share.swift
//  Achtung
//
//  Created by Ben Gottlieb on 6/24/25.
//

#if canImport(UIKit)
	import UIKit


@available(iOSApplicationExtension, unavailable)
extension UIApplication {
	static func share(something: [Any]) {
		shared.currentWindow?.rootViewController?.presentedest.share(something: something)
	}
}

extension UIViewController {
	func share(something: [Any], fromItem barButtonItem: UIBarButtonItem? = nil, fromView: UIView? = nil) {
		guard !something.isEmpty else { return }
		let activityVC = UIActivityViewController(activityItems: something, applicationActivities: nil)
		if let barButtonItem = barButtonItem {
			activityVC.popoverPresentationController?.barButtonItem = barButtonItem
		} else if let view = fromView {
			activityVC.popoverPresentationController?.sourceView = view
			activityVC.popoverPresentationController?.sourceRect = view.bounds
		} else if let root = UIApplication.shared.currentWindow?.rootViewController?.presentedest.view {
			activityVC.popoverPresentationController?.sourceView = root
			activityVC.popoverPresentationController?.sourceRect = CGRect.zero
			
		}
		self.present(activityVC, animated: true, completion: nil)
	}
}


public extension UIViewController {
	var presentedest: UIViewController {
		return self.presentedViewController?.presentedest ?? self
	}
}

extension UIApplication {
	 var currentWindow: UIWindow? {
		if #available(iOS 13.0, *) {
			if let window = self.currentScene?.frontWindow { return window }
		}
		
		if let window = self.delegate?.window { return window }
		 #if os(visionOS)
			return nil
		 #else
			return self.windows.first
		 #endif
	 }

	var currentScene: UIWindowScene? {
		let scene = self.connectedScenes
			.filter { $0.activationState == .foregroundActive }
			.compactMap { $0 as? UIWindowScene }
			.first
		
		if let scene { return scene }
		
		return self.connectedScenes
			.filter { $0.activationState == .foregroundInactive }
			.compactMap { $0 as? UIWindowScene }
			.first
	}
}

public extension UIWindowScene {
	var frontWindow: UIWindow? {
		if let window = self.windows.first(where: { $0.isKeyWindow }) { return window }
		return self.windows.first
	}
}
#endif
