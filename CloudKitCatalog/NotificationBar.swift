/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    This class describes the notification bar that is shown when a CloudKit notification is received.
*/

import UIKit
import CloudKit

class NotificationBar: UIView {

    var notification: CKNotification? {
        didSet {
            if let navigationController = window!.rootViewController as? UINavigationController {
                for viewController in navigationController.viewControllers {
                    viewController.navigationItem.hidesBackButton = (notification != nil)
                }
            }
            setNeedsLayout()
            self.superview!.layoutIfNeeded()
        }
    }
    
    var heightConstraint: NSLayoutConstraint!
    
    var label: UILabel!
    var button: UIButton!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        heightConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0.0)
        translatesAutoresizingMaskIntoConstraints = false

        backgroundColor = UIColor.black
        
        addConstraint(heightConstraint)
        
        label = UILabel()
        label.text = "You have a new CloudKit notification!"
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        label.isUserInteractionEnabled = true
        
        addSubview(label)
        
        button = UIButton()
        button.setTitle("✕", for: .normal)
        button.addTarget(self, action: #selector(NotificationBar.close), for: .touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        
        addSubview(button)
        
        let rightConstraint = NSLayoutConstraint(item: self, attribute: .rightMargin, relatedBy: .equal, toItem: button, attribute: .right, multiplier: 1.0, constant: 0.0)
        addConstraint(rightConstraint)
        
        let centerConstraint = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: button, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        addConstraint(centerConstraint)
        
        let leftConstraint = NSLayoutConstraint(item: self, attribute: .leftMargin, relatedBy: .equal, toItem: label, attribute: .left, multiplier: 1.0, constant: 0.0)
        addConstraint(leftConstraint)
        
        let rightLabelConstraint = NSLayoutConstraint(item: button, attribute: .left, relatedBy: .equal, toItem: label, attribute: .right, multiplier: 1.0, constant: 8.0)
        addConstraint(rightLabelConstraint)

        let centerLabelConstraint = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: label, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        addConstraint(centerLabelConstraint)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(NotificationBar.showNotification))
        label.addGestureRecognizer(tapGestureRecognizer)

    }
    
    @objc func close() {
        UIView.animate(withDuration: 0.4, animations: {
            self.label.isHidden = true
            self.button.isHidden = true
            self.heightConstraint.constant = 0
            self.notification = nil
        })
    }
    
    func show() {
        UIView.animate(withDuration: 0.4, animations: {
            self.heightConstraint.constant = self.superview!.frame.size.height
            self.label.isHidden = false
            self.button.isHidden = false
            self.superview!.layoutIfNeeded()
        })
    }
    
    @objc func showNotification() {
        if let _ = notification, let navigationController = window?.rootViewController as? NavigationController, let mainMenuViewController = navigationController.viewControllers.first as? MainMenuTableViewController {
            close()
            if let topViewController = navigationController.topViewController as? CodeSampleViewController , topViewController.selectedCodeSample is MarkNotificationsReadSample {
                topViewController.runCode(sender: topViewController.runButton)
            } else {
                let notificationSample = mainMenuViewController.codeSampleGroups.last!.codeSamples.first
                navigationController.performSegue(withIdentifier: "ShowLoadingView", sender: notificationSample)
            }
        }
    }
    

}
