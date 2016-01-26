//
//  Keys.swift
//  GiveNow
//
//  Created by Brennan Stehling on 12/19/15.
//  Copyright © 2015 GiveNow. All rights reserved.
//

import UIKit

class Keys: NSObject {
    
    static let _sharedInstance = Keys()
    
    private var _keys : [String : AnyObject]?
    
    static func sharedInstance() -> Keys {
        return Keys._sharedInstance
    }
    
    // MARK: Keys

    var parseApplicationId : String? {
        return stringForKey("ParseApplicationId")
    }
    
    var parseClientKey : String? {
        return stringForKey("ParseClientKey")
    }
    
    var mapboxToken : String? {
        return stringForKey("MapboxToken")
    }
    
    // MARK: Private
    
    private var keys : [String : AnyObject]? {
        get {
            if let _keys = _keys {
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
    
    private func stringForKey(key : String) -> String? {
        if let keys = self.keys,
            let greeting = keys[key] as? String {
                return greeting
        }
        
        return nil
    }
    
}
