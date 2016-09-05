//
//  TagDescriptionViewController.swift
//  MyLocations
//
//  Created by BT-Training on 02/09/16.
//  Copyright © 2016 BT-Training. All rights reserved.
//

import UIKit
import CoreLocation
import MBProgressHUD

class TagDescriptionViewController: UITableViewController {
    @IBOutlet weak var descriptionArea: UITextView!
    @IBOutlet weak var categoryLabel:   UILabel!
    @IBOutlet weak var latitudeLabel:   UILabel!
    @IBOutlet weak var longitudeLabel:  UILabel!
    @IBOutlet weak var addressLabel:    UILabel!
    @IBOutlet weak var dateLabel:       UILabel!
    
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark: CLPlacemark?
    let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .ShortStyle
        return formatter
    }()
    
    var category = "No category"
    
    // MARK: Controller overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionArea.text = ""
        categoryLabel.text   = category
        latitudeLabel.text   = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text  = String(format: "%.8f", coordinate.longitude)
        
        if let placemark = self.placemark {
            addressLabel.text = stringFromPlacemark(placemark)
        }
        else {
            addressLabel.text = "No address found"
        }
        
        dateLabel.text = formatDate(NSDate())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CategoryTableSegue" {
            if let categoryTableViewController = segue.destinationViewController as? CategoryTableViewController {
//                categoryTableViewController.delegate         = self
                categoryTableViewController.selectedCategory = category
            }
        }
    }
    
    // MARK: Methods
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func done(sender: AnyObject) {
        let hud        = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.mode       = .CustomView
        let image      = UIImage(named: "glyph-check")?.imageWithRenderingMode(.AlwaysTemplate)
        hud.customView = UIImageView(image: image)
        hud.label.text = "Done"
        
//        hud.hideAnimated(true, afterDelay: 5)
//        hud.completionBlock = {
//            self.dismissViewControllerAnimated(true, completion: nil)
//        }
        
        afterDelay(1) {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func categoryPickerDidPickCategory(segue: UIStoryboardSegue) {
        print("unwind working")
        
        if segue.identifier == "pickedCategory" {
            if let controller = segue.sourceViewController as? CategoryTableViewController {
                category = controller.selectedCategory
                categoryLabel.text = category
            }
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
        
        if let country = placemark.country {
            secondLine += "\n \(country)"
        }
        
        return firstLine + "\n" + secondLine
    }
    
    private func formatDate(date: NSDate) -> String {
        return dateFormatter.stringFromDate(date)
    }
}

//extension TagDescriptionViewController: CategoryTableDelegate {
//    func categoryTable(controller: CategoryTableViewController, didSelect: String) {
//        category           = didSelect
//        categoryLabel.text = category
//        self.navigationController?.popViewControllerAnimated(true)
//    }
//}
