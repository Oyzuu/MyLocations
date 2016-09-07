//
//  MapViewController.swift
//  MyLocations
//
//  Created by BT-Training on 07/09/16.
//  Copyright © 2016 BT-Training. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    
    // MARK: attributes
    
    @IBOutlet weak var mapView: MKMapView!
    
    var managedObjectContext: NSManagedObjectContext! {
        didSet {
            NSNotificationCenter.defaultCenter().addObserverForName(
                NSManagedObjectContextObjectsDidChangeNotification, object: managedObjectContext,
                queue: NSOperationQueue.mainQueue()) {
                    
                notification in
                                        
                if self.isViewLoaded() {
                    self.updateLocations()
                }
            }
        }
    }
    
    var locations = [Location]()
    
    // MARK: Controller overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateLocations()
        if !locations.isEmpty {
            showLocations()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "editLocationSegue" {
            if let navigationController = segue.destinationViewController as? UINavigationController,
                controller = navigationController.viewControllers[0] as? TagDescriptionViewController {
                controller.managedObjectContext = managedObjectContext
                controller.locationToEdit = sender as? Location
            }
        }
    }
    
    // MARK: Methods
    
    @IBAction func showUser() {
        let center = mapView.userLocation.coordinate
        let region = MKCoordinateRegionMakeWithDistance(center, 1000, 1000)
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func showLocations() {
        mapView.setRegion(regionForannotations(locations), animated: true)
    }
    
    func regionForannotations(annotations: [MKAnnotation]) -> MKCoordinateRegion {
        var region = MKCoordinateRegion()
        
        switch annotations.count {
        case 0:
            region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
        case 1:
            region = MKCoordinateRegionMakeWithDistance(annotations[0].coordinate, 1000, 1000)
        default :
            var topLeft     = CLLocationCoordinate2D(latitude: -90, longitude:  180)
            var bottomRight = CLLocationCoordinate2D(latitude:  90, longitude: -180)
            
            for annotation in annotations {
                topLeft.latitude      = max(topLeft.latitude,      annotation.coordinate.latitude)
                topLeft.longitude     = min(topLeft.longitude,     annotation.coordinate.longitude)
                bottomRight.latitude  = min(bottomRight.latitude,  annotation.coordinate.latitude)
                bottomRight.longitude = max(bottomRight.longitude, annotation.coordinate.longitude)
                
                let centerLatitude  = topLeft.latitude  - (topLeft.latitude  - bottomRight.latitude)  / 2
                let centerLongitude = topLeft.longitude - (topLeft.longitude - bottomRight.longitude) / 2
                
                let center = CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude)
                
                let extraSpace = 1.5
                let span = MKCoordinateSpan(
                    latitudeDelta:  extraSpace * abs(topLeft.latitude  - bottomRight.latitude),
                    longitudeDelta: extraSpace * abs(topLeft.longitude - bottomRight.longitude))
                
                region = MKCoordinateRegion(center: center, span: span)
            }
        }
        
        return mapView.regionThatFits(region)
    }
    
    func updateLocations() {
        mapView.removeAnnotations(locations)
        
        let entity = NSEntityDescription.entityForName("Location",
                                                       inManagedObjectContext: managedObjectContext)
        
        let fetchRequest    = NSFetchRequest()
        fetchRequest.entity = entity
        
        locations = try! managedObjectContext.executeFetchRequest(fetchRequest) as! [Location]
        
        mapView.addAnnotations(locations)
    }
}

// MARK: Extension : Map view delegate

extension MapViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let location = view.annotation as? Location else {
            return
        }
        
        performSegueWithIdentifier("editLocationSegue", sender: location)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is Location else {
            return nil
        }
        
        let identifier = "Location"
        var annotationView =
            mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as! MKPinAnnotationView!
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView.enabled        = true
            annotationView.canShowCallout = true
            annotationView.animatesDrop   = false
            annotationView.pinTintColor   = UIColor(red: 0.32, green: 0.82, blue: 0.4, alpha: 1)
            
            annotationView.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            annotationView.annotation = annotation
        }
        
        return annotationView
    }
    
}

extension MapViewController: UINavigationBarDelegate {
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
}







