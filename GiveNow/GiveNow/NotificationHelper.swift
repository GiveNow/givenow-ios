//
//  NotificationHelper.swift
//  GiveNow
//
//  Created by Evan Waters on 1/22/16.
//  Copyright © 2016 GiveNow. All rights reserved.
//

import UIKit
import SwiftyJSON

class NotificationHelper: NSObject {
    
    static func localizeNotificationMessage(dictionary: [ NSObject : AnyObject ]) -> String {
        let json = JSON(dictionary)
        let locKey = json["data"]["alert"]["loc-key"].string
        let name = json["data"]["alert"]["loc-args"][0].string
        
        var notification = ""
        if locKey != nil {
            notification = NSLocalizedString(locKey!, comment: "")
            print(notification)
        }
        if name != nil {
            notification = notification.stringByReplacingOccurrencesOfString("{Person}", withString: name!)
            print(notification)
        }
        
        return notification
    }
    
    static func localizeNotificationTitle(dictionary: [NSObject : AnyObject]) -> String {
        let json = JSON(dictionary)
        let titleKey = json["data"]["title"]["loc-key"].string
        var title = ""
        if titleKey != nil {
            title = NSLocalizedString(titleKey!, comment: "")
        }
        return title
    }

}
