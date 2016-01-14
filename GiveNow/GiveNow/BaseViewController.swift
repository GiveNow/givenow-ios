//
//  BaseViewController.swift
//  GiveNow
//
//  Created by Brennan Stehling on 12/16/15.
//  Copyright © 2015 GiveNow. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    // MARK: Base Overrides

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .Default
    }
    
    // MARK: Table Views
    
    func tableViewCellForView(view : UIView?) -> UITableViewCell? {
        var superview : UIView? = view?.superview
        while superview != nil {
            if let cell = superview as? UITableViewCell {
                return cell
            }
            
            superview = superview?.superview
        }
        
        return nil
    }
    
    // MARK: Collection Views
    
    func collectionViewCellForView(view : UIView?) -> UICollectionViewCell? {
        var superview : UIView? = view?.superview
        while superview != nil {
            if let cell = superview as? UICollectionViewCell {
                return cell
            }
            
            superview = superview?.superview
        }
        
        return nil
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
        
        vc.didMoveToParentViewController(self)
    }
    
    func removeEmbeddedViewController(vc : UIViewController) {
        vc.willMoveToParentViewController(self)
        vc.view.removeFromSuperview()
        vc.removeFromParentViewController()
    }
    
    func fetchViewControllerFromStoryboard(storyboardName: String, storyboardIdentifier: String) -> UIViewController {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(storyboardIdentifier)
        return vc
    }

}
