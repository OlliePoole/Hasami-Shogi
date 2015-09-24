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
    
    /// The size of the board to play the game on
    static var boardSize = 81
    
    
    /// The type of game to be played
    static var gameType : GameType {
        get {
            return GameType(rawValue: NSUserDefaults.standardUserDefaults().integerForKey("GameType"))!
        }
        set {
            NSUserDefaults.standardUserDefaults().setInteger(gameType.rawValue, forKey: "GameType")
        }
    }
    
    
    /// If the current game type is HasamiShogi, return 9. If the game type is Dia Hasami Shogi return 18
    static var numberOfPiecesPerPlayer = HSGameConstants.gameType == .HasamiShogi ? 18 : 9
    
    
    /// In the Dia Hasami Shogi variant, if a line of pieces wins the game
    static var lineToWin : Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey("LineToWin")
        }
        set {
            NSUserDefaults.standardUserDefaults().setBool(lineToWin, forKey: "LneToWin")
        }
    }
    
    
    /// The number of pieces required to win a game
    static var numberOfPiecesToWin : Int {
        get {
            return NSUserDefaults.standardUserDefaults().integerForKey("PiecesToWin")
        }
        set {
            NSUserDefaults.standardUserDefaults().setInteger(numberOfPiecesToWin, forKey: "PiecesToWin")
        }
    }
}
