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
        return UIColor(red: 0/255, green: 185/255, blue: 230/255, alpha: 1.0)
    }
    
    class func colorPrimaryDark() -> UIColor {
        return UIColor(red: 10/255, green: 137/255, blue: 167/255, alpha: 1.0)
    }
    
    class func colorPrimaryLight() -> UIColor {
        return UIColor(red: 225/255, green: 245/255, blue: 254/255, alpha: 1.0)
    }
    
    class func colorAccent() -> UIColor {
        return UIColor(red: 102/255, green: 187/255, blue: 106/255, alpha: 1.0)
    }
    
    class func colorAlternate() -> UIColor {
        return UIColor(red: 3.0/255.0, green: 155.0/255.0, blue: 229.0/255.0, alpha: 1.0)
    }
    
}

extension UIView {
    
    func addCustomUIView(frame: CGRect, backgroundColor: UIColor) {
        let view = UIView(frame: frame)
        view.backgroundColor = backgroundColor
        addSubview(view)
    }
    
    func addCustomUILabel(frame: CGRect, font: UIFont, textColor: UIColor) -> UILabel {
        let label = UILabel()
        label.frame = frame
        label.font = font
        label.textColor = textColor
        addSubview(label)
        return label
    }
    
}

extension UIImage {
    
    class func templatedImageFromName(name: String) -> UIImage {
        if let image = UIImage(named: name) {
            return image.imageWithRenderingMode(.AlwaysTemplate)
        }
        else {
            return UIImage()
        }
    }
    
}

extension UIViewController {
    
    func createModalLoginView(delegate: ModalLoginViewControllerDelegate) {
        let modalLogin = ModalLoginViewController()
        modalLogin.modalPresentationStyle = .OverFullScreen
        modalLogin.modalTransitionStyle = .CrossDissolve
        modalLogin.delegate = delegate
        presentViewController(modalLogin, animated: true, completion: {})
    }
    
}