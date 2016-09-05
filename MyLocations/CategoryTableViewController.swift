//
//  CategoryTableViewController.swift
//  MyLocations
//
//  Created by BT-Training on 05/09/16.
//  Copyright © 2016 BT-Training. All rights reserved.
//

import UIKit

//protocol CategoryTableDelegate: class {
//    func categoryTable(controller: CategoryTableViewController, didSelect: String)
//}

class CategoryTableViewController: UITableViewController {
    let categories = [
        "No category",
        "Bar",
        "Restaurant",
        "Store",
        "Park",
        "Pokestop",
        "House"
    ]
    
    var selectedCategory = ""
    var selectedIndex: NSIndexPath?
    
//    weak var delegate: CategoryTableDelegate?
    
    // MARK: Controller overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updateSelectedIndexPath()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "pickedCategory" {
            let cell = sender as! UITableViewCell
            if let indexPath = tableView.indexPathForCell(cell) {
                selectedCategory = categories[indexPath.row]
            }
        }
    }
    
    // MARK: Methods
    func updateSelectedIndexPath() {
        for i in 0..<categories.count {
            if categories[i] == selectedCategory {
                selectedIndex = NSIndexPath(forRow: i, inSection: 0)
                break
            }
        }
    }
}

// MARK: - Table view data source
extension CategoryTableViewController {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("categoryCell", forIndexPath: indexPath)
        
        cell.textLabel!.text = categories[indexPath.row]
        cell.accessoryType   = indexPath == selectedIndex ? .Checkmark : .None
        
        return cell
    }
}

// MARK: - Table view delegate
//extension CategoryTableViewController {
//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        let oldIndex = selectedIndex
//        
//        if indexPath != selectedIndex {
//            selectedCategory = categories[indexPath.row]
//            selectedIndex    = indexPath
//            
//            var toUpdate = [indexPath]
//            
//            if let oldIndex = oldIndex {
//                toUpdate.append(oldIndex)
//            }
//            
//            tableView.reloadRowsAtIndexPaths(toUpdate, withRowAnimation: .Automatic)
//            
//            if let delegate = self.delegate {
//                delegate.categoryTable(self, didSelect: selectedCategory)
//            }
//        }
//        else {
//            tableView.deselectRowAtIndexPath(indexPath, animated: true)
//        }
//    }
//}




