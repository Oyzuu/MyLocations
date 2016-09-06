//
//  FirstViewController.swift
//  MyLocations
//
//  Created by BT-Training on 01/09/16.
//  Copyright © 2016 BT-Training. All rights reserved.

import UIKit
import CoreLocation
import CoreData

class CurrentLocationViewController: UIViewController {
    // MARK: Controller attributes
    @IBOutlet weak var messageLabel:   UILabel!
    @IBOutlet weak var latitudeLabel:  UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel:   UILabel!
    
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    
    var timer: NSTimer?
    var managedObjectContext: NSManagedObjectContext!
    
    let locationManager = CLLocationManager()
    var location: CLLocation?
    var updatingLocation = false
    var lastLocationError: NSError?
    
    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    var performingReverseGeocoding = false
    var lastGeocodingError: NSError?
    
    // MARK: Controller overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resetGetButtonShadow()
        configureGetButton()
        updateLabels()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "tagDescriptionSegue" {
//            guard let navigationController = segue.destinationViewController as? UINavigationController
//                else { return }
            if let navigationController = segue.destinationViewController as? UINavigationController,
            tagDescriptionViewController = navigationController.viewControllers[0] as? TagDescriptionViewController {
                tagDescriptionViewController.coordinate = location!.coordinate
                tagDescriptionViewController.placemark  = placemark
                
                tagDescriptionViewController.managedObjectContext = self.managedObjectContext
            }
        }
    }
    
    // MARK: Methods
    @IBAction func getButtonTapped(sender: AnyObject) {
        let authStatus = CLLocationManager.authorizationStatus()
        
        switch authStatus {
        case .NotDetermined: locationManager.requestWhenInUseAuthorization()
        case .Denied: fallthrough
        case .Restricted: showLocationServicesDeniedAlert()
        default : break
        }
        
        if updatingLocation {
            stopLocationManager()
        }
        else {
            location           = nil
            lastLocationError  = nil
            placemark          = nil
            lastGeocodingError = nil
            
            startLocationManager()
        }
        
        configureGetButton()
        updateLabels()
    }
    
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "Location services disabled",
                                      message: "Please enable locations services for this app",
                                      preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func configureGetButton() {
        if updatingLocation {
            getButton.setTitle("Stop", forState: .Normal)
        }
        else {
            getButton.setTitle("Get my location", forState: .Normal)
        }
    }
    
    private func stringFromPlacemark(placemark: CLPlacemark) -> String {
        var firstLine  = ""
        
        if let streetName = placemark.thoroughfare {
            firstLine += streetName + " "
        }
        
        if let streetNumber = placemark.subThoroughfare {
            firstLine += streetNumber
        }
        
        var secondLine = ""
        
        if let postalCode = placemark.postalCode {
            secondLine += postalCode + " "
        }
        
        if let city = placemark.locality {
            secondLine += city
        }
        
        return firstLine + "\n" + secondLine
    }
    
    private func updateLabels() {
        print("\(updatingLocation)")
        if let location = self.location {
            let coordinates = location.coordinate
            
            latitudeLabel.text  = String(format: "%.8f", coordinates.latitude)
            longitudeLabel.text = String(format: "%.8f", coordinates.longitude)
            
            tagButton.hidden  = false
            messageLabel.text = ""
            
            if let placemark = self.placemark {
                addressLabel.text = stringFromPlacemark(placemark)
            }
            else if performingReverseGeocoding {
                addressLabel.text = "Searching for address"
            }
            else if lastGeocodingError != nil {
                addressLabel.text = "Error finding address"
            }
            else {
                addressLabel.text = "No address found"
            }
        }
        else {
            latitudeLabel.text  = ""
            longitudeLabel.text = ""
            addressLabel.text   = ""
            tagButton.hidden    = true
            
            let statusMessage: String
            if let error = self.lastLocationError {
                if error.domain == kCLErrorDomain && error.code == CLError.Denied.rawValue {
                    statusMessage = "Location services disabled"
                }
                else {
                    statusMessage = "Error getting location"
                }
            }
            else if !CLLocationManager.locationServicesEnabled() {
                statusMessage = "Location services disabled"
            }
            else if updatingLocation {
                statusMessage = "Searching..."
            }
            else {
                statusMessage = "Tap 'Get my location' to start"
            }
            
            messageLabel.text = statusMessage
        }
    }
    
    private func resetGetButtonShadow() {
        getButton.layer.cornerRadius  = 60
        getButton.layer.shadowOffset  = CGSize(width: 0, height: 2)
        getButton.layer.shadowRadius  = 2
        getButton.layer.shadowOpacity = 0.5
    }
    
    func didTimeOut() {
        if location == nil {
            stopLocationManager()
            lastLocationError = NSError(domain: "MyLocationsErrorDomain", code: 1, userInfo: nil)
            updateLabels()
            configureGetButton()
        }
    }
    
    private func startLocationManager() {
        guard CLLocationManager.locationServicesEnabled() else {
            return
        }
        
        locationManager.delegate        = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        
        updatingLocation = true
        timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self,
                                                       selector: #selector(didTimeOut),
                                                       userInfo: nil, repeats: false)
    }
    
    private func stopLocationManager() {
        guard updatingLocation else {
            return
        }
        
        if let timer = self.timer {
            timer.invalidate()
        }
        
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        
        updatingLocation = false
        updateLabels()
        configureGetButton()
    }
    
    
    @IBAction func didSwipe(sender: AnyObject) {
        print("swipe left")
        tabBarController?.selectedIndex = 1
    }
}


// MARK: CLLocationManagerDelegate
extension CurrentLocationViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
//        print("didFailWithError : \(error)")
        
        if error.code == CLError.LocationUnknown.rawValue {
            return
        }
        
        lastLocationError = error
        
        stopLocationManager()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        lastLocationError = nil
        
        print(newLocation)
        
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        
        var distance = CLLocationDistance(DBL_MAX)
        if let location = self.location {
            distance = newLocation.distanceFromLocation(location)
        }
        
        if location == nil || newLocation.horizontalAccuracy <= location!.horizontalAccuracy {
            print("here")
            lastLocationError = nil
            location = newLocation
            configureGetButton()
            updateLabels()
            
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                stopLocationManager()
                configureGetButton()
                
                if distance > 0 {
                    performingReverseGeocoding = false
                }
            }
            
            if !performingReverseGeocoding {
                performingReverseGeocoding = true
                
                geocoder.reverseGeocodeLocation(newLocation) {
                    placemarks, error in
//                    print("found placemarks: \(placemarks) error: \(error)")
                    self.lastGeocodingError = error
                    
                    if error == nil, let p = placemarks where !p.isEmpty {
                        self.placemark = p.last!
                    }
                    else {
                        self.placemark = nil
                    }
                    
                    self.performingReverseGeocoding = false
                    self.updateLabels()
                }
            }
        }
        else if distance < 1.0 {
            let timeInterval = newLocation.timestamp.timeIntervalSinceDate(location!.timestamp)
            
            if timeInterval > 10 {
                stopLocationManager()
                updateLabels()
                configureGetButton()
            }
        }
    }
}






