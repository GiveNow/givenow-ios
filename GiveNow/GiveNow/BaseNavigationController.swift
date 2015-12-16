//
//  BaseNavigationController.swift
//  GiveNow
//
//  Created by Brennan Stehling on 12/16/15.
//  Copyright © 2015 GiveNow. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {
    
    // MARK: Base Overrides

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        if let topVC = self.topViewController {
            return topVC.preferredStatusBarStyle()
        }
        
        return .Default
    }
    
    // MARK: Embedding View Controllers -
    
    func fillSubview(subview : UIView, inSuperView superview : UIView) {
        let views : [ String : AnyObject ] = ["subview" : subview]
        let options = NSLayoutFormatOptions(rawValue: 0)
        superview.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[subview]|", options: options, metrics: nil, views: views))
        superview.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[subview]|", options: options, metrics: nil, views: views))
    }
    
    func embedViewController(vc : UIViewController, intoView superview : UIView) {
        self.embedViewController(vc, intoView: superview, placementBlock: nil)
    }
    
    func embedViewController(vc : UIViewController, intoView superview : UIView, placementBlock : ((UIView) -> Void)?) {
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChildViewController(vc)
        superview.addSubview(vc.view)
        
        if let placementBlock = placementBlock {
            placementBlock(vc.view)
        }
        else {
            self.fillSubview(vc.view, inSuperView: view)
        }
        
        vc.beginAppearanceTransition(true, animated: true)
        vc.didMoveToParentViewController(self)
        vc.endAppearanceTransition()
    }
    
    func removeEmbeddedViewController(vc : UIViewController) {
        vc.willMoveToParentViewController(self)
        vc.beginAppearanceTransition(false, animated: true)
        vc.view.removeFromSuperview()
        vc.removeFromParentViewController()
        vc.endAppearanceTransition()
    }
    
}
