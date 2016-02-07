//
//  Extensions.swift
//  GiveNow
//
//  Created by Evan Waters on 12/17/15.
//  Copyright © 2015 GiveNow. All rights reserved.
//

import Foundation
import UIKit
import MapKit

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
    
    class func colorAccentDisabled() -> UIColor {
        return UIColor(red: 141/255, green: 174/255, blue: 142/255, alpha: 1.0)
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
    
    func addShadow() {
        layer.shadowColor = UIColor.darkGrayColor().CGColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSizeMake(3.0, 3.0)
        layer.shadowRadius = 2.0
    }
    
    func removeShadow() {
        layer.shadowOpacity = 0.0
    }
    
    func toggleShadowOff() {
        UIView.animateWithDuration(0.5, animations: {
            self.removeShadow()
            })
    }
    
    func toggleShadowOn() {
        UIView.animateWithDuration(0.5, animations: {
            self.addShadow()
            })
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

extension MKMapView {
    
    func centerMapOnMapItem(mapItem: MKMapItem) {
        let currentRegion = region
        let newCenter = coordinatesForMapItem(mapItem)
        let newRegion = MKCoordinateRegion(center: newCenter, span: currentRegion.span)
        setRegion(newRegion, animated: true)
    }
    
    func coordinatesForMapItem(mapItem: MKMapItem) -> CLLocationCoordinate2D {
        return mapItem.placemark.coordinate
    }
    
}

extension MKMapItem {
    
    func getName() -> String {
        if let name = name {
            return name
        }
        else {
            return ""
        }
    }
    
    func getAddress() -> String {
        var address = ""
        if let addressDictionary = placemark.addressDictionary {
            address = getAddressFromAddressDictionary(addressDictionary)
        }
        return address
    }
    
    private func getAddressFromAddressDictionary(addressDictionary: [NSObject: AnyObject]) -> String {
        var address = ""
        if let formattedAddressLines = addressDictionary["FormattedAddressLines"] as? [String] {
            for line in formattedAddressLines {
                address += line + " "
            }
        }
        return address
    }
    
}

extension String {
    
    static func localizedString(key: String) -> String {
        return NSLocalizedString(key, comment: "")
    }
    
    static func localizedStringWithParameters(key: String, phoneNumber: String?, name: String?, code: String?) -> String {
        var string = NSLocalizedString(key, comment: "")
        if let phoneNumber = phoneNumber {
            string = string.stringByReplacingOccurrencesOfString("{PhoneNumber}", withString: phoneNumber)
        }
        if let name = name {
            string = string.stringByReplacingOccurrencesOfString("{Name}", withString: name)
        }
        if let code = code {
            string = string.stringByReplacingOccurrencesOfString("{code}", withString: code)
        }
        return string
    }
    
}

