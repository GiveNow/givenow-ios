//
//  BaseMapViewController.swift
//  GiveNow
//
//  Created by Evan Waters on 1/14/16.
//  Copyright © 2016 GiveNow. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class BaseMapViewController: BaseViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var locationManager: CLLocationManager? {
        didSet {
            if let locationManager = locationManager {
                locationManager.delegate = self
                locationManager.requestWhenInUseAuthorization()
                locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
                locationManager.activityType = .OtherNavigation
                locationManager.startUpdatingLocation()
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        locationManager = CLLocationManager()
        super.init(coder: aDecoder)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
    }
    
    func zoomIntoLocation(animated : Bool, mapView: MKMapView, completionHandler: (Bool) -> Void) {
        if let locationManager = self.locationManager,
            let location = locationManager.location {
                if CLLocationCoordinate2DIsValid(location.coordinate) {
                    let latitudeInMeters : CLLocationDistance = 30000
                    let longitudeInMeters : CLLocationDistance = 30000
                    let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, latitudeInMeters, longitudeInMeters)
                    
                    mapView.setRegion(coordinateRegion, animated: animated)
                    completionHandler(true)
                }
                else {
                    completionHandler(false)
                    print("Location is not valid")
                }
        }
        else {
            if self.locationManager == nil {
                print("Location manager is nil")
            }
            if self.locationManager?.location == nil {
                print("Location is nil")
            }
            completionHandler(false)
        }
    }
    
    func locationStatus() -> SystemPermissionStatus {
        let status = CLLocationManager.authorizationStatus()
        
        if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
            return .Allowed
        }
        if status == .Restricted || status == .Denied {
            return .Denied
        }
        
        return .NotDetermined
    }
    
    func promptForLocationAuthorization() {
        if let locationManager = self.locationManager {
            locationManager.requestAlwaysAuthorization()
        }
    }

}
