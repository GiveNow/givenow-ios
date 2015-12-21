//
//  Extensions.swift
//  GiveNow
//
//  Created by Evan Waters on 12/17/15.
//  Copyright © 2015 GiveNow. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    class func colorPrimary() -> UIColor {
        return UIColor(hue: 192/255, saturation: 100/255, brightness: 90/255, alpha: 1.0)
    }
    
    class func colorPrimaryDark() -> UIColor {
        return UIColor(hue: 191/255, saturation: 94/255, brightness: 65/255, alpha: 1.0)
    }
    
    class func colorPrimaryLight() -> UIColor {
        return UIColor(hue: 199/255, saturation: 11/255, brightness: 100/255, alpha: 1.0)
    }
    
    class func colorAccent() -> UIColor {
        return UIColor(hue: 123/255, saturation: 45/255, brightness: 73/255, alpha: 1.0)
    }
    
}




//<color name="colorPrimary">#ff00b9e6</color>
//<color name="colorPrimaryDark">#ff0a89a7</color>
//<color name="colorPrimaryLight">#ffe1f5fe</color>
//<color name="colorAccent">#ff66bb6a</color>