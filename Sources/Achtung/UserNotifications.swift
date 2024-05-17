//
//  AchtungNotifications.swift
//
//
//  Created by Ben Gottlieb on 5/17/24.
//

#if os(iOS)

import UserNotifications


@available(iOS 15.0, *)
public actor AchtungNotifications: NSObject {
	public static let instance = AchtungNotifications()
	
	var isAuthorized = false
	
	public func requestPermissions() async throws {
		isAuthorized = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
		UNUserNotificationCenter.current().delegate = self
	}
	
	@discardableResult public func playSound(named: String, at date: Date = .now) -> String {
		let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.day, .month, .year, .hour, .minute, .second, .nanosecond], from: date.addingTimeInterval(0.01)), repeats: false)
		let content = UNMutableNotificationContent()
		content.sound = UNNotificationSound(named: UNNotificationSoundName(named))
		let id = UUID().uuidString
		let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
		
		UNUserNotificationCenter.current().add(request)
		return id
	}
	
	public func cancel(withID id: String) {
		UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
	}
}

@available(iOS 15.0, *)
extension AchtungNotifications: UNUserNotificationCenterDelegate {
	public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
		[.banner, .badge, .sound]
	}

}

#endif
