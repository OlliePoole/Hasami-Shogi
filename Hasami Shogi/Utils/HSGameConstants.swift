//
//  HSGameConstants.swift
//  Hasami Shogi
//
//  Created by Oliver Poole on 24/09/2015.
//  Copyright © 2015 OliverPoole. All rights reserved.
//

import UIKit

enum GameType : Int {
    case HasamiShogi
    case DiaHasamiShogi
}

/// Holds all the contants for defining the gameplay
class HSGameConstants: NSObject {
    
    /// The number of rows and cols for the game board
    static var numberOfRows = 9
    static var numberOfSections = 9
    
    
    /// The type of game to be played
    static var gameType : GameType {
        get {
            return GameType(rawValue: NSUserDefaults.standardUserDefaults().integerForKey("GameType"))!
        }
        set (gameType) {
            NSUserDefaults.standardUserDefaults().setInteger(gameType.rawValue, forKey: "GameType")
        }
    }
    
    
    /// If the current game type is HasamiShogi, return 9. If the game type is Dia Hasami Shogi return 18
    static var numberOfPiecesPerPlayer = HSGameConstants.gameType == .HasamiShogi ? 9 : 18
    
    
    /// In the Dia Hasami Shogi variant, if a line of pieces wins the game
    static var lineToWin : Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey("LineToWin")
        }
        set (lineToWin) {
            NSUserDefaults.standardUserDefaults().setBool(lineToWin, forKey: "LineToWin")
        }
    }
    
    
    /// The number of counters that need to be taken to win a game
    static var numberOfPiecesToWin : Int {
        get {
            return NSUserDefaults.standardUserDefaults().integerForKey("PiecesToWin")
        }
        set (numberOfPiecesToWin) {
            NSUserDefaults.standardUserDefaults().setInteger(numberOfPiecesToWin, forKey: "PiecesToWin")
        }
    }
}
