//
//  AppState.swift
//  GiveNow
//
//  Created by Brennan Stehling on 12/16/15.
//  Copyright © 2015 GiveNow. All rights reserved.
//

import UIKit
import Parse

class AppState: NSObject {
    
    static let _sharedInstance = AppState()
    
    static func sharedInstance() -> AppState {
        return AppState._sharedInstance
    }
    
    var isUserRegistered : Bool {
        get {
            return !PFAnonymousUtils.isLinkedWithUser(PFUser.currentUser())
        }
    }
    
    var userPhoneNumber : String? {
        get {
            if self.isUserRegistered {
                if let user = PFUser.currentUser(),
                    let username = user.username {
                        if username.characters.count == 10 ||
                            username.characters.count == 11 {
                                return username
                        }
                }
            }
            
            return nil
        }
    }

}
