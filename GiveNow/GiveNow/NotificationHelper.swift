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
    
    static func localizeNotificationMessage(json: JSON) -> String {
        if let notification = json["data"]["alert"].string {
            return notification
        }
        else {
            return ""
        }
    }
    
    static func localizeNotificationTitle(json: JSON) -> String {
        if let title = json["data"]["title"].string {
            return title
        }
        else {
            return ""
        }
    }

}
