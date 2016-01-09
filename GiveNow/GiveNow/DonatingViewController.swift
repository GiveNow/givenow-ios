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

class DonatingViewController: BaseViewController, MKMapViewDelegate, UISearchBarDelegate, UISearchControllerDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var pickupLocationButton: UIButton?
    @IBOutlet var mapView: MKMapView?
    
    var searchController:UISearchController!
    
    var searchResults = [MKMapItem]()
    var searchResultsTableView = UITableView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0), style: .Grouped)
    
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
        initializeSearchResultsTable()
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
    
    func initializeSearchResultsTable() {
        searchResultsTableView.delegate = self
        searchResultsTableView.dataSource = self
        view.addSubview(searchResultsTableView)
        searchResultsTableView.rowHeight = 60.0
        searchResultsTableView.frame = CGRect(x: 0.0, y: 64.0, width: view.frame.width, height: view.frame.height - 64)
        searchResultsTableView.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: 0.0))
        searchResultsTableView.hidden = true
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
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        searchResultsTableView.hidden = false
        if searchController.searchBar.text != nil {
            searchMapView(searchController.searchBar.text!)
        }
        return true
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchResults = [MKMapItem]()
        if searchText == "" {
            self.searchResultsTableView.reloadData()
        }
        else {
            searchMapView(searchText)
        }
    }
    
    func searchMapView(searchText: String) {
        let localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchText
        localSearchRequest.region = mapView!.region
        
        let localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.startWithCompletionHandler{(localSearchResponse, error) -> Void in
            
            if error != nil {
                print(error)
            }
            else if localSearchResponse == nil {
                print("No results returned")
            }
            else {
                for mapItem in localSearchResponse!.mapItems {
                    self.searchResults.append(mapItem)
                }
            }
            self.searchResultsTableView.reloadData()
        }

    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchResultsTableView.hidden = true
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchResultsTableView.hidden = true
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let mapItem = searchResults[indexPath.row]
        
        let mapItemNameLabel = UILabel(frame: CGRect(x: 10.0, y: 5.0, width: view.frame.width - 20.0, height: 22.0))
        mapItemNameLabel.text = nameForMapItem(mapItem)
        cell.addSubview(mapItemNameLabel)
        
        let mapItemAddressLabel = UILabel(frame: CGRect(x: 10.0, y: 27.0, width: view.frame.width - 20.0, height: 22.0))
        mapItemAddressLabel.text = addressForMapItem(mapItem)
        mapItemAddressLabel.textColor = UIColor.lightGrayColor()
        mapItemAddressLabel.font = UIFont.italicSystemFontOfSize(13.0)
        cell.addSubview(mapItemAddressLabel)
        return cell
    }

    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let mapItem = searchResults[indexPath.row]
        searchController.searchBar.text = addressForMapItem(mapItem)
        searchResultsTableView.hidden = true
        searchController.dismissViewControllerAnimated(true, completion: {() -> Void in
            self.centerMapOnMapItem(mapItem)
        })
    }
    
    func centerMapOnMapItem(mapItem: MKMapItem) {
        let currentRegion = mapView!.region
        let newCenter = coordinatesForMapItem(mapItem)
        let newRegion = MKCoordinateRegion(center: newCenter, span: currentRegion.span)
        mapView!.setRegion(newRegion, animated: true)
    }
    
    
    
    func nameForMapItem(mapItem: MKMapItem) -> String {
        if mapItem.name != nil {
            return mapItem.name!
        }
        else {
            return ""
        }
    }
    
    func addressForMapItem(mapItem: MKMapItem) -> String {
        var address = ""
        if mapItem.placemark.addressDictionary != nil {
            let addressDictionary = mapItem.placemark.addressDictionary!
            address = getAddressFromAddressDictionary(addressDictionary)
        }
        return address
    }
    
    func getAddressFromAddressDictionary(addressDictionary: [NSObject: AnyObject]) -> String {
        var address = ""
        if addressDictionary["FormattedAddressLines"] != nil {
            if let formattedAddressLines = addressDictionary["FormattedAddressLines"] as? [String] {
                for line in formattedAddressLines {
                    address += line + " "
                }
            }
        }
        return address
    }
    
    func coordinatesForMapItem(mapItem: MKMapItem) -> CLLocationCoordinate2D {
        return mapItem.placemark.coordinate
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
                    if placemark.addressDictionary != nil {
                        let addressDictionary = placemark.addressDictionary!
                        let address = self.getAddressFromAddressDictionary(addressDictionary)
                        self.searchController.searchBar.text = address
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