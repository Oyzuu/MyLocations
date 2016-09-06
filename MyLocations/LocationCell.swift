//
//  LocationCell.swift
//  MyLocations
//
//  Created by BT-Training on 06/09/16.
//  Copyright © 2016 BT-Training. All rights reserved.
//

import UIKit
import CoreLocation

class LocationCell: UITableViewCell {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureForLocation(location: Location) {
        if location.locationDescription.isEmpty {
            descriptionLabel.text = "No description"
        }
        else {
            descriptionLabel.text = location.locationDescription
        }

        if let placemark = location.placemark {
            addressLabel.text = stringFromPlacemark(placemark)
        }
        else {
            addressLabel.text = ""
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
        
        //        if let country = placemark.country {
        //            secondLine += "\n \(country)"
        //        }
        
        return firstLine + ", " + secondLine
    }

}
