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
class HSGameDataManager: NSObject {
    
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
     Creates dummy users to launch the game instead of requiring the user to register before playing
     
     - returns: The two created users
     */
    static func createDummyUsersForFirstLaunch() -> (playerOne: User, playerTwo: User) {
        let playerOne = HSGameDataManager.createUserWith("Player One", bio: "Player one bio", profileImage: nil, isDefaultUser: true)
        let playerTwo = HSGameDataManager.createUserWith("Player Two", bio: "Player two bio", profileImage: nil, isDefaultUser: true)
        
        return (playerOne!, playerTwo!)
    }
    
    
    /**
     When a new game is started, save the two users playing. They then become the default users
     to load the game with next time
     
     - parameter playerOne: player one
     - parameter playerTwo: player two
     */
    static func saveCurrentTwoPlayersAsDefaultWithPlayerOne(playerOne: User, playerTwo: User) {
        // Find the current default users
        let predicate = NSPredicate(format: "isDefault == true")
        
        let defaultUsers = HSCoreDataAccess.recordsFromTableWithTableName(userTableName, predicate: predicate)
        
        // Set their default flags to no
        for user in defaultUsers as! [User] {
            user.isDefault = false
        }
        
        // Set the new player's default flags to yes
        for user in [playerOne, playerTwo] {
            user.isDefault = true
        }
        
        // Save the context
        HSCoreDataAccess.saveContext()
    }
    
    
    /**
     Loads the two default players from defaults. This means the user doesn't 
     have to pick new players everytime they start a new game
     
     - returns: The two default players in a tuple
     */
    static func loadDefaultPlayers() -> (playerOne: User, playerTwo: User) {
        // Find the current default users
        let predicate = NSPredicate(format: "isDefault == true")
        
        let defaultUsers = HSCoreDataAccess.recordsFromTableWithTableName(userTableName, predicate: predicate)
        
        return (defaultUsers![0] as! User, defaultUsers![1] as! User)
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
    static func createUserWith(userName: String, bio: String, profileImage: UIImage?, isDefaultUser: Bool) -> User? {
        
        let user = HSCoreDataAccess.createUserEntity() as! User
        user.username = userName
        user.bio = bio
        //user.profileImage = profileImage //TODO: Fix this
        user.isDefault = isDefaultUser
        
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
