//
//  User.swift
//  Hasami Shogi
//
//  Created by Oliver Poole on 25/09/2015.
//  Copyright © 2015 OliverPoole. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class User: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    var profileImage : UIImage {
        get {
            return UIImage(named: "Homer Simpson")!
        }
    }
}
