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
            pinAnnotationView.pinColor = .Green
            pinAnnotationView.canShowCallout = true
            
            let selectButton = UIButton()
            selectButton.frame.size.width = 80
            selectButton.frame.size.height = 44
            selectButton.setTitle("Accept", forState: .Normal)
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


