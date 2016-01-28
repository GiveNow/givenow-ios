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

class DonatingViewController: BaseMapViewController, UISearchBarDelegate, UISearchControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet var pickupLocationButton: UIButton?
    @IBOutlet var mapView: MKMapView?
    @IBOutlet weak var myLocationButton: MyLocationButton!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var infoImage: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var helpButton: UIButton!
    
    var shouldUpdateSearchBarWithMapCenter = false
    var myPickupRequest:PickupRequest!
    var selectedAddress:String?
    
    var pendingDonationViewController:MyPendingDonationViewController!
    
    var searchController:UISearchController?
    
    var searchResults = [MKMapItem]()
    var searchResultsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeSearchController()
        initializeSearchResultsTable()
        initializeMenuButton(menuButton)
        layoutView()
        zoomToUserLocation()
        navigationItem.title = ""
    }
    
    func layoutView() {
        localizeText()
        templateImages()
    }
    
    func localizeText() {
        pickupLocationButton?.setTitle(NSLocalizedString("button_set_pickup_location_label", comment: ""), forState: .Normal)
        infoLabel.text = NSLocalizedString("request_pickup_choose_location", comment: "")
        
    }
    
    func templateImages() {
        if let image = UIImage(named: "info") {
            self.infoImage.image = image.imageWithRenderingMode(.AlwaysTemplate)
            self.infoImage.tintColor = UIColor.whiteColor()
        }
        if let image = UIImage(named: "help") {
            helpButton.setImage(image.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
            helpButton.tintColor = UIColor.whiteColor()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        displayPendingDonationViewIfNeeded()
    }
    
    @IBAction func helpButtonTapped(sender: AnyObject) {
        
    }
    
    
    func zoomToUserLocation() {
        let status = locationStatus()
        if status == .NotDetermined {
            promptForLocationAuthorization()
        }
        else if status == .Allowed {
            if let mapView = self.mapView {
                zoomIntoLocation(false, mapView: mapView, completionHandler: {(zoomed) -> Void in
                    if zoomed == true {
                        self.shouldUpdateSearchBarWithMapCenter = true
                        self.setAddressFromCoordinates()
                    }
                })
            }
        }
        else if status == .Denied {
            self.shouldUpdateSearchBarWithMapCenter = true
        }
        else {
            print("I'm not gonna zoom")
        }
    }
    
    @IBAction func myLocationTapped(sender: AnyObject) {
        centerMapOnUserLocation()
    }
    
    func centerMapOnUserLocation() {
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
            if let error = error {
                print(error)
            }
            else if let result = result {
                if result.count > 0 {
                    if let pickupRequest = result[0] as? PickupRequest {
                        self.myPickupRequest = pickupRequest
                        self.addPendingDonationChildView()
                        self.displayPromptIfNeeded()
                    }
                }
            }
        })
    }
    
    func addPendingDonationChildView() {
        centerMapOnDonation()
        setNavTitle()
        if let storyboard = storyboard {
            pendingDonationViewController = storyboard.instantiateViewControllerWithIdentifier("pendingDonationView") as! MyPendingDonationViewController
            pendingDonationViewController.pickupRequest = myPickupRequest
            addChildViewController(pendingDonationViewController)
            pendingDonationViewController.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
            view.addSubview(pendingDonationViewController.view)
            pendingDonationViewController.didMoveToParentViewController(self)
        }
    }
    
    func centerMapOnDonation() {
        guard let coordinates = myPickupRequest.pickupLocationCoordinates(), mapView = mapView else {
            return
        }
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapView.centerMapOnMapItem(mapItem)
    }
    
    func setNavTitle() {
        guard let pickupLocationName = myPickupRequest.address else {
            return
        }
        navigationItem.titleView = nil
        searchController = nil
        navigationItem.title = pickupLocationName
    }
    
    func displayPromptIfNeeded() {
        guard let storyboard = storyboard else {
            return
        }
        if myPickupRequest.pendingVolunteer != nil && myPickupRequest.confirmedVolunteer == nil {
            if let modalViewController = storyboard.instantiateViewControllerWithIdentifier("modalPrompt") as? ModalPromptViewController {
                embedViewController(modalViewController, intoView: view)
                
                if let readyForPickupPrompt = storyboard.instantiateViewControllerWithIdentifier("readyForPickup") as? ReadyForPickupViewController {
                    readyForPickupPrompt.pickupRequest = myPickupRequest
                    modalViewController.embedViewController(readyForPickupPrompt, intoView: modalViewController.promptView)
                }
            }
        }
        else if myPickupRequest.donation != nil {
            if let modalViewController = storyboard.instantiateViewControllerWithIdentifier("modalPrompt") as? ModalPromptViewController {
                embedViewController(modalViewController, intoView: view)
                
                if let thankYouPrompt = storyboard.instantiateViewControllerWithIdentifier("donationPickedUp") as? ThankYouPromptViewController {
                    thankYouPrompt.pickupRequest = myPickupRequest
                    modalViewController.embedViewController(thankYouPrompt, intoView: modalViewController.promptView)
                }
            }
        }
    }
    
    func updatePendingDonationChildView() {
        myPickupRequest.fetchIfNeededInBackgroundWithBlock({(result, error) -> Void in
            if let error = error {
                print(error)
            }
            else {
                self.pendingDonationViewController.pickupRequest = self.myPickupRequest
                self.pendingDonationViewController.setHeaderBasedOnRequestStatus()
            }
        })
    }
    
    @IBAction func setPickupLocationButtonTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("selectCategories", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let searchController = searchController else {
            return
        }
        if segue.identifier == "selectCategories" {
            let destinationController = segue.destinationViewController as! DonationCategoriesViewController
            let location = mapView?.centerCoordinate
            var address:String!
            if let searchText = searchController.searchBar.text {
                address = searchText
                destinationController.navigationItem.title = searchText
            }
            else {
                address = ""
            }
            destinationController.location = location
            destinationController.address = address
        }
        else if segue.identifier == "viewNewDonation" {
            let destinationController = segue.destinationViewController as! MyPendingDonationViewController
            destinationController.pickupRequest = myPickupRequest
        }
    }
    
    private func validateSetPickupLocationButton() {
        guard let searchController = searchController else {
            return
        }
        if searchController.searchBar.text == nil || searchController.searchBar.text == "" {
            self.disablePickupLocationButton()
        }
        else {
            self.enablePickupLocationButton()
        }
    }
    
    private func disablePickupLocationButton() {
        self.pickupLocationButton!.enabled = false
        self.pickupLocationButton!.backgroundColor = UIColor.colorAccentDisabled()
    }
    
    private func enablePickupLocationButton() {
        self.pickupLocationButton!.enabled = true
        self.pickupLocationButton!.backgroundColor = UIColor.colorAccent()
    }
    
    // MARK: - Search
    
    func initializeSearchController() {
        print("Creating the search controller")
        searchController = UISearchController(searchResultsController: nil)
        if let searchController = searchController {
            searchController.hidesNavigationBarDuringPresentation = false
            searchController.searchBar.delegate = self
            searchController.dimsBackgroundDuringPresentation = false
            formatSearchField()
            searchController.delegate = self
            navigationItem.titleView = searchController.searchBar
            validateSetPickupLocationButton()
        }
    }
    
    func formatSearchField() {
        guard let searchController = searchController else {
            return
        }
        for subView in searchController.searchBar.subviews {
            for subView in subView.subviews {
                if let textField = subView as? UITextField {
                    textField.backgroundColor = UIColor.colorPrimaryDark()
                    textField.textColor = UIColor.whiteColor()
                    if textField.respondsToSelector("attributedPlaceholder") {
                        let attributedDict = [NSForegroundColorAttributeName: UIColor.whiteColor()]
                        textField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("search", comment: ""), attributes: attributedDict)
                    }
                }
            }
        }
        if let searchImage = UIImage(named: "search") {
            searchController.searchBar.setImage(searchImage.imageWithRenderingMode(.AlwaysTemplate), forSearchBarIcon: .Search, state: .Normal)
        }
        if let cancelImage = UIImage(named: "cancel") {
            searchController.searchBar.setImage(cancelImage.imageWithRenderingMode(.AlwaysTemplate), forSearchBarIcon: .Clear, state: .Normal)
        }
        searchController.searchBar.tintColor = UIColor.whiteColor()
    }
    
    func backgroundTapped(sender: UIGestureRecognizer? = nil) {
        hideSearchResultsTable()
        guard let searchController = searchController else {
            return
        }
        searchController.dismissViewControllerAnimated(true, completion: {})
    }
    
    func hideSearchResultsTable() {
        searchResultsTableView.hidden = true
        searchResults = [MKMapItem]()
        searchResultsTableView.reloadData()
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        guard let searchController = searchController else {
            return false
        }
        guard let searchText = searchController.searchBar.text else {
            return false
        }
        searchResultsTableView.hidden = false
        searchMapView(searchText)
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
            
            if let error = error {
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
        guard let mapView = self.mapView else {
            return
        }
        if searchResults.count > 0 {
            let mapItem = searchResults[0]
            mapView.centerMapOnMapItem(mapItem)
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
        // Asking for searchResults[indexPath.row] directly is occassionally crashing the app
        if indexPath.row < searchResults.count {
            let mapItem = searchResults[indexPath.row]
            
            let nameFrame = CGRect(x: 10.0, y: 5.0, width: view.frame.width - 20.0, height: 22.0)
            let mapItemNameLabel = cell.addCustomUILabel(nameFrame, font: UIFont.boldSystemFontOfSize(15.0), textColor: UIColor.blackColor())
            mapItemNameLabel.text = mapItem.getName()
            
            let addressFrame = CGRect(x: 10.0, y: 27.0, width: view.frame.width - 20.0, height: 22.0)
            let mapItemAddressLabel = cell.addCustomUILabel(addressFrame, font: UIFont.italicSystemFontOfSize(13.0), textColor: UIColor.lightGrayColor())
            mapItemAddressLabel.text = mapItem.getAddress()
        }
        return cell
    }

    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let searchController = searchController else {
            return
        }
        let mapItem = searchResults[indexPath.row]
        selectedAddress = mapItem.getName()
        hideSearchResultsTable()
        searchController.dismissViewControllerAnimated(true, completion: {() -> Void in
            self.mapView!.centerMapOnMapItem(mapItem)
            self.validateSetPickupLocationButton()
        })
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        guard let searchController = searchController else {
            return
        }
        searchController.searchBar.resignFirstResponder()
    }
    
    // MARK: - Map functions
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if shouldUpdateSearchBarWithMapCenter == true {
            setAddressFromCoordinates()
        }
    }
    
    private func setAddressFromCoordinates() {
        guard let searchController = searchController, mapView = mapView else {
            return
        }
        if let selectedAddress = selectedAddress {
            searchController.searchBar.text = selectedAddress
            self.selectedAddress = nil
        }
        else {
            let geocoder = CLGeocoder()
            let coordinates = mapView.centerCoordinate
            let latitude = coordinates.latitude
            let longitude = coordinates.longitude
            let location = CLLocation(latitude: latitude, longitude: longitude)
            geocoder.reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
                if let error = error {
                    print("Got an error doing reverse geocoding")
                    print(error)
                }
                else {
                    if let placemarks = placemarks {
                        let placemark = placemarks[0]
                        if let name = placemark.name {
                            searchController.searchBar.text = name
                            self.validateSetPickupLocationButton()
                        }
                    }
                }
            })
        }
    }
    
    // MARK: Segues
    
    @IBAction func newPickupRequestCreated(segue: UIStoryboardSegue) {
    }
    
}