//
//  DonatingViewController.swift
//  GiveNow
//
//  Created by Brennan Stehling on 12/16/15.
//  Copyright © 2015 GiveNow. All rights reserved.
//

import UIKit
import MapKit
//import Mapbox
import CoreLocation

// TODO: implement
// See https://github.com/GiveNow/givenow-ios/issues/6

public enum SystemPermissionStatus : Int {
    case NotDetermined = 0
    case Allowed
    case Denied
}

class DonatingViewController: BaseViewController, MKMapViewDelegate, UISearchBarDelegate, UISearchControllerDelegate {

    @IBOutlet var pickupLocationButton: UIButton?
    @IBOutlet var mapView: MKMapView?
    
    var searchController:UISearchController!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        pickupLocationButton?.backgroundColor = ColorPalette().Confirmation
        pickupLocationButton?.setTitleColor(.whiteColor(), forState: .Normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeSearchController()
        awakeFromNib()
    }
    
    func initializeSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        
        searchController.delegate = self
        navigationItem.titleView = searchController.searchBar
        
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
    
    func zoomIntoLocation(animated : Bool) {
        if let locationManager = self.locationManager,
            let location = locationManager.location {
                if CLLocationCoordinate2DIsValid(location.coordinate) {
                    let latitudeInMeters : CLLocationDistance = 30000
                    let longitudeInMeters : CLLocationDistance = 30000
                    let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, latitudeInMeters, longitudeInMeters)
                    
                    self.mapView?.setRegion(coordinateRegion, animated: animated)
                    
//                    let north = max(min(coordinateRegion.center.latitude + (coordinateRegion.span.latitudeDelta * 0.5), 90.0), -90.0)
//                    let south = max(min(coordinateRegion.center.latitude - (coordinateRegion.span.latitudeDelta * 0.5), 90.0), -90.0)
//                    let east = max(min(coordinateRegion.center.longitude + (coordinateRegion.span.longitudeDelta * 0.5), 180.0), -180.0)
//                    let west = max(min(coordinateRegion.center.longitude - (coordinateRegion.span.longitudeDelta * 0.5), 180.0), -180.0)
//                    
//                    let sw = CLLocationCoordinate2DMake(south, west)
//                    let ne = CLLocationCoordinate2DMake(north, east)
//                    
//                    let bounds : MGLCoordinateBounds = MGLCoordinateBounds(sw: sw, ne: ne)
//                    self.mapView?.setVisibleCoordinateBounds(bounds, animated: animated)
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
        
//        locationManager.requestAlwaysAuthorization()
    }
    
    @IBAction func setPickupLocationButtonTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("selectCategories", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "selectCategories" {
            let location = mapView?.centerCoordinate
            var address:String!
            if searchController.searchBar.text != nil {
                address = searchController.searchBar.text!
            }
            else {
                address = ""
            }
            let destinationController = segue.destinationViewController as! DonationCategoriesViewController
            destinationController.location = location
            destinationController.address = address
        }
    }
    
    // MARK: - Search
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        
        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchText
        localSearchRequest.region = mapView!.region
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.startWithCompletionHandler{(localSearchResponse, error) -> Void in
            
            if error != nil {
                print(error)
            }
            else if localSearchResponse == nil {
                print("No results returned")
            }
            else {
                let mapItem = localSearchResponse!.mapItems[0]
                if mapItem.name != nil {
                    print(mapItem.name!)
                }
                print(mapItem.placemark.coordinate)
                if mapItem.placemark.addressDictionary != nil {
                    let addressDictionary = mapItem.placemark.addressDictionary!
                    if addressDictionary["FormattedAddressLines"] != nil {
                        if let formattedAddressLines = addressDictionary["FormattedAddressLines"] as? [String] {
                            for line in formattedAddressLines {
                                print(line)
                            }
                        }
                    }
                }
            }
        }
        
//        //1
//        searchBar.resignFirstResponder()
//        dismissViewControllerAnimated(true, completion: nil)
//        if self.mapView.annotations.count != 0{
//            annotation = self.mapView.annotations[0]
//            self.mapView.removeAnnotation(annotation)
//        }
//        //2
//        localSearchRequest = MKLocalSearchRequest()
//        localSearchRequest.naturalLanguageQuery = searchBar.text
//        localSearch = MKLocalSearch(request: localSearchRequest)
//        localSearch.startWithCompletionHandler { (localSearchResponse, error) -> Void in
//            
//            if localSearchResponse == nil{
//                let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.Alert)
//                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
//                self.presentViewController(alertController, animated: true, completion: nil)
//                return
//            }
//            //3
//            self.pointAnnotation = MKPointAnnotation()
//            self.pointAnnotation.title = searchBar.text
//            self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:     localSearchResponse!.boundingRegion.center.longitude)
//            
//            
//            self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
//            self.mapView.centerCoordinate = self.pointAnnotation.coordinate
//            self.mapView.addAnnotation(self.pinAnnotationView.annotation!)
//        }
        
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        
    }
    
    
    
    
    
    // MARK: - Geocoding
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        setAddressFromCoordinates()
    }
    
    func setAddressFromCoordinates() {
        let geocoder = CLGeocoder()
        let coordinates = mapView?.centerCoordinate
        let latitude = coordinates!.latitude
        let longitude = coordinates!.longitude
        let location = CLLocation(latitude: latitude, longitude: longitude)
        geocoder.reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                print(error)
            }
            else {
                if placemarks != nil {
                    let placemark = placemarks![0]
                    let addressDictionary = placemark.addressDictionary
                    if addressDictionary != nil {
                        if let street = addressDictionary!["Street"] as? String {
                            self.searchController.searchBar.text = street
                        }
                    }
                }
            }
        })
    }
    
    
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