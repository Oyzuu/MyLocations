//
//  Location.swift
//  
//
//  Created by BT-Training on 05/09/16.
//
//

import Foundation
import CoreData
import MapKit

class Location: NSManagedObject, MKAnnotation {
    
    class func nextPhotoID() -> Int {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let currentID    = userDefaults.integerForKey("photoID")
        
        userDefaults.setInteger(currentID + 1, forKey: "photoID")
        userDefaults.synchronize()
        
        return currentID
    }
    
    var hasPhoto: Bool {
        return photoID != nil
    }
    
    var photoPath: String {
        assert(hasPhoto, "No photo ID set")
        
        let fileName = "Photo-\(photoID!.integerValue).jpg"
        
        return (applicationDocumentsDirectory as NSString).stringByAppendingPathComponent(fileName)
    }
    
    var photoImage: UIImage? {
        return UIImage(contentsOfFile: photoPath)
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude:  self.latitude,
                                      longitude: self.longitude)
    }
    
    var title: String? {
        if locationDescription.isEmpty {
            return "No description"
        }
        
        return self.locationDescription
    }
    
    var subtitle: String? {
        return self.category
    }
}
