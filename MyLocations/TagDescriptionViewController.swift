//
//  TagDescriptionViewController.swift
//  MyLocations
//
//  Created by BT-Training on 02/09/16.
//  Copyright © 2016 BT-Training. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData
import MBProgressHUD

class TagDescriptionViewController: UITableViewController {
    
    // MARK: outlets
    
    @IBOutlet weak var descriptionArea: UITextView!
    @IBOutlet weak var categoryLabel:   UILabel!
    @IBOutlet weak var latitudeLabel:   UILabel!
    @IBOutlet weak var longitudeLabel:  UILabel!
    @IBOutlet weak var addressLabel:    UILabel!
    @IBOutlet weak var dateLabel:       UILabel!
    @IBOutlet weak var addPhotoLabel:   UILabel!
    @IBOutlet weak var photoImage:      UIImageView!
    
    // MARK: attributes
    
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark: CLPlacemark?
    let dateFormatter: NSDateFormatter = {
        let formatter       = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .ShortStyle
        return formatter
    }()
    
    var category = "No category"
    var managedObjectContext: NSManagedObjectContext!
    var date = NSDate()
    var descriptionText = ""
    
    var locationToEdit: Location? {
        didSet {
            guard let location = locationToEdit else {
                return
            }
            
            descriptionText      = location.locationDescription
            category             = location.category
            coordinate.latitude  = location.latitude
            coordinate.longitude = location.longitude
            date                 = location.date
            placemark            = location.placemark
        }
    }
    
    var image: UIImage?
    
    // MARK: Controller overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if locationToEdit != nil {
            title = "Edit tag"
        }
        
        descriptionArea.text = descriptionText
        categoryLabel.text   = category
        latitudeLabel.text   = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text  = String(format: "%.8f", coordinate.longitude)
        
        if let placemark = self.placemark {
            addressLabel.text = stringFromPlacemark(placemark)
        }
        else {
            addressLabel.text = "No address found"
        }
        
        dateLabel.text = formatDate(date)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CategoryTableSegue" {
            if let categoryTableViewController = segue.destinationViewController as? CategoryTableViewController {
                categoryTableViewController.selectedCategory = category
            }
        }
    }
    
    // MARK: Methods
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func done(sender: AnyObject) {
        let location: Location
        var doneMessage: String
        if let temp = locationToEdit {
            location = temp
            doneMessage = "Updated"
        }
        else {
            location = NSEntityDescription.insertNewObjectForEntityForName(
            "Location", inManagedObjectContext: managedObjectContext) as! Location
            doneMessage = "Tagged"
            location.photoID = nil
        }
        
        location.locationDescription = descriptionArea.text
        
        location.category  = category
        location.latitude  = coordinate.latitude
        location.longitude = coordinate.longitude
        location.date      = date
        location.placemark = placemark
        
        if let image = self.image {
            if !location.hasPhoto {
                location.photoID = Location.nextPhotoID()
            }
            
            if let data = UIImageJPEGRepresentation(image, 0.5) {
                do {
                    try data.writeToFile(location.photoPath, options: .DataWritingAtomic)
                }
                catch {
                    print("Erro writing file")
                }
            }
        }
        
        do {
            try managedObjectContext.save()
            
            let hud        = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            hud.mode       = .CustomView
            let image      = UIImage(named: "glyph-check")?.imageWithRenderingMode(.AlwaysTemplate)
            hud.customView = UIImageView(image: image)
            // hud.bezelView to access background color
            hud.label.text = doneMessage
            
            //        hud.hideAnimated(true, afterDelay: 5)
            //        hud.completionBlock = {
            //            self.dismissViewControllerAnimated(true, completion: nil)
            //        }
            
            afterDelay(1) {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        catch {
            fatalCoreDataError(error)
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
    
    func pickPhoto() {
        if true || UIImagePickerController.isSourceTypeAvailable(.Camera) {
            showPhotoMenu()
        }
        else {
            takeOrChoosePhoto(.PhotoLibrary)
        }
    }
    
    func takeOrChoosePhoto(source: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType    = source
        imagePicker.allowsEditing = true
        imagePicker.delegate      = self
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func showPhotoMenu() {
        let alert           = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let cancelAction    = UIAlertAction(title: "Cancel",     style: .Cancel, handler:  nil)
        let takePhotoAction = UIAlertAction(title: "Take photo", style: .Default) {
            _ in
            self.takeOrChoosePhoto(.Camera)
        }
        
        let chooseFromLibraryAction = UIAlertAction(title: "Choose from library", style: .Default) {
            _ in
            self.takeOrChoosePhoto(.PhotoLibrary)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(takePhotoAction)
        alert.addAction(chooseFromLibraryAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func showImage(image: UIImage) {
        photoImage.image     = image
        photoImage.hidden    = false
        addPhotoLabel.hidden = true
        
        photoImage.frame = CGRect(x: 10, y: 10, width: 260, height: 260)
        
        tableView.reloadData()
    }
}

// MARK: Extension - TableView delegate

extension TagDescriptionViewController {
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            pickPhoto()
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 0 {
            if photoImage.hidden {
                return 44
            }
            else {
                return 280
            }
        }
        else {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }
}

// MARK: Extension - ImagePicker & NavigationController delegates

extension TagDescriptionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dismissViewControllerAnimated(true, completion: nil)
        
        image = info[UIImagePickerControllerEditedImage] as? UIImage
        if let image = self.image {
            showImage(image)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

