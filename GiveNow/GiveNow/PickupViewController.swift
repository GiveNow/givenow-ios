//
//  PickupViewController.swift
//  GiveNow
//
//  Created by Evan Waters on 12/20/15.
//  Copyright © 2015 GiveNow. All rights reserved.
//

import UIKit
import Parse
import MapKit
import CoreLocation

//// https://github.com/GiveNow/givenow-ios/issues/8
//// ToDo:
//Fetch pending donations
//Display donations on a map
//Select a donation and send notification to confirm donation is ready for pick up
//Set donation as picked up and dropped off

class PickupViewController: BaseViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
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
    
    var openPickupRequests:[PickupRequest]!
    
    let backend = Backend.sharedInstance()

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        fetchOpenPickupRequests()
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    func fetchOpenPickupRequests() {
        let query = backend.queryOpenPickupRequests()
        backend.fetchPickupRequestsWithQuery(query, completionHandler: { (result, error) -> Void in
            if error != nil {
                print(error)
            }
            else if let pickupRequests = result as? [PickupRequest] {
                self.openPickupRequests = pickupRequests
                self.addOpenPickupRequestToMap()
            }
        })
    
    }
    
    func addOpenPickupRequestToMap() {
        print(openPickupRequests)
        for pickupRequest in openPickupRequests {
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
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let pickupRequestMapPoint = view.annotation as? PickupRequestMapPoint {
            let pickupRequest = pickupRequestMapPoint.pickupRequest
            backend.claimOpenPickupRequest(pickupRequest, completionHandler: { (result, error) -> Void in
                if error != nil {
                    print(error)
                }
                else {
                    mapView.removeAnnotation(pickupRequestMapPoint)
                }
            })
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is PickupRequestMapPoint {
            let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pickupRequest")
            pinAnnotationView.pinColor = .Purple
            pinAnnotationView.canShowCallout = true
            
            let selectButton = UIButton()
            selectButton.frame.size.width = 80
            selectButton.frame.size.height = 44
            selectButton.setTitle("Accept", forState: .Normal)
            selectButton.backgroundColor = UIColor.purpleColor()

            pinAnnotationView.leftCalloutAccessoryView = selectButton
            
            return pinAnnotationView
        }
        return nil
    }

}

class PickupRequestMapPoint: NSObject, MKAnnotation {
    var latitude: Double
    var longitude: Double
    var title:String?
    var pickupRequest:PickupRequest!
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(latitude: Double, longitude: Double, title: String, pickupRequest: PickupRequest) {
        self.latitude = latitude
        self.longitude = longitude
        self.title = title
        self.pickupRequest = pickupRequest
    }
    
}

