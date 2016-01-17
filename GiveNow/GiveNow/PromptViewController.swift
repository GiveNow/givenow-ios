//
//  PromptViewController.swift
//  GiveNow
//
//  Created by Evan Waters on 1/16/16.
//  Copyright © 2016 GiveNow. All rights reserved.
//

import UIKit

class PromptViewController: BaseViewController {
    
    var promptImage:UIImageView!
    var promptHeader:UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        layoutView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func layoutView() {
        
        // Add image
        promptImage = UIImageView(frame: CGRect(x: 20, y: 20, width: 30, height: 30))
        if let image = UIImage(named: "round_icon") {
            promptImage.image = image
        }
        
        // Add header label
        promptHeader = UILabel(frame: CGRect(x: 60, y: 20, width: view.frame.width - 80, height: 30))
        promptHeader.font = UIFont.boldSystemFontOfSize(17.0)
        
    }

}
