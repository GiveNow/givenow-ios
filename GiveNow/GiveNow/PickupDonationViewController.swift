//
//  PickupDonationViewController.swift
//  GiveNow
//
//  Created by Evan Waters on 1/5/16.
//  Copyright © 2016 GiveNow. All rights reserved.
//

import UIKit
import Parse
import MapKit
import CoreLocation

class PickupDonationViewController: BaseViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var donationPickedUpButton: UIButton!
    
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var navigationButton: UIButton!
    
    var pickupRequest:PickupRequest!
    let backend = Backend.sharedInstance()
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        addPickupRequestToMap()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let status = locationStatus()
        if status == .NotDetermined {
            promptForLocationAuthorization()
        }
        else if status == .Allowed {
            zoomIntoLocation(true)
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
    
    func zoomIntoLocation(animated : Bool) {
        if let locationManager = self.locationManager,
            let location = locationManager.location {
                if CLLocationCoordinate2DIsValid(location.coordinate) {
                    let latitudeInMeters : CLLocationDistance = 30000
                    let longitudeInMeters : CLLocationDistance = 30000
                    let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, latitudeInMeters, longitudeInMeters)
                    
                    self.mapView?.setRegion(coordinateRegion, animated: animated)
                }
                else {
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
        }
    }
    
    func addPickupRequestToMap() {
        let latitude = pickupRequest.location!.latitude
        let longitude = pickupRequest.location!.longitude
        var title:String!
        if pickupRequest.address != nil {
            title = pickupRequest.address!
        }
        else {
            title = "Unknown address"
        }
        let donationPoint = PickupRequestMapPoint(latitude: latitude, longitude: longitude, title: title, pickupRequest: pickupRequest)
        mapView.addAnnotation(donationPoint)
        print(donationPoint)
    }
    
    @IBAction func donationPickedUp(sender: AnyObject) {
        backend.saveDonationForPickupRequest(pickupRequest, completionHandler: {(donation, error) -> Void in
            if let error = error {
                print(error)
            }
            else {
                self.performSegueWithIdentifier("donationCompleted", sender: nil)
            }
        })
    }
    
    //MARK: Toolbar buttons

    @IBAction func callButtonTapped(sender: AnyObject) {
        let phoneNumber = "5555555555"
        callNumber(phoneNumber)
    }
    
    private func callNumber(phoneNumber:String) {
        if let phoneCallURL:NSURL = NSURL(string:"tel://\(phoneNumber)") {
            let application:UIApplication = UIApplication.sharedApplication()
            if (application.canOpenURL(phoneCallURL)) {
                application.openURL(phoneCallURL);
            }
        }
    }
    
    @IBAction func messageButtonTapped(sender: AnyObject) {
        print("Send SMS")
    }
    
    @IBAction func navigationButtonTapped(sender: AnyObject) {
        print("Navigate!")
        let latitude = pickupRequest.location!.latitude
        let longitude = pickupRequest.location!.longitude
        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let placeMark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placeMark)
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        
        mapItem.openInMapsWithLaunchOptions(launchOptions)
        
        
    }
    
    
    

}
