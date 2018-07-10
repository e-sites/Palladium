//
//  Palladium.swift
//  Palladium
//
//  Created by Bas van Kuijck on 10/07/2018.
//  Copyright © 2018 E-sites. All rights reserved.
//

import Foundation
import UserNotifications

/// The general class
///
/// Use `Palladrium.shared` singleton.
public class Palladium {
    /// The singleton instance
    public static let shared = Palladium()
    
    fileprivate let notificationCenter = UNUserNotificationCenter.current()
    
    private init() {
        
    }
}

// MARK: - Authorization
// --------------------------------------------------------

extension Palladium {
    /// Request authorization to receive local notifications
    ///
    /// - Parameters:
    ///   - options: (Optional) `UNAuthorizationOptions`. Defaults to `[.alert, .badge, .sound]`
    ///   - handler: Called after the authorization finished. Arguments: (Optional) `Error`
    public func requestAuthorization(options: UNAuthorizationOptions? = nil,
                                     handler: @escaping ((Error?) -> Void)) {
        notificationCenter.getNotificationSettings { [unowned self] settings in
            switch settings.authorizationStatus {
            case .authorized:
                handler(nil)
                return
                
            case .denied:
                handler(Error.notAuthorized)
                return
                
            case .notDetermined:
                break
            }
            
            let options = options ?? UNAuthorizationOptions([.alert, .badge, .sound])
            self.notificationCenter.requestAuthorization(options: options) { result, error in
                if !result {
                    handler(Error.notAuthorized)

                } else if let error = error {
                    handler(Error.underlying(error))

                } else {
                    handler(nil)
                }
            }
        }
    }
}


// MARK: - Notification requests
// --------------------------------------------------------

extension Palladium {
    /// Creates a new `UNNotificationRequest` that fires on a specific `Date`
    ///
    /// - Warning: `date` should be in the future, else `Error.dateInPast` will be thrown in the `handler`.
    /// - Warning: Previously scheduled notifications with a specific `id` will be cancelled.
    ///
    /// - Parameters:
    ///   - content: `UNMutableNotificationContent`
    ///   - metaData: `MetaData`
    ///   - date: (Optional) `Date`. Default = now
    ///   - handler: `(UNNotificationRequest?, Error?) -> Void`
    public func add(content: UNMutableNotificationContent,
                    in metaData: MetaData,
                    at date: Date = Date(),
                    handler: ((UNNotificationRequest?, Error?) -> Void)? = nil) {
        if date < Date() {
            handler?(nil, Error.dateInPast)
            return
        }
        var dateComponents = Calendar.current.dateComponents([ .year, .month, .day, .hour, .minute, .second ],
                                                             from: date)
        dateComponents.timeZone = TimeZone.current
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        add(content: content, in: metaData, trigger: trigger, handler: handler)
    }

    /// Creates a new `UNNotificationRequest` that fires from the given trigger
    ///
    /// - Parameters:
    ///   - content: `UNMutableNotificationContent`
    ///   - metaData: `MetaData`
    ///   - trigger: `UNCalendarNotificationTrigger`
    ///   - handler: `(UNNotificationRequest?, Error?) -> Void`
    public func add(content: UNMutableNotificationContent,
                    in metaData: MetaData,
                    trigger: UNCalendarNotificationTrigger,
                    handler: ((UNNotificationRequest?, Error?) -> Void)? = nil) {
        cancelNotification(id: metaData.id) { _, error in
            if let error = error {
                handler?(nil, error)
                return
            }
            content.userInfo[Constant.Key.id.name] = metaData.id

            if let category = metaData.category {
                content.userInfo[Constant.Key.category.name] = category

                if let group = metaData.group {
                    content.userInfo[Constant.Key.group.name] = group
                }
            }
            content.userInfo[Constant.Key.tags.name] = metaData.tags

            let notificationRequest = UNNotificationRequest(identifier: UUID().uuidString,
                                                            content: content,
                                                            trigger: trigger)

            self.notificationCenter.add(notificationRequest) { error in
                if let error = error {
                    handler?(nil, Error.underlying(error))
                } else {
                    handler?(notificationRequest, nil)
                }
            }
        }
    }
}

// MARK: - Cancellation
// --------------------------------------------------------

extension Palladium {
    private func _cancelNotifications(filter: @escaping ((UNNotificationRequest) -> Bool),
                                      handler: (([String]?, Error?) -> Void)? = nil) {
        requestAuthorization { [unowned self] error in
            if let error = error {
                handler?(nil, error)
                return
            }
            
            self.notificationCenter.getPendingNotificationRequests { [unowned self] requests in
                let identifiers = requests.filter { filter($0) }.map { $0.identifier }
                self.notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
                handler?(identifiers, nil)
            }
        }
    }

    /// Cancels a specific notification with a given unique ID
    ///
    /// - Parameters:
    ///  - id: `String`
    ///  - handler: `([String]?, Error?) -> Void`. Returns the request identifier or and error
    public func cancelNotification(id: String, handler: (([String]?, Error?) -> Void)? = nil) {
        _cancelNotifications(filter: {
            $0.identifier == id
        }, handler: handler)
    }

    /// Cancels a set of notifications with a specific metadata setup
    ///
    /// - Warning: Either `category`, `group` and/or `tags` should be used. Else a fatal error will be thrown.
    ///
    /// - Parameters:
    ///  - category: (Optional) `String`
    ///  - group: (Optional) `String`. `category` must be entered.
    ///  - tags: (Optional) `[String]`. All the tags the notification should hold
    ///  - handler: (Optional) `([String]?, Error?) -> Void`
    public func cancelNotifications(category: String? = nil,
                                    group: String? = nil,
                                    tags: [String] = [],
                                    handler: (([String]?, Error?) -> Void)? = nil) {
        if group != nil && category == nil {
            fatalError("`category` should be specified in order to use a `group`")
            
        } else if category == nil && group == nil && tags.isEmpty {
            fatalError("You must at least specify any of the following: `category`, `group` and/or `tags`")
        }
        
        _cancelNotifications(filter: { request -> Bool in
            if let category = category {
                if category == (request.content.userInfo[Constant.Key.category.name] as? String) {
                    if let group = group, group != (request.content.userInfo[Constant.Key.group.name] as? String) {
                        return false
                    }
                } else {
                    return false
                }
            }
            
            let contentTags = (request.content.userInfo[Constant.Key.tags.name] as? [String]) ?? []
            for tag in tags {
                if !contentTags.contains(tag) {
                    return false
                }
            }
            return true
            
        }, handler: handler)
    }

    /// Cancels all pending notifications
    public func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
}
