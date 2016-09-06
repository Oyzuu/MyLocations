//
//  LocationsViewController.swift
//  MyLocations
//
//  Created by BT-Training on 06/09/16.
//  Copyright © 2016 BT-Training. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class LocationsViewController: UITableViewController {
    
    var managedObjectContext: NSManagedObjectContext!
    
//    var locations = [Location]()
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription
            .entityForName("Location", inManagedObjectContext: self.managedObjectContext)
        fetchRequest.entity = entity
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchRequest.fetchBatchSize = 20
        
        let fetchedResultsController =
            NSFetchedResultsController(fetchRequest: fetchRequest,
                                       managedObjectContext: self.managedObjectContext,
                                       sectionNameKeyPath: nil, cacheName: "Locations")
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSFetchedResultsController.deleteCacheWithName("Locations")
        
//        self.refreshControl = UIRefreshControl()
//        self.refreshControl!.addTarget(self, action: #selector(refresh), forControlEvents: .ValueChanged)
        
        refresh()
    }
    
    override func viewWillAppear(animated: Bool) {
        tableView.tableFooterView = UIView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "editLocationSegue" {
            if let navigationController = segue.destinationViewController as? UINavigationController,
                controller = navigationController.viewControllers[0] as? TagDescriptionViewController {
                
                controller.managedObjectContext = self.managedObjectContext
                if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell) {
                    let location = fetchedResultsController.objectAtIndexPath(indexPath) as! Location
                    
                    controller.locationToEdit = location
                }
            }
        }
    }
    
    func refresh() {
        do {
            try fetchedResultsController.performFetch()
        }
        catch {
            fatalCoreDataError(error)
        }
        
        
//        let fetchRequest = NSFetchRequest()
//        let entity = NSEntityDescription.entityForName("Location",
//                                                       inManagedObjectContext: managedObjectContext)
//        fetchRequest.entity = entity
//        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
//        fetchRequest.sortDescriptors = [sortDescriptor]
//        
//        do {
//            let foundObjects = try managedObjectContext.executeFetchRequest(fetchRequest)
//            locations = foundObjects as! [Location]
//            tableView.reloadData()
//            self.refreshControl?.endRefreshing()
//        }
//        catch {
//            fatalCoreDataError(error)
//        }
    }
    
    deinit {
        fetchedResultsController.delegate = nil
    }
}

// MARK: - Table view data source
extension LocationsViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let location = fetchedResultsController.objectAtIndexPath(indexPath) as! Location
        
        let cell = tableView.dequeueReusableCellWithIdentifier("locationCell", forIndexPath: indexPath) as! LocationCell
        cell.configureForLocation(location)
        
        if indexPath.row % 2 == 1 {
//            cell.backgroundColor = UIColor(red: 14/255, green: 122/255, blue: 254/255, alpha: 0.1)
            cell.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.05)
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let location = fetchedResultsController.objectAtIndexPath(indexPath) as! Location
            managedObjectContext.deleteObject(location)
            tableView.reloadData()
            
            do {
                try managedObjectContext.save()
            }
            catch {
                fatalCoreDataError(error)
            }
        }
    }
}

// MARK: Table view delegate
extension LocationsViewController {
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

// MARK: NSFetchedResultsControllerDelegate
extension LocationsViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        case .Update:
            tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        case .Move  :
            tableView.moveRowAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch  type {
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
        case .Update:
            break
        case .Move  :
            break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
}
