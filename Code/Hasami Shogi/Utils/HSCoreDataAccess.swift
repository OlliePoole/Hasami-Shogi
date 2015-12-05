//
//  HSDatabaseManager.swift
//  Hasami Shogi
//
//  Created by Oliver Poole on 25/09/2015.
//  Copyright © 2015 OliverPoole. All rights reserved.
//

import UIKit
import CoreData

/// A layer for providing basic access to core data
class HSCoreDataAccess: NSObject {
    
    static var managedObjectContext : NSManagedObjectContext! {
        get {
            return (UIApplication.sharedApplication().delegate as! HSAppDelegate).managedObjectContext
        }
    }
    
    /**
    Returns records from a table in the core data model
    
    - parameter tableName: The name of the table
    
    - returns: The records from the model that match the tablename
    */
    static func recordsFromTableWithTableName(tableName: String) -> Array<AnyObject>? {
        
        let fetchRequest = HSCoreDataAccess.fetchRequest(tableName)
        
        return executeRequest(fetchRequest)
    }
    
    
    /**
    Returns records from a table in the core data model that match a certain predicate
    
    - parameter tableName: The name of the table to search
    - parameter predicate: The predicate to use in the search
    
    - returns: The records from the model matching the tablename and the predicate
    */
    static func recordsFromTableWithTableName(tableName: String, predicate: NSPredicate) -> Array<AnyObject>? {
        
        let fetchRequest = HSCoreDataAccess.fetchRequest(tableName)
        
        fetchRequest.predicate = predicate
        
        return executeRequest(fetchRequest)
    }
    
    
    /**
    Creates a new user managed object instance
    
    - returns: The newly created user managed object
    */
    static func createUserEntity() -> NSManagedObject {
        let userManagedObject = NSEntityDescription.insertNewObjectForEntityForName("User", inManagedObjectContext: HSCoreDataAccess.managedObjectContext)
        
        return userManagedObject
    }
    
    
    /**
    Saves the current context of Core Data
    
    - returns: True if the save was successful
    */
    static func saveContext() -> Bool {
        
        do {
            if let managedObjectContext = managedObjectContext {
                if managedObjectContext.hasChanges {
                    try managedObjectContext.save()
                    return true
                }
            }
        }
        catch {
            print(error)
        }
        
        return false
    }
    
    /**
    Builds a Fetch Request object
    
    - parameter entityName: The name of the entity for the object
    
    - returns: The Fetch Request Object
    */
    private static func fetchRequest(entityName: String) -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: entityName)
        
        fetchRequest.returnsObjectsAsFaults = false
        
        return fetchRequest
    }
    
    
    /**
    Executes a Fetch Request
    
    - parameter fetchRequest: The request to be executed
    
    - returns: The results of the request
    */
    private static func executeRequest(fetchRequest: NSFetchRequest) -> Array<AnyObject> {
        
        var results = [AnyObject]()
        
        do {
            results = try HSCoreDataAccess.managedObjectContext!.executeFetchRequest(fetchRequest)
        }
        catch {
            print(error)
        }
        
        return results
    }
}

