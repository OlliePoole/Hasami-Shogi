//
//  HSCoreDataAccessTests.swift
//  Hasami Shogi
//
//  Created by Oliver Poole on 25/09/2015.
//  Copyright © 2015 OliverPoole. All rights reserved.
//

import XCTest

@testable import Hasami_Shogi

class HSCoreDataAccessTests: XCTestCase {
    
    let tableName = "User"
    
    /**
    Function to test data can be retrieved from core data
    */
    func testRecordsFromTableWithTableName() {
        let results = HSCoreDataAccess.recordsFromTableWithTableName(tableName)
        
        if let _ = results {
            // data has been retrieved from core data
            XCTAssert(true)
        }
        else {
            // the table hasn't been found and something has gone wrong!
            XCTAssert(false)
        }
    }
    
    /**
    In this test, read data from Core Data, find the name of the first record
    Use that name to form a predicate that returns a single record
    */
    func testRecordsFromTableWithPredicate() {
        let results = HSCoreDataAccess.recordsFromTableWithTableName(tableName)
        
        if results?.count > 0 {
            if let result = results?[0] {
                
                // If the record is a User
                if let result = result as? User {
                    let username = result.username!
                    
                    let predicate = NSPredicate(format: "username == %@", username)
                    let predicateResults = HSCoreDataAccess.recordsFromTableWithTableName(tableName, predicate: predicate)
                    
                    // Asset that one record has been fetched
                    XCTAssert(predicateResults?.count == 1)
                }
            }
        }
        
        // One or more if statements have failed
        XCTAssert(false)
    }
}
