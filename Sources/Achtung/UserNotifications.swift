//
//  AchtungNotifications.swift
//
//
//  Created by Ben Gottlieb on 5/17/24.
//

import UserNotifications
import SwiftUI

@available(iOS 16.0, macOS 13, *)
@MainActor public class AchtungNotifications: NSObject {
	public static let instance = AchtungNotifications()
	var notificationTappedClosure: (@MainActor (String, String) async -> Void)?

	/// The delegate the host app had installed before we took over; unhandled
	/// callbacks and non-Achtung notifications are forwarded to it.
	weak var forwardedDelegate: UNUserNotificationCenterDelegate?
	var achtungNotificationIDs: Set<String> = []

	var isAuthorized = false
	
	@MainActor var isAuthorizedForCurrentState: Bool {
		if isAuthorized { return true }
		
//		#if os(iOS)
//			if UIApplication.shared.applicationState == .active { return true }
//		#endif
		
		return false
	}
	
	public func setup() async {
		let options = await UNUserNotificationCenter.current().notificationSettings()
		isAuthorized = options.alertSetting == .enabled
	}
	
	public func requestPermissions() async throws {
		isAuthorized = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
		becomeNotificationCenterDelegate()
	}

	/// Installs Achtung as the notification center delegate without losing an
	/// existing delegate: the host app's delegate keeps receiving callbacks for
	/// notifications Achtung didn't schedule.
	public func becomeNotificationCenterDelegate() {
		let center = UNUserNotificationCenter.current()
		if let existing = center.delegate, existing !== self { forwardedDelegate = existing }
		center.delegate = self
	}
	
	public func setNotificationTappedClosure(_ closure: (@MainActor (String, String) async -> Void)?) {
		notificationTappedClosure = closure
	}
	
	@discardableResult public func playSound(named: String, at date: Date? = nil) -> String {
		let triggerDate = date ?? .now
		let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.day, .month, .year, .hour, .minute, .second, .nanosecond], from: triggerDate.addingTimeInterval(0.01)), repeats: false)
		let content = UNMutableNotificationContent()
		content.sound = UNNotificationSound(named: UNNotificationSoundName(named))
		let id = UUID().uuidString
		let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

		achtungNotificationIDs.insert(id)
		UNUserNotificationCenter.current().add(request)
		return id
	}

	@discardableResult public func setBadge(count: Int, at date: Date? = nil) -> String? {
		guard let date else {
			UNUserNotificationCenter.current().setBadgeCount(count)
			return nil
		}
		let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.day, .month, .year, .hour, .minute, .second, .nanosecond], from: date.addingTimeInterval(0.01)), repeats: false)
		let content = UNMutableNotificationContent()
		content.badge = NSNumber(value: count)
		let id = UUID().uuidString
		let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

		achtungNotificationIDs.insert(id)
		UNUserNotificationCenter.current().add(request)
		return id
	}

	func show(toast: Achtung.Toast) async -> Bool {
		let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.01, repeats: false)
		let content = UNMutableNotificationContent()
		content.body = toast.message ?? ""
		content.title = toast.title ?? ""

		becomeNotificationCenterDelegate()

		do {
			let request = UNNotificationRequest(identifier: toast.id, content: content, trigger: trigger)
			achtungNotificationIDs.insert(toast.id)
			try await UNUserNotificationCenter.current().add(request)
			return true
		} catch {
			achtungNotificationIDs.remove(toast.id)
			print("Failed to present toas: \(error)")
			return false
		}
	}

	public func cancel(withID id: String) {
		achtungNotificationIDs.remove(id)
		UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
	}
}

@available(iOS 16.0, macOS 13, *)
extension AchtungNotifications: UNUserNotificationCenterDelegate {
	public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping @Sendable (UNNotificationPresentationOptions) -> Void) {
		let selector = #selector(UNUserNotificationCenterDelegate.userNotificationCenter(_:willPresent:withCompletionHandler:))
		if !achtungNotificationIDs.contains(notification.request.identifier), let forwarded = forwardedDelegate, forwarded.responds(to: selector) {
			forwarded.userNotificationCenter?(center, willPresent: notification, withCompletionHandler: completionHandler)
			return
		}
		completionHandler([.banner, .badge, .sound])
	}

	public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping @Sendable () -> Void) {
		let id = response.notification.request.identifier
		let selector = #selector(UNUserNotificationCenterDelegate.userNotificationCenter(_:didReceive:withCompletionHandler:))
		if !achtungNotificationIDs.contains(id), let forwarded = forwardedDelegate, forwarded.responds(to: selector) {
			forwarded.userNotificationCenter?(center, didReceive: response, withCompletionHandler: completionHandler)
			return
		}
		achtungNotificationIDs.remove(id)
		Task {
			await notificationTappedClosure?(id, response.actionIdentifier)
		}
		completionHandler()
	}

	#if os(iOS) || os(macOS) || os(visionOS)
	public func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
		forwardedDelegate?.userNotificationCenter?(center, openSettingsFor: notification)
	}
	#endif
}
