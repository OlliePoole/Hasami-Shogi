//
//  HSGameViewController+FiveInARowLogic.swift
//  Hasami Shogi
//
//  Created by Oliver Poole on 05/12/2015.
//  Copyright © 2015 OliverPoole. All rights reserved.
//

import Foundation

/**
 A further extention of the HSGameViewController implementing the protocol method for 
 checking the five in row win conditon.
 */

extension HSGameViewController {

    func gameBoard(gameBoard: HSGameBoardViewController, checkForFiveInARowWinningConditionsWithLastMove lastMove: NSIndexPath, andPlayerHomeSections sections: [Int], currentPlayer player: Player) -> Bool! {
        
        var gameWon : Bool = false
        
        // If line to win
        if HSGameConstants.lineToWin && HSGameConstants.gameType == .DiaHasamiShogi {
            
            // Check to ensure the move isn't in the user's home location
            if sections.contains(lastMove.section) {
                return false
            }
            
            let checksToMake = [(CheckingState.North, CheckingState.South), (.East, .West), (.NorthEast, .SouthWest), (.NorthWest, .SouthEast)]
            var counterCount : Int // If there are 5 counters in row, the game is over
            let friendlyCellState = player == .PlayerOne ? CellState.RedCounter : CellState.BlueCounter
            
            
            // For each current check and it's opposite partner
            for (currentCheck, partnerCurrentCheck) in checksToMake {
                
                counterCount = 1
                
                let counterIterator = GameBoardCounterIterator(gameBoard: gameBoard, currentCheck: currentCheck, friendlyCellState: friendlyCellState)
                
                /**
                *  Found an enemy counter, stop iterating
                */
                counterIterator.enemyCellAction = { (indexPath) -> Void in
                    // Found an enemy cell, stop iterating
                    counterIterator.stopIterating()
                }
                
                
                /**
                *  Found a friendly counter, increment the counter and check for winning conditions
                */
                counterIterator.friendlyCellAction = { (indexPath) -> Void in
                    // If the section the cell is found in is not a home section
                    if !sections.contains(indexPath.section) {
                        counterCount++
                    }
                    
                    if counterCount == 5 {
                        gameWon = true
                        counterIterator.stopIterating()
                    }
                }
                
                
                /**
                *  Empty cell found, start new iterator to iterate in the opposite(partner) direction
                */
                counterIterator.emptyCellAction = { (indexPath) -> Void in
                    
                    counterIterator.stopIterating()
                    
                    let partnerCounterIterator = GameBoardCounterIterator(gameBoard: gameBoard, currentCheck: partnerCurrentCheck, friendlyCellState: friendlyCellState)
                    
                    /**
                    *  Empty cell found, reset the counter, stop iterating
                    */
                    partnerCounterIterator.emptyCellAction = { (indexPath) -> Void in
                        counterCount = 1
                        
                        partnerCounterIterator.stopIterating()
                    }
                    
                    
                    /**
                    *  Friendly counter found, increment the counter, check for winning conditions
                    */
                    partnerCounterIterator.friendlyCellAction = { (indexPath) -> Void in
                        
                        // If the section the cell is found in is not a home section
                        if !sections.contains(indexPath.section) {
                            counterCount++
                        }
                        
                        if counterCount == 5 {
                            gameWon = true
                            
                            partnerCounterIterator.stopIterating()
                        }
                    }
                    
                    
                    /**
                    *  Enemy counter found, stop iterating
                    */
                    partnerCounterIterator.enemyCellAction = { (indexPath) -> Void in
                        // Found an enemy cell, stop iterating
                        partnerCounterIterator.stopIterating()
                    }
                    
                    partnerCounterIterator.iterate(lastMove.copy() as! NSIndexPath)
                }
                
                counterIterator.iterate(lastMove.copy() as! NSIndexPath)
            }
        }
        
        return gameWon
    }
}