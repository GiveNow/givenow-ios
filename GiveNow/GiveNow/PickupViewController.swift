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

class PickupViewController: BaseMapViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var myLocationButton: MyLocationButton!
    @IBOutlet weak var pickupRequests: UITabBarItem!
    
    var openPickupRequests:[PickupRequest]!

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
            zoomIntoLocation(false, mapView: mapView, completionHandler: {_ in})
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Fetching pickup requests
    
    private func fetchOpenPickupRequests() {
        let query = backend.queryOpenPickupRequests()
        backend.fetchPickupRequestsWithQuery(query, completionHandler: { (result, error) -> Void in
            if let error = error {
                print(error)
            }
            else if let pickupRequests = result as? [PickupRequest] {
                self.openPickupRequests = pickupRequests
                self.addOpenPickupRequestToMap()
            }
        })
    
    }
    
    private func addOpenPickupRequestToMap() {
        for pickupRequest in openPickupRequests {
            let latitude = pickupRequest.location!.latitude
            let longitude = pickupRequest.location!.longitude
            var title = NSLocalizedString("unknown_address", comment: "")
            if let address = pickupRequest.address {
                if address != "" {
                    title = address
                }
            }
            let donationPoint = PickupRequestMapPoint(latitude: latitude, longitude: longitude, title: title, pickupRequest: pickupRequest)
            mapView.addAnnotation(donationPoint)
        }
    }
    
    // MARK: Map view setup
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let pickupRequestMapPoint = view.annotation as? PickupRequestMapPoint {
            let pickupRequest = pickupRequestMapPoint.pickupRequest
            backend.claimOpenPickupRequest(pickupRequest, completionHandler: { (result, error) -> Void in
                if let error = error {
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
            pinAnnotationView.pinColor = .Green
            pinAnnotationView.canShowCallout = true
            
            let selectButton = UIButton()
            selectButton.frame.size.width = 80
            selectButton.frame.size.height = 44
            selectButton.setTitle(NSLocalizedString("accept", comment: ""), forState: .Normal)
            selectButton.backgroundColor = UIColor.colorAccent()

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


