//
//  Functions.swift
//  MyLocations
//
//  Created by BT-Training on 05/09/16.
//  Copyright © 2016 BT-Training. All rights reserved.
//

import Foundation

let myManagedObjectContextSaveDidFailNotification = "myManagedObjectContextSaveDidFailNotification"
let applicationDocumentsDirectory: String = {
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
    
    return paths[0]
}()

func fatalCoreDataError(error: ErrorType) {
    print("*** FATAL ERROR: \(error) ***")
    
    NSNotificationCenter.defaultCenter()
        .postNotificationName(myManagedObjectContextSaveDidFailNotification, object: nil)
}

func afterDelay(seconds: Double, closure: () -> ()) {
    let when = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC)))
    
    dispatch_after(when, dispatch_get_main_queue(), closure)
}
