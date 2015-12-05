//
//  User+CoreDataProperties.swift
//  Hasami Shogi
//
//  Created by Oliver Poole on 25/09/2015.
//  Copyright © 2015 OliverPoole. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension User {

    @NSManaged var username: String?
    @NSManaged var bio: String?
    @NSManaged var points: NSNumber?

}
