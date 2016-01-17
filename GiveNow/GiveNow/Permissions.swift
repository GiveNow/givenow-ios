//
//  Permissions.swift
//  GiveNow
//
//  Created by Brennan Stehling on 1/16/16.
//  Copyright © 2016 GiveNow. All rights reserved.
//

import UIKit

var IsSimulator : Bool {
    #if (arch(i386) || arch(x86_64)) && (os(iOS) || os(watchOS) || os(tvOS))
        return true
    #else
        return false
    #endif
}

public enum SystemPermissionStatus : Int {
    case NotDetermined = 0
    case Allowed
    case Denied
}

public let PromptedForNotificationsPermissionKey = "PromptedForNotificationsPermissionKey"

class Permissions: NSObject {
    
    static func systemStatusForNotifications() -> SystemPermissionStatus {
        if IsSimulator {
            return .Allowed
        }
        
        let settings = UIApplication.sharedApplication().currentUserNotificationSettings()
        if let settingTypes = settings?.types where settingTypes != .None {
            return .Allowed
        }
        else {
            if NSUserDefaults.standardUserDefaults().boolForKey(PromptedForNotificationsPermissionKey) &&
                UIApplication.sharedApplication().applicationState == .Active {
                    return .Denied
            }
        }
        
        return .NotDetermined
    }
    
    static func registerForNotificationsPermission() {
        if IsSimulator {
            // do nothing
            return
        }
        
        let status = systemStatusForNotifications()
        
        if status == .NotDetermined {
            // When the system prompt comes up the app itself becomes inactive
            // which is important for determining the system status. It takes
            // a moment for the prompt to appear which is why there is a delay
            // before setting the user default below.
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.25 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(NSNumber(bool: true), forKey:PromptedForNotificationsPermissionKey)
                defaults.synchronize()
            }
        }
        
        if status == .NotDetermined || status == .Allowed {
            let application = UIApplication.sharedApplication()
            
            let action = UIMutableUserNotificationAction()
            action.title = "View"
            action.identifier = "View"
            
            let category = UIMutableUserNotificationCategory()
            category.identifier = "Alerts"
            category.setActions([action], forContext: .Default)
            category.setActions([action], forContext: .Minimal)
            
            let categories = NSSet(object: category) as! Set<UIUserNotificationCategory>
            let userNotificationTypes : UIUserNotificationType = [.Sound, .Alert, .Badge]
            let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: categories)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }
    }
    
    static func unregisterForNotificationsPermission() {
        if !IsSimulator {
            let application = UIApplication.sharedApplication()
            application.unregisterForRemoteNotifications()
        }
    }

}
