//
//  MyLocationButton.swift
//  GiveNow
//
//  Created by Evan Waters on 1/13/16.
//  Copyright © 2016 GiveNow. All rights reserved.
//

import UIKit

class MyLocationButton: UIButton {

    override func awakeFromNib() {
        layer.cornerRadius = frame.size.width / 2
        layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        layer.shadowColor = UIColor.darkGrayColor().CGColor
        layer.shadowRadius = 5.0
        
        if let image = UIImage(named: "my-location") {
        
            self.setImage(image.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        }
        
        self.tintColor = UIColor.grayColor()
        
        super.awakeFromNib()
    }

}
