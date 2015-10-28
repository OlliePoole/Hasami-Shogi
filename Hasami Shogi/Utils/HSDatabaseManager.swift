//
//  HSDatabaseManager.swift
//  Hasami Shogi
//
//  Created by Oliver Poole on 26/09/2015.
//  Copyright © 2015 OliverPoole. All rights reserved.
//

import UIKit

/// A further Core Data layer, sitting ontop of CoreDataAccess
/// to give more useful methods
class HSDatabaseManager: NSObject {
    
    static let userTableName = "User"

    /**
    Fetches all the users from Core Data
    
    - returns: All the users
    */
    static func fetchAllUsers() -> Array<User>? {
        let users = HSCoreDataAccess.recordsFromTableWithTableName(userTableName)
        
        return users as? [User]
    }
    
    
    /**
     When first launching, create two users "Player One", "Player Two"
     
     - returns: The two new users
     */
    static func createDummyUsersForFirstLaunch() -> (playerOne: User, playerTwo: User) {
        let playerOne = HSDatabaseManager.createUserWith("Player One", bio: "Player one bio", profileImage: nil)
        let playerTwo = HSDatabaseManager.createUserWith("Player Two", bio: "Player two bio", profileImage: nil)
        
        return (playerOne!, playerTwo!)
    }
    
    /**
    Fetches a single user based on their username
    
    - parameter username: The username of the user to search for
    
    - returns: If the user is found, the user object. Else nil
    */
    static func fetchUserWith(username: String) -> User? {
        let predicate = NSPredicate(format: "username = %@", username)
        
        let users = HSCoreDataAccess.recordsFromTableWithTableName(userTableName, predicate: predicate) as? [User]
        
        return users?.first
    }
    
    
    /**
    Creates a new User object and saves to Core Data
    
    - parameter userName:     The desired username
    - parameter bio:          The short bio for the new user
    - parameter profileImage: The profile image, nil if none
    
    - returns: The newly created User object, returns nil if save failed
    */
    static func createUserWith(userName: String, bio: String, profileImage: UIImage?) -> User? {
        
        let user = HSCoreDataAccess.createUserEntity() as! User
        user.username = userName
        user.bio = bio
        //user.profileImage = profileImage //TODO: Fix this
        
        if HSCoreDataAccess.saveContext() {
            // Save was successful
            return user
        }
        else {
            // Save failed
            return nil
        }
    }
    
    
    /**
    Used to manually save any edited information
    
    - returns: A Boolean value for the success of the save
    */
    static func saveCoreDataContext() -> Bool! {
        return HSCoreDataAccess.saveContext()
    }
    
}
