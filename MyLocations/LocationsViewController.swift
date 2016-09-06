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
    
    var locations = [Location]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: #selector(refresh), forControlEvents: .ValueChanged)
        
        refresh()
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
                
                controller.managedObjectContext = self.managedObjectContext
                if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell) {
                    controller.locationToEdit = locations[indexPath.row]
                }
            }
        }
    }
    
    func refresh() {
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("Location",
                                                       inManagedObjectContext: managedObjectContext)
        fetchRequest.entity = entity
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let foundObjects = try managedObjectContext.executeFetchRequest(fetchRequest)
            locations = foundObjects as! [Location]
            tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
        catch {
            fatalCoreDataError(error)
        }
    }
}

// MARK: - Table view data source
extension LocationsViewController {
    
//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 1
//    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let location = locations[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("locationCell", forIndexPath: indexPath) as! LocationCell
        cell.configureForLocation(location)
        
        return cell
    }
}
