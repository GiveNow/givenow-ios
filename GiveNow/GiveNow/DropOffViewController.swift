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

class DropOffViewController: BaseMapViewController {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var myLocationButton: MyLocationButton!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var shadowView: UIView!
    
    var dropOffAgencies:[DropOffAgency]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutView()
        initializeMenuButton(menuButton)
        mapView.delegate = self
        fetchDropOffAgencies()
        
    }
    
    func layoutView() {
        myLocationButton.addShadow()
        shadowView.addShadow()
        localizeStrings()
    }
    
    func localizeStrings() {
        navItem.title = NSLocalizedString("dropoff_title", comment: "")
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
            zoomIntoLocation(false, mapView: mapView, completionHandler: {_ in})
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchDropOffAgencies() {
        backend.fetchDropOffAgencies({ (result, error) -> Void in
            if let error = error {
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
            if let agencyAddress = dropOffAgency.agencyAddress {
                if agencyAddress != "" {
                    title = agencyAddress
                }
            }
            else {
                title = NSLocalizedString("unknown_address", comment: "")
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
            pinAnnotationView.addShadow()
            
            let directionsButton = UIButton()
            directionsButton.frame.size.width = 44
            directionsButton.frame.size.height = 44
            directionsButton.layer.cornerRadius = 5
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
        
        mapItem.name = NSLocalizedString("dropoff_center", comment: "")
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
