//
//  LocalizationHelper.swift
//  GiveNow
//
//  Created by Evan Waters on 1/22/16.
//  Copyright © 2016 GiveNow. All rights reserved.
//

import UIKit

class LocalizationHelper: NSObject {
    
    static func nameForDonor(pickupRequest: PickupRequest) -> String {
        var nameText:String!
        if let user = pickupRequest.donor?.fetchIfNeededInBackground().result as? User {
            if let name = user.name {
                nameText = name
            }
        }
        else {
            nameText = String.localizedString("a_volunteer")
        }
        return nameText
    }

}
