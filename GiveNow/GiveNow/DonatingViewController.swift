//
//  DonatingViewController.swift
//  GiveNow
//
//  Created by Brennan Stehling on 12/16/15.
//  Copyright © 2015 GiveNow. All rights reserved.
//

import UIKit
import MapKit
import Parse
import CoreLocation

// TODO: implement
// See https://github.com/GiveNow/givenow-ios/issues/6

public enum SystemPermissionStatus : Int {
    case NotDetermined = 0
    case Allowed
    case Denied
}

class DonatingViewController: BaseMapViewController, UISearchBarDelegate, UISearchControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet var pickupLocationButton: UIButton?
    @IBOutlet var mapView: MKMapView?
    @IBOutlet weak var myLocationButton: MyLocationButton!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var navItem: UINavigationItem!
    
    var shouldUpdateSearchBarWithMapCenter = false
    var myPickupRequest:PickupRequest!
    
    var pendingDonationViewController:MyPendingDonationViewController!
    
    var searchController:UISearchController!
    
    var searchResults = [MKMapItem]()
    var searchResultsTableView: UITableView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        pickupLocationButton?.backgroundColor = UIColor.colorAccent()
        pickupLocationButton?.setTitleColor(.whiteColor(), forState: .Normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeSearchController()
        initializeSearchResultsTable()
        initializeMenuButton(menuButton)
        localizeText()
        awakeFromNib()
    }
    
    func localizeText() {
        pickupLocationButton?.setTitle(NSLocalizedString("button_set_pickup_location_label", comment: ""), forState: .Normal)
        navItem.title = NSLocalizedString("title_pickup_address", comment: "")
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let status = locationStatus()
        if status == .NotDetermined {
            promptForLocationAuthorization()
        }
        else if status == .Allowed && mapView != nil {
            zoomIntoLocation(false, mapView: self.mapView!, completionHandler: {(zoomed) -> Void in
                if zoomed == true {
                    self.shouldUpdateSearchBarWithMapCenter = true
                    self.setAddressFromCoordinates()
                }
            })
        }
        
        displayPendingDonationViewIfNeeded()
    }
    
    @IBAction func myLocationTapped(sender: AnyObject) {
        if let location = locationManager?.location {
            let coord = location.coordinate
            let currentRegion = mapView!.region
            let newRegion = MKCoordinateRegion(center: coord, span: currentRegion.span)
            mapView!.setRegion(newRegion, animated: true)
        }
    }
    
    func displayPendingDonationViewIfNeeded() {
        let query = backend.queryMyPickupRequests()
        backend.fetchPickupRequestsWithQuery(query, completionHandler: {(result, error) -> Void in
            if error != nil {
                print(error)
            }
            else if result != nil {
                if result!.count > 0 {
                    if let pickupRequest = result![0] as? PickupRequest {
                        self.myPickupRequest = pickupRequest
                        self.addPendingDonationChildView()
                        self.displayPromptIfNeeded()
                    }
                }
            }
        })
    }
    
    func addPendingDonationChildView() {
        if storyboard != nil {
            searchController.searchBar.hidden = true
            pendingDonationViewController = storyboard!.instantiateViewControllerWithIdentifier("pendingDonationView") as! MyPendingDonationViewController
            pendingDonationViewController.pickupRequest = myPickupRequest
            addChildViewController(pendingDonationViewController)
            pendingDonationViewController.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
            view.addSubview(pendingDonationViewController.view)
            pendingDonationViewController.didMoveToParentViewController(self)
        }
    }
    
    func displayPromptIfNeeded() {
        if myPickupRequest.pendingVolunteer != nil && myPickupRequest.confirmedVolunteer == nil {
            if let modalViewController = storyboard!.instantiateViewControllerWithIdentifier("modalPrompt") as? ModalPromptViewController {
                embedViewController(modalViewController, intoView: view)
                
                if let readyForPickupPrompt = storyboard!.instantiateViewControllerWithIdentifier("readyForPickup") as? ReadyForPickupViewController {
                    readyForPickupPrompt.pickupRequest = myPickupRequest
                    modalViewController.embedViewController(readyForPickupPrompt, intoView: modalViewController.promptView)
                }
            }
        }
        else if myPickupRequest.donation != nil {
            if let modalViewController = storyboard!.instantiateViewControllerWithIdentifier("modalPrompt") as? ModalPromptViewController {
                embedViewController(modalViewController, intoView: view)
                
                if let thankYouPrompt = storyboard!.instantiateViewControllerWithIdentifier("donationPickedUp") as? ThankYouPromptViewController {
                    thankYouPrompt.pickupRequest = myPickupRequest
                    modalViewController.embedViewController(thankYouPrompt, intoView: modalViewController.promptView)
                }
            }
        }
    }
    
    func updatePendingDonationChildView() {
        myPickupRequest.fetchIfNeededInBackgroundWithBlock({(result, error) -> Void in
            if error != nil {
                print(error)
            }
            else {
                print(result)
                self.pendingDonationViewController.pickupRequest = self.myPickupRequest
                self.pendingDonationViewController.setHeaderBasedOnRequestStatus()
            }
        })
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
        else if segue.identifier == "viewNewDonation" {
            let destinationController = segue.destinationViewController as! MyPendingDonationViewController
            destinationController.pickupRequest = myPickupRequest
        }
    }
    
    // MARK: - Search
    
    func initializeSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.delegate = self
        navigationItem.titleView = searchController.searchBar
        searchController.searchBar.tintColor = UIColor.colorPrimaryDark()
    }
    
    func backgroundTapped(sender: UIGestureRecognizer? = nil) {
        hideSearchResultsTable()
        searchController.dismissViewControllerAnimated(true, completion: {})
    }
    
    func hideSearchResultsTable() {
        searchResultsTableView.hidden = true
        searchResults = [MKMapItem]()
        searchResultsTableView.reloadData()
    }
    
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
        hideSearchResultsTable()
        setAddressFromCoordinates()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if searchResults.count > 0 {
            let mapItem = searchResults[0]
            self.mapView!.centerMapOnMapItem(mapItem)
        }
        hideSearchResultsTable()
    }
    
    // MARK: Search Results Table
    
    func initializeSearchResultsTable() {
        let frame = CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: view.frame.height)
        searchResultsTableView = UITableView(frame: frame, style: .Grouped)
        searchResultsTableView.backgroundColor = UIColor.clearColor()
        let backgroundView = UIView(frame: frame)
        backgroundView.backgroundColor = UIColor.darkGrayColor()
        backgroundView.alpha = 0.5
        searchResultsTableView.backgroundView = backgroundView
        searchResultsTableView.delegate = self
        searchResultsTableView.dataSource = self
        view.addSubview(searchResultsTableView)
        searchResultsTableView.rowHeight = 60.0
        searchResultsTableView.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: 1.0))
        searchResultsTableView.hidden = true
        
        let tap = UITapGestureRecognizer(target: self, action: Selector("backgroundTapped:"))
        tap.delegate = self
        backgroundView.addGestureRecognizer(tap)
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
        
        let nameFrame = CGRect(x: 10.0, y: 5.0, width: view.frame.width - 20.0, height: 22.0)
        let mapItemNameLabel = cell.addCustomUILabel(nameFrame, font: UIFont.boldSystemFontOfSize(15.0), textColor: UIColor.blackColor())
        mapItemNameLabel.text = mapItem.getName()
        
        let addressFrame = CGRect(x: 10.0, y: 27.0, width: view.frame.width - 20.0, height: 22.0)
        let mapItemAddressLabel = cell.addCustomUILabel(addressFrame, font: UIFont.italicSystemFontOfSize(13.0), textColor: UIColor.lightGrayColor())
        mapItemAddressLabel.text = mapItem.getAddress()
        
        return cell
    }

    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let mapItem = searchResults[indexPath.row]
        searchController.searchBar.text = mapItem.getName()
        hideSearchResultsTable()
        searchController.dismissViewControllerAnimated(true, completion: {() -> Void in
            self.mapView!.centerMapOnMapItem(mapItem)
        })
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        searchController.searchBar.resignFirstResponder()
    }
    
    // MARK: - Map functions
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if shouldUpdateSearchBarWithMapCenter == true {
            setAddressFromCoordinates()
        }
    }
    
    private func setAddressFromCoordinates() {
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
                    if placemark.name != nil {
                        self.searchController.searchBar.text = placemark.name!
                    }
                }
            }
        })
    }
    
    // MARK: Segues
    
    @IBAction func newPickupRequestCreated(segue: UIStoryboardSegue) {
    }
    
}