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
    
    var isUserLoggedIn : Bool {
        get {
            return PFUser.currentUser() != nil
        }
    }

}
