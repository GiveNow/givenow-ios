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
    @IBOutlet weak var shadowView: UIView!
    
    var donorPhoneNumber:String!
    
    var pickupRequest:PickupRequest!

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        addPickupRequestToMap()
        layoutView()
    }
    
    private func localizeStrings() {
        donationPickedUpButton.setTitle(NSLocalizedString("finish_pickup", comment: ""), forState: .Normal)
    }
    
    private func layoutView() {
        shadowView.addShadow()
        formatButtons()
        setDonorPhoneNumber()
        validateButtons()
        localizeStrings()
    }
    
    private func formatButtons() {
        guard let donationPickedUpButton = donationPickedUpButton else {
            return
        }
        callButton.setImage(UIImage.templatedImageFromName("phone"), forState: .Normal)
        messageButton.setImage(UIImage.templatedImageFromName("textsms"), forState: .Normal)
        navigationButton.setImage(UIImage.templatedImageFromName("navigation"), forState: .Normal)
        
        donationPickedUpButton.layer.cornerRadius = 5.0
        donationPickedUpButton.addShadow()
        
        myLocationButton.addShadow()
    }
    
    private func validateButtons() {
        if donorPhoneNumber == nil {
            callButton.enabled = false
            messageButton.enabled = false
        }
    }
    
    @IBAction func myLocationTapped(sender: AnyObject) {
        if let location = locationManager?.location {
            let coord = location.coordinate
            let currentRegion = mapView!.region
            let newRegion = MKCoordinateRegion(center: coord, span: currentRegion.span)
            mapView!.setRegion(newRegion, animated: true)
        }
        myLocationButton.toggleShadowOff()
    }
    
    //Turning shadow back on after map moves
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        myLocationButton.toggleShadowOn()
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
    
    private func addPickupRequestToMap() {
        guard let location = pickupRequest.location else {
            return
        }
        let latitude = location.latitude
        let longitude = location.longitude
        var title:String!
        if let address = pickupRequest.address {
            if address != "" {
                title = address
            }
            else {
                title = NSLocalizedString("unknown_address", comment: "")
            }
        }
        else {
            title = NSLocalizedString("unknown_address", comment: "")
        }
        let donationPoint = PickupRequestMapPoint(latitude: latitude, longitude: longitude, title: title, pickupRequest: pickupRequest)
        mapView.addAnnotation(donationPoint)
    }
    
    @IBAction func donationPickedUp(sender: AnyObject) {
        backend.pickUpDonation(pickupRequest, completionHandler: {(donation, error) -> Void in
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
            pinAnnotationView.addShadow()
            return pinAnnotationView
        }
        return nil
    }
    
    private func setDonorPhoneNumber() {
        guard let donor = pickupRequest.donor else {
            return
        }
        if let phoneNumber = donor.phoneNumber() {
            self.donorPhoneNumber = phoneNumber
        }
    }
    
    //MARK: Toolbar buttons

    @IBAction func callButtonTapped(sender: AnyObject) {
        if let phoneCallURL:NSURL = NSURL(string:"tel://\(donorPhoneNumber)") {
            let application:UIApplication = UIApplication.sharedApplication()
            if (application.canOpenURL(phoneCallURL)) {
                application.openURL(phoneCallURL);
            }
        }
    }
    
    @IBAction func messageButtonTapped(sender: AnyObject) {
        if let messageURL:NSURL = NSURL(string:"sms://\(donorPhoneNumber)") {
            let application:UIApplication = UIApplication.sharedApplication()
            if (application.canOpenURL(messageURL)) {
                application.openURL(messageURL);
            }
        }
    }
    
    @IBAction func navigationButtonTapped(sender: AnyObject) {
        let latitude = pickupRequest.location!.latitude
        let longitude = pickupRequest.location!.longitude
        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let placeMark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placeMark)
        
        mapItem.name = NSLocalizedString("navigation_instructions_donation_location", comment: "")
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        
        mapItem.openInMapsWithLaunchOptions(launchOptions)
        
    }
    

}
