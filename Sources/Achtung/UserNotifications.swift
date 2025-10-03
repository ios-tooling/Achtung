//
//  AchtungNotifications.swift
//
//
//  Created by Ben Gottlieb on 5/17/24.
//

import UserNotifications


@available(iOS 16.0, macOS 13, *)
public actor AchtungNotifications: NSObject {
	public static let instance = AchtungNotifications()
	var notificationTappedClosure: (@MainActor (String, String) async -> Void)?
	
	var isAuthorized = false
	
	public func requestPermissions() async throws {
		isAuthorized = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
		UNUserNotificationCenter.current().delegate = self
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
		
		UNUserNotificationCenter.current().add(request)
		return id
	}
	
	func show(toast: Achtung.Toast) {
		let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.01, repeats: false)
		let content = UNMutableNotificationContent()
		content.body = toast.message ?? ""
		content.title = toast.title ?? ""
		
		if UNUserNotificationCenter.current().delegate === self {
			UNUserNotificationCenter.current().delegate = AchtungNotifications.instance
		}
		
		let request = UNNotificationRequest(identifier: toast.id, content: content, trigger: trigger)
		UNUserNotificationCenter.current().add(request)
	}
	
	public func cancel(withID id: String) {
		UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
	}
}

@available(iOS 16.0, macOS 13, *)
extension AchtungNotifications: UNUserNotificationCenterDelegate {
	public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
		[.banner, .badge, .sound]
	}

	public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
		Task {
			guard let closure = notificationTappedClosure else { return }
			await closure(response.notification.request.identifier, response.actionIdentifier)
		}
	}
}
