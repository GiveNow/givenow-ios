//
//  DropOffViewController.swift
//  GiveNow
//
//  Created by Evan Waters on 1/12/16.
//  Copyright © 2016 GiveNow. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class DropOffViewController: BaseViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var myLocationButton: MyLocationButton!
    
    var dropOffAgencies:[DropOffAgency]!
    
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
        initializeMenuButton()
        mapView.delegate = self
        fetchDropOffAgencies()
    }
    
    @IBAction func myLocationTapped(sender: AnyObject) {
        if let location = locationManager?.location {
            let coord = location.coordinate
            let currentRegion = mapView!.region
            let newRegion = MKCoordinateRegion(center: coord, span: currentRegion.span)
            mapView!.setRegion(newRegion, animated: true)
        }
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
                    
                    self.mapView?.setRegion(coordinateRegion, animated: false)
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func initializeMenuButton() {
        if self.revealViewController() != nil {
            if let menuImage = UIImage(named: "menu") {
                self.menuButton.image = menuImage.imageWithRenderingMode(.AlwaysTemplate)
                self.menuButton.tintColor = UIColor.whiteColor()
            }
            self.menuButton.target = self.revealViewController()
            self.menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    func fetchDropOffAgencies() {
        backend.fetchDropOffAgencies({ (result, error) -> Void in
            if error != nil {
                print(error)
            }
            else if let dropOffAgencies = result as? [DropOffAgency] {
                self.dropOffAgencies = dropOffAgencies
                self.addDropOffAgenciesToMap()
            }
        })
        
    }
    
    func addDropOffAgenciesToMap() {
        for dropOffAgency in dropOffAgencies {
            let latitude = dropOffAgency.agencyGeoLocation!.latitude
            let longitude = dropOffAgency.agencyGeoLocation!.longitude
            var title:String!
            if dropOffAgency.agencyAddress != nil {
                title = dropOffAgency.agencyAddress!
            }
            else {
                title = "Unknown address"
            }
            let agencyPoint = DropOffAgencyMapPoint(latitude: latitude, longitude: longitude, title: title, dropOffAgency: dropOffAgency)
            mapView.addAnnotation(agencyPoint)
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is DropOffAgencyMapPoint {
            let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "dropOffAgency")
            pinAnnotationView.pinColor = .Green
            pinAnnotationView.canShowCallout = true
            
            let directionsButton = UIButton()
            directionsButton.frame.size.width = 44
            directionsButton.frame.size.height = 44
            directionsButton.tintColor = UIColor.whiteColor()
            directionsButton.setImage(UIImage(named: "navigation")!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
            directionsButton.backgroundColor = UIColor.colorAccent()
            
            pinAnnotationView.leftCalloutAccessoryView = directionsButton
            
            return pinAnnotationView
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let dropOffAgencyMapPoint = view.annotation as? DropOffAgencyMapPoint {
            let dropOffAgency = dropOffAgencyMapPoint.dropOffAgency
            self.getDirections(dropOffAgency)
            
        }
    }
    
    func getDirections(dropOffAgency: DropOffAgency) {
        let latitude = dropOffAgency.agencyGeoLocation!.latitude
        let longitude = dropOffAgency.agencyGeoLocation!.longitude
        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let placeMark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placeMark)
        
        mapItem.name = "Drop Off Agency"
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        
        mapItem.openInMapsWithLaunchOptions(launchOptions)
        
    }
    
}

class DropOffAgencyMapPoint: NSObject, MKAnnotation {
    var latitude: Double
    var longitude: Double
    var title:String?
    var dropOffAgency:DropOffAgency!
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(latitude: Double, longitude: Double, title: String, dropOffAgency: DropOffAgency) {
        self.latitude = latitude
        self.longitude = longitude
        self.title = title
        self.dropOffAgency = dropOffAgency
    }
    
}
