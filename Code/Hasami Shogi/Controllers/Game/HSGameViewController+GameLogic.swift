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
        
        func cellForIndex(indexPath : NSIndexPath, on gameBoard: HSGameBoardViewController) -> HSGameBoardCollectionViewCell {
            return gameBoard.collectionView.cellForItemAtIndexPath(indexPath) as! HSGameBoardCollectionViewCell
        }
        
        if startIndex == endIndex { return false }
        
        var movementDirection : CheckingState?
        
        // Does the user want to move horizontally or vertically
        if startIndex.section == endIndex.section {
            
            // Does the user want to move left or right?
            if startIndex.row > endIndex.row {
                movementDirection = .West // Move left
            }
            else {
                movementDirection = .East // Move right
            }
        }
        else if startIndex.row == endIndex.row { // Movement is vertical
            
            // Does the user want to move up or down?
            if startIndex.section > endIndex.section {
                movementDirection = .North // Move up
            }
            else {
                movementDirection = .South // Move down
            }
        }
        else { return false } // Movement is not up / down / left / right
        
        
        // The state of the cell at the start position is the friendly state of the player
        let friendlyState = cellForIndex(startIndex, on: gameBoard).currentState
        var movementIsValid = false
        
        let counterIterator = GameBoardCounterIterator(gameBoard: gameBoard, currentCheck: movementDirection!, friendlyCellState: friendlyState)
        
        /**
        *  If an empty cell is found, check if the cell is the end cell
        *  
        *  If so, set the boolean flag to true and stop iterating
        */
        counterIterator.emptyCellAction = { (indexPath) -> Void in
            
            // Check if the desired move location has been reached
            if indexPath == endIndex {
                movementIsValid = true
                counterIterator.stopIterating()
            }
        }
        
        // If a friendly or enemy cell is found, movement is not valid
        counterIterator.friendlyCellAction = { (indexPath) -> Void in counterIterator.stopIterating() }
        counterIterator.enemyCellAction = { (indexPath) -> Void in counterIterator.stopIterating() }
        
        // Start itereating from the starting location
        counterIterator.iterate(startIndex)
        
        return movementIsValid
    }
    
    func gameBoard(gameBoard: HSGameBoardViewController, checkForDeathAt currentIndex: NSIndexPath, currentPlayer player: Player) -> [NSIndexPath] {
        
        var checksToMake = [CheckingState.North, .South, .West, .East]
        var deathIndexPaths = [NSIndexPath]()
        
        let friendlyCellState = player == .PlayerOne ? CellState.RedCounter : CellState.BlueCounter
        var shouldLoop = true
        var hasClosingCounter = false // Used to check that a closing counter is found for death checks
        
        
        while shouldLoop && checksToMake.count > 0 {
            
            let currentCheck = checksToMake.removeFirst()
            
            // Reset the death indexes
            deathIndexPaths = [NSIndexPath]()
            
            let counterIterator = GameBoardCounterIterator(gameBoard: gameBoard, currentCheck: currentCheck, friendlyCellState: friendlyCellState)
            
            /**
            *  Empty cell found, reset the death indexes and stop iterating
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
                hasClosingCounter = true
            }
            
            counterIterator.iterate(currentIndex)
        }
        
        // All checks have been made, make sure a closing counter has been found before returning death indexes
        return (hasClosingCounter) ? deathIndexPaths : [NSIndexPath]()
    }
    
    func gameBoard(gameBoard: HSGameBoardViewController, checkForWinningConditionsWith playerOneInfo: PlayerInfo, playerTwoInfo: PlayerInfo) -> Bool! {
        
        // Return based on how many counters are needed to win
        let playerOneWon = HSGameConstants.numberOfPiecesPerPlayer - playerOneInfo.countersRemaining >= HSGameConstants.numberOfPiecesToWin
        let playerTwoWon = HSGameConstants.numberOfPiecesPerPlayer - playerTwoInfo.countersRemaining >= HSGameConstants.numberOfPiecesToWin
        
        // Check if either player has won, or a player has formed a line
        return playerOneWon || playerTwoWon
    }
    
    func showNewGameDialogWithBoard(gameBoard: HSGameBoardViewController) {
        let newGameViewController = storyboard?.instantiateViewControllerWithIdentifier("HSNewGameViewController") as! HSNewGameViewController
        let navController = UINavigationController(rootViewController: newGameViewController)
        
        newGameViewController.delegate = self
        
        presentViewController(navController, animated: true, completion: nil)
    }
}
