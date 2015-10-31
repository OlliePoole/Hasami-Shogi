//
//  HSGameViewController+GameLogic.swift
//  Hasami Shogi
//
//  Created by Oliver Poole on 29/10/2015.
//  Copyright © 2015 OliverPoole. All rights reserved.
//

import UIKit
import Foundation

enum CheckingState {
    case North, NorthEast, East, SouthEast, South, SouthWest, West, NorthWest
}

// MARK: - HSGameBoardViewControllerDelegate
extension HSGameViewController: HSGameLogicDelegate {
    
    func gameBoard(gameBoard: HSGameBoardViewController, checkIfCellAtIndex startIndex: NSIndexPath, hasTheSameOwnerAsCellAt endIndex: NSIndexPath) -> Bool! {
        
        let startCell = gameBoard.collectionView.cellForItemAtIndexPath(startIndex) as! HSGameBoardCollectionViewCell
        let endCell = gameBoard.collectionView.cellForItemAtIndexPath(endIndex) as! HSGameBoardCollectionViewCell
        
        return startCell.currentState == endCell.currentState && startCell.currentState != .Empty
    }
    
    func gameBoard(gameBoard: HSGameBoardViewController, canMovePieceFrom startIndex: NSIndexPath, to endIndex: NSIndexPath) -> Bool! {
        
        func cellForIndex(atRow: Int, inSection: Int, on gameBoard: HSGameBoardViewController) -> HSGameBoardCollectionViewCell {
            return gameBoard.collectionView.cellForItemAtIndexPath(NSIndexPath(forRow: atRow, inSection: inSection)) as! HSGameBoardCollectionViewCell
        }
        
        if startIndex == endIndex {
            return false
        }
        
        // Does the user want to move horizontally or vertically
        if startIndex.section == endIndex.section {
            
            // Does the user want to move left or right?
            if startIndex.row > endIndex.row {
                
                // Move left
                for var x = startIndex.row - 1; x >= endIndex.row; x-- {
                    
                    // Check each cell between the start and the end
                    let cell = cellForIndex(x, inSection: startIndex.section, on: gameBoard)
                    
                    if cell.currentState != .Empty {
                        // A counter has been found blocking the way
                        return false
                    }
                }
                
                // No counters found
                return true
            }
            else {
                // Move right
                for var x = startIndex.row + 1; x <= endIndex.row; x++ {
                    
                    // Check each cell between the start and the end
                    let cell = cellForIndex(x, inSection: startIndex.section, on: gameBoard)
                    
                    if cell.currentState != .Empty {
                        // A counter has been found blocking the way
                        return false
                    }
                }
                
                // No counters found
                return true
            }
        }
        else if startIndex.row == endIndex.row { // Movement is vertical
            
            // Does the user want to move up or down?
            if startIndex.section > endIndex.section {
                
                // Move up
                for var x = startIndex.section - 1; x >= endIndex.section; x-- {
                    
                    // Check each cell between the start and the end
                    let cell = cellForIndex(startIndex.row, inSection: x, on: gameBoard)
                    
                    if cell.currentState != .Empty {
                        // A counter has been found blocking the way
                        return false
                    }
                }
                
                // No counters found
                return true
            }
            else {
                
                // Move down
                for var x = startIndex.section + 1; x <= endIndex.section; x++ {
                    
                    // Check each cell between the start and the end
                    let cell = cellForIndex(startIndex.row, inSection: x, on: gameBoard)
                    
                    if cell.currentState != .Empty {
                        // A counter has been found blocking the way
                        return false
                    }
                }
                
                // No counters found
                return true
            }
        }
        else {
            // Movement is not vertical or horizontal
            return false
        }
    }
    
    func gameBoard(gameBoard: HSGameBoardViewController, checkForDeathAt currentIndex: NSIndexPath, currentPlayer player: Player) -> [NSIndexPath]? {
        
        var checksToMake = [CheckingState.North, .South, .West, .East]
        var deathIndexPaths = [NSIndexPath]()
        
        let friendlyCellState = player == .PlayerOne ? CellState.RedCounter : CellState.BlueCounter
        var shouldLoop = true
        
        while shouldLoop && checksToMake.count > 0 {
            
            let currentCheck = checksToMake.removeFirst()
            
            let counterIterator = GameBoardCounterIterator(gameBoard: gameBoard, currentCheck: currentCheck, friendlyCellState: friendlyCellState)
            
            /**
            *  Empty cell found, reset the death indexs and stop iterating
            */
            counterIterator.emptyCellAction = { (indexPath) -> Void in
                deathIndexPaths = [NSIndexPath]()
                counterIterator.stopIterating()
            }
            
            /**
            *  An enemy cell has been found, add the index to the death array
            */
            counterIterator.enemyCellAction = { (indexPath) -> Void in
                deathIndexPaths.append(indexPath)
            }
            
            /**
            *  When a friendly cell is found, stop iterating and stop looping so the function can return
            */
            counterIterator.friendlyCellAction = { (indexPath) -> Void in
                counterIterator.stopIterating()
                shouldLoop = false
            }
            
            counterIterator.iterate(currentIndex)
        }
        
        // All checks have been made
        return deathIndexPaths
    }
    
    func gameBoard(gameBoard: HSGameBoardViewController, checkForWinningConditionsWith playerOneInfo: PlayerInfo, playerTwoInfo: PlayerInfo) -> Bool! {
        
        // Return based on how many counters are needed to win
        let playerOneWon = HSGameConstants.numberOfPiecesPerPlayer - playerOneInfo.countersRemaining >= HSGameConstants.numberOfPiecesToWin
        let playerTwoWon = HSGameConstants.numberOfPiecesPerPlayer - playerTwoInfo.countersRemaining >= HSGameConstants.numberOfPiecesToWin
        
        // Check if either player has won, or a player has formed a line
        return playerOneWon || playerTwoWon
    }
    
    func gameBoard(gameBoard: HSGameBoardViewController, checkForFiveInARowWinningConditionsWithLastMove lastMove: NSIndexPath, andPlayerHomeSections sections: [Int], currentPlayer player: Player) -> Bool! {
        
        var gameWon : Bool = false
        
        // If line to win
        if HSGameConstants.lineToWin {
            
            // Check to ensure the move isn't in the user's home location
            if sections.contains(lastMove.section) {
                return false
            }
            
            let checksToMake = [(CheckingState.North, CheckingState.South), (.East, .West), (.NorthEast, .SouthWest), (.NorthWest, .SouthEast)]
            var counterCount = 1 // If there are 5 counters in row, the game is over
            let friendlyCellState = player == .PlayerOne ? CellState.RedCounter : CellState.BlueCounter
            
            
            // For each current check and it's opposite partner
            for (currentCheck, partnerCurrentCheck) in checksToMake {
                
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
                    counterCount++
                    
                    if counterCount == 5 {
                        gameWon = true
                        counterIterator.stopIterating()
                    }
                }
                
                
                /**
                *  Empty cell found, start new iterator to iterate in the opposite(partner) direction
                */
                counterIterator.emptyCellAction = { (indexPath) -> Void in
                    
                    let counterIterator = GameBoardCounterIterator(gameBoard: gameBoard, currentCheck: partnerCurrentCheck, friendlyCellState: friendlyCellState)
                    
                    /**
                    *  Empty cell found, reset the counter, stop iterating
                    */
                    counterIterator.emptyCellAction = { (indexPath) -> Void in
                        counterCount = 1
                        counterIterator.stopIterating()
                    }
                    
                    
                    /**
                    *  Friendly counter found, increment the counter, check for winning conditions
                    */
                    counterIterator.friendlyCellAction = { (indexPath) -> Void in
                        
                        if !sections.contains(indexPath.section) {
                            counterCount++
                        }
                        
                        if counterCount == 5 {
                            gameWon = true
                            counterIterator.stopIterating()
                        }
                    }
                    
                    
                    /**
                    *  Enemy counter found, stop iterating
                    */
                    counterIterator.enemyCellAction = { (indexPath) -> Void in
                        // Found an enemy cell, stop iterating
                        counterIterator.stopIterating()
                    }
                    
                    counterIterator.iterate(lastMove)
                }
                
                counterIterator.iterate(lastMove)
            }
        }
    
        return gameWon
    }
    
    
    func showNewGameDialogWithBoard(gameBoard: HSGameBoardViewController) {
        let newGameViewController = storyboard?.instantiateViewControllerWithIdentifier("HSNewGameViewController") as! HSNewGameViewController
        let navController = UINavigationController(rootViewController: newGameViewController)
        
        newGameViewController.delegate = self
        
        presentViewController(navController, animated: true, completion: nil)
    }
}
