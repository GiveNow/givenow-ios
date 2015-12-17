//
//  DonatingViewController.swift
//  GiveNow
//
//  Created by Brennan Stehling on 12/16/15.
//  Copyright © 2015 GiveNow. All rights reserved.
//

import UIKit
import Mapbox
import CoreLocation

// TODO: implement
// See https://github.com/GiveNow/givenow-ios/issues/6

class DonatingViewController: BaseViewController {

    @IBOutlet var headingContainerView: UIView?
    @IBOutlet var pickupLocationButton: UIButton?
    @IBOutlet var mapView: MGLMapView?
    
    var locationManger: CLLocationManager? {
        didSet {
            locationManger?.delegate = self
            locationManger?.requestWhenInUseAuthorization()
            locationManger?.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            locationManger?.activityType = .OtherNavigation
            locationManger?.startUpdatingLocation()
        }
    }
    
    required  init?(coder aDecoder: NSCoder) {
        locationManger = CLLocationManager()
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        headingContainerView?.backgroundColor = ColorPalette().Heading
//        pickupLocationButton?.backgroundColor = ColorPalette().Confirmation
        pickupLocationButton?.setTitleColor(.whiteColor(), forState: .Normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        awakeFromNib()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
//        mapView.
//        MKMapRect(origin: MKMapPoint(, size: <#T##MKMapSize#>)
//        mapView?.setVisibleMapRect(<#T##mapRect: MKMapRect##MKMapRect#>, animated: <#T##Bool#>)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension DonatingViewController: CLLocationManagerDelegate {

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        let lastLocation = locations.last
//        let latitude = lastLocation?.coordinate.latitude ?? 0
//        let longitude = lastLocation?.coordinate.longitude ?? 0
//        let origin = MKMapPointMake(latitude, longitude)
//        
//        let size = MKMapSize(width: 200, height: 200)
//        let mapRect = MKMapRect(origin: origin, size: size)
//        mapView?.setVisibleMapRect(mapRect, animated: true)
        manager.stopUpdatingLocation()
    }
}