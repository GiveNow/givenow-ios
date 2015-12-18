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
    
    private var _keys : [String : AnyObject]?
    
    static func sharedInstance() -> AppState {
        return AppState._sharedInstance
    }
    
    var isUserLoggedIn : Bool {
        get {
            return !PFAnonymousUtils.isLinkedWithUser(PFUser.currentUser())
        }
    }
    
    var keys : [String : AnyObject]? {
        get {
            if _keys != nil {
                return _keys
            }
            if let path = NSBundle.mainBundle().pathForResource("Keys", ofType: "plist"),
                let dictionary = NSDictionary(contentsOfFile: path) as? [String : AnyObject] {
                    _keys = dictionary
                    return dictionary
            }
            
            return nil
        }
    }
    
    var parseApplicationId : String? {
        if let keys = self.keys,
            let applicationId = keys["ParseApplicationId"] as? String {
                return applicationId
        }
        
        return nil
    }
    
    var parseClientKey : String? {
        if let keys = self.keys,
            let clientKey = keys["ParseClientKey"] as? String {
                return clientKey
        }
        
        return nil
    }
    
    var mapboxToken : String? {
        if let keys = self.keys,
            let token = keys["MapboxToken"] as? String {
                return token
        }
        
        return nil
    }

}
