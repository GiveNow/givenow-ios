//
//  Backend.swift
//  GiveNow
//
//  Created by Brennan Stehling on 12/16/15.
//  Copyright © 2015 GiveNow. All rights reserved.
//

import UIKit

// TODO: implement
// See https://github.com/GiveNow/givenow-ios/issues/3

// Integations with Parse and Mapbox geocoding

class Backend: NSObject {
    
    static let _sharedInstance = Backend()
    
    static func sharedInstance() -> Backend {
        return Backend._sharedInstance
    }

}
