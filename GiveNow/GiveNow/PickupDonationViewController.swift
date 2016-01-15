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

class PickupDonationViewController: BaseMapViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var donationPickedUpButton: UIButton!
    
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var navigationButton: UIButton!
    @IBOutlet weak var myLocationButton: MyLocationButton!
    
    var pickupRequest:PickupRequest!

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        addPickupRequestToMap()
        formatButtons()
    }
    
    func formatButtons() {
        tintButton(callButton, imageName: "phone")
        tintButton(messageButton, imageName: "textsms")
        tintButton(navigationButton, imageName: "navigation")
    }
    
    func tintButton(button: UIButton, imageName: String) {
        if let image = UIImage(named: imageName) {
            button.setImage(image.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
            button.tintColor = UIColor.colorAccent()
        }
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
            zoomIntoLocation(false, mapView: mapView, completionHandler: {_ in })
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
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is PickupRequestMapPoint {
            let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pickupRequest")
            pinAnnotationView.pinColor = .Green
            pinAnnotationView.canShowCallout = true
            return pinAnnotationView
        }
        return nil
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
        let phoneNumber = "5555555555"
        sendMessage(phoneNumber)
    }
    
    private func sendMessage(phoneNumber:String) {
        if let messageURL:NSURL = NSURL(string:"sms://\(phoneNumber)") {
            let application:UIApplication = UIApplication.sharedApplication()
            if (application.canOpenURL(messageURL)) {
                application.openURL(messageURL);
            }
        }
    }
    
    @IBAction func navigationButtonTapped(sender: AnyObject) {
        print("Navigate!")
        let latitude = pickupRequest.location!.latitude
        let longitude = pickupRequest.location!.longitude
        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let placeMark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placeMark)
        
        mapItem.name = "Donation Location"
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        
        mapItem.openInMapsWithLaunchOptions(launchOptions)
        
    }
    

}
