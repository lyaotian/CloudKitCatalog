/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    This is the navigation bar that contains NotificationBar as a subview.
*/

import UIKit
import CloudKit

class NavigationBar: UINavigationBar {

    var notificationBar: NotificationBar!
    
    required init?(coder aDecoder: NSCoder) {
        notificationBar = NotificationBar(coder: aDecoder)
        super.init(coder: aDecoder)
        barStyle = .black
        barTintColor = UIColor(red: 0.25, green: 0.29, blue: 0.36, alpha: 1.0)
        tintColor = UIColor.white
        
        addSubview(notificationBar)
        
        let leftConstraint = NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: notificationBar, attribute: .leading, multiplier: 1.0, constant: 0.0)
        addConstraint(leftConstraint)
        
        let rightConstraint = NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: notificationBar, attribute: .trailing, multiplier: 1.0, constant: 0.0)
        addConstraint(rightConstraint)
        
        let topConstraint = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: notificationBar, attribute: .top, multiplier: 1.0, constant: 0.0)
        addConstraint(topConstraint)
        
    }
    
    func showNotificationAlert(_ notification: CKNotification) {
        if notificationBar.notification == nil {
            notificationBar.notification = notification
            bringSubview(toFront: notificationBar)
            notificationBar.show()
        }
    }
}
