/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    This file handles registration for CloudKit Notifications as well as processing remote notifications when
                they are received.
*/

import UIKit
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        let settings = UIUserNotificationSettings(types: .alert, categories: nil)
        
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        if let userInfo = userInfo as? [String: NSObject] {
            let notification = CKNotification.init(fromRemoteNotificationDictionary: userInfo)
            let state = application.applicationState
            if let viewController = window?.rootViewController as? UINavigationController {
                if let tableViewController = viewController.viewControllers[0] as? MainMenuTableViewController {
                    let index = tableViewController.codeSampleGroups.count - 1
                    if let notificationSample = tableViewController.codeSampleGroups.last?.codeSamples.first as? MarkNotificationsReadSample {
                        notificationSample.cache.addNotification(notification: notification)
                        tableViewController.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                    }
                }
                if state == .active {
                    if let navigationBar = viewController.navigationBar as? NavigationBar {
                        navigationBar.showNotificationAlert(notification)
                    }
                }
                
            }
            
        }
    }
}

