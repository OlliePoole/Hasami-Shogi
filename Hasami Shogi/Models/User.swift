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

    @NSManaged var username: String?
    @NSManaged var bio: String?
    @NSManaged var points: NSNumber?
    @NSManaged var isDefault: NSNumber?
    
    var profileImage : UIImage {
        get {
            return UIImage(named: "Homer Simpson")!
        }
    }
    
}
