//
//  Functions.swift
//  MyLocations
//
//  Created by BT-Training on 05/09/16.
//  Copyright © 2016 BT-Training. All rights reserved.
//

import Foundation

func afterDelay(seconds: Double, closure: () -> ()) {
    let when = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC)))
    
    dispatch_after(when, dispatch_get_main_queue(), closure)
}
