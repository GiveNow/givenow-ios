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
    
    static func localizeNotificationMessage(dictionary: [NSObject : AnyObject ]) -> String {
        let json = JSON(dictionary)
        print(json)
        if let notification = json["data"]["alert"].string {
            return notification
        }
        else {
            return ""
        }
//        let locKey = json["data"]["alert"]["loc-key"].string
//        
//        var name:String?
//        if let nameValue = json["data"]["alert"]["loc-args"][0].string {
//            name = nameValue
//        }
//        let notification = String.localizedStringWithParameters(locKey!, phoneNumber: nil, name: name!, code: nil)
//        return notification
    }
    
    static func localizeNotificationTitle(dictionary: [NSObject : AnyObject]) -> String {
        let json = JSON(dictionary)
        if let title = json["data"]["title"].string {
            return title
        }
        else {
            return ""
        }
        
//        var title:String!
//        if let titleKey = json["data"]["title"]["loc-key"].string {
//            title = String.localizedString(titleKey)
//        }
//        else {
//            title = String.localizedString("notification_received")
//        }
//        
//        return title
    }

}
