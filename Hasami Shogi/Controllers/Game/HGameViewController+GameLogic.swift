//
//  HSGameViewController+GameLogic.swift
//  Hasami Shogi
//
//  Created by Oliver Poole on 29/10/2015.
//  Copyright © 2015 OliverPoole. All rights reserved.
//

import UIKit
import Foundation

// MARK: - HSGameViewController extention
extension HSGameViewController {
    // Extend the HSGameView Controller to add extra functionality, specific to game board logic operations
    
    enum CheckingState {
        case North, NorthEast, East, SouthEast, South, SouthWest, West, NorthWest
    }
    
    /**
     - parameter indexPath: The index path of the cell to check
     - parameter gameBoard: The game board where the request origininated
     
     - returns: The current cell state of a specified cell
     */
    func cellStateAtIndexPath(indexPath: NSIndexPath, on gameBoard: HSGameBoardViewController) -> CellState {
        let cell = gameBoard.collectionView.cellForItemAtIndexPath(indexPath) as! HSGameBoardCollectionViewCell
        
        return cell.currentState
    }
    
    
    /**
     Checks the current boundaries, to ensure that the next cell selected isn't out of bounds
     
     - parameter indexPath:     The indexpath of the next cell to be checked
     - parameter checkingState: The position of the cell in respect to the previous cell
     
     - returns: True, if the next cell is not out of bounds
     */
    func checkGameBoardBoundariesAtIndex(indexPath: NSIndexPath, withCurrentCheck checkingState: CheckingState) -> Bool! {
        switch checkingState {
        case .North: return indexPath.section > 0
        case .South: return indexPath.section < HSGameConstants.numberOfSections
        case .West: return indexPath.row > 0
        case .East: return indexPath.row < HSGameConstants.numberOfRows
        
        case .NorthEast: return indexPath.section > 0 && indexPath.row < HSGameConstants.numberOfRows
        case .SouthEast: return indexPath.section < HSGameConstants.numberOfSections && indexPath.row < HSGameConstants.numberOfRows
        case .SouthWest: return indexPath.section < HSGameConstants.numberOfSections && indexPath.row > 0
        case .NorthWest: return indexPath.section > 0 && indexPath.row > 0
        }
    }
    
    
    /**
     - parameter currentIndexPath: The index path of the cell currently being checked
     - parameter checkingState:    The position of the next cell with respect to the current cell
     
     - returns: The index path of the next cell to check
     */
    func nextIndexPath(currentIndexPath: NSIndexPath, withCurrentCheck checkingState: CheckingState) -> NSIndexPath {
        
        switch checkingState {
        case .North: return NSIndexPath(forRow: currentIndexPath.row, inSection: currentIndexPath.section - 1)
        case .South: return NSIndexPath(forRow: currentIndexPath.row, inSection: currentIndexPath.section + 1)
        case .West: return NSIndexPath(forRow: currentIndexPath.row - 1, inSection: currentIndexPath.section)
        case .East: return NSIndexPath(forRow: currentIndexPath.row + 1, inSection: currentIndexPath.section)
            
        case .NorthEast: return NSIndexPath(forRow: currentIndexPath.row + 1, inSection: currentIndexPath.section - 1)
        case .SouthEast: return NSIndexPath(forRow: currentIndexPath.row + 1, inSection: currentIndexPath.section + 1)
        case .SouthWest: return NSIndexPath(forRow: currentIndexPath.row - 1, inSection: currentIndexPath.section + 1)
        case .NorthWest: return NSIndexPath(forRow: currentIndexPath.row - 1, inSection: currentIndexPath.section + 1)
        }
    }
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
    
    func gameBoard(gameBoard: HSGameBoardViewController, checkForDeathAt currentIndex: NSIndexPath) -> [NSIndexPath]? {
        
        let checksToMake = [CheckingState.North, .South, .West, .East]
        var deathIndexPaths = [NSIndexPath]()
        
        for currentCheck in checksToMake {
            
            var nextCellIndex = nextIndexPath(currentIndex, withCurrentCheck: currentCheck)
            
            while checkGameBoardBoundariesAtIndex(nextCellIndex, withCurrentCheck: currentCheck)! {
                
                // What is the state of the next cell?
                let cellState = cellStateAtIndexPath(nextCellIndex, on: gameBoard)
                
                // If it's empty we can stop checking
                if cellState == .Empty {
                    deathIndexPaths = [NSIndexPath]()
                    break
                }
                
                // If the cell has a different owner to the current cell
                if self.gameBoard(gameBoard, checkIfCellAtIndex: nextCellIndex, hasTheSameOwnerAsCellAt: currentIndex) == false {
                    // Yes it does, add to deathIndexPaths
                    deathIndexPaths.append(nextCellIndex)
                } else {
                    // We've found a friendly counter, return from funtion
                    return deathIndexPaths
                }
                
                nextCellIndex = nextIndexPath(nextCellIndex, withCurrentCheck: currentCheck)
            }
        }
        
        // All checks have been made
        return deathIndexPaths
    }
    
    func gameBoard(gameBoard: HSGameBoardViewController, checkForWinningConditionsWith playerOneInfo: PlayerInfo, playerTwoInfo: PlayerInfo, lastMove indexPath: NSIndexPath) -> Bool! {
        
        // Return based on how many counters are needed to win
        let playerOneWon = HSGameConstants.numberOfPiecesPerPlayer - playerOneInfo.countersRemaining >= HSGameConstants.numberOfPiecesToWin
        let playerTwoWon = HSGameConstants.numberOfPiecesPerPlayer - playerTwoInfo.countersRemaining >= HSGameConstants.numberOfPiecesToWin
        
        // Check if either player has won, or a player has formed a line
        return playerOneWon || playerTwoWon
    }
    
    func gameBoard(gameBoard: HSGameBoardViewController, checkForFiveInARowWinningConditionsWithLastMove lastMove: NSIndexPath, andPlayerHomeSection section: Int) -> Bool! {
        
        // If line to win
        if HSGameConstants.lineToWin {
            
            let checksToMake = [(CheckingState.North, CheckingState.South), (.East, .West), (.NorthEast, .SouthWest), (.NorthWest, .SouthEast)]
            var counterCount = 0 // If there are 5 counters in row, the game is over
            
            // For each current check and it's opposite partner
            for (currentCheck, partnerCurrentCheck) in checksToMake {
                
                // Find the next cell to check
                var nextCellIndex = nextIndexPath(lastMove, withCurrentCheck: currentCheck)
                
                // While the next cell is not out of the game boundaries
                while checkGameBoardBoundariesAtIndex(nextCellIndex, withCurrentCheck: currentCheck)! {
                    
                    // What is the state of the next cell?
                    var cellState = cellStateAtIndexPath(nextCellIndex, on: gameBoard)
                    
                    // Is it empty?
                    if cellState == .Empty {
                        // Check in the opposite direction
                        
                        nextCellIndex = nextIndexPath(nextCellIndex, withCurrentCheck: partnerCurrentCheck)
                        
                        while checkGameBoardBoundariesAtIndex(nextCellIndex, withCurrentCheck: partnerCurrentCheck)! {
                            
                            // What is the state of the next cell?
                            cellState = cellStateAtIndexPath(nextCellIndex, on: gameBoard)
                            
                            if cellState == .Empty {
                                counterCount = 0
                                break
                            }
                            else {
                                // if the next cell has the same owner as the current cell
                                if self.gameBoard(gameBoard, checkIfCellAtIndex: nextCellIndex, hasTheSameOwnerAsCellAt: lastMove)! {
                                    counterCount++
                                    
                                    if counterCount == 5 {
                                        return true
                                    }
                                }
                                else {
                                    break
                                }
                            }
                            nextCellIndex = nextIndexPath(nextCellIndex, withCurrentCheck: currentCheck)
                        }
                    }
                    else {
                        
                        // if the next cell has the same owner as the current cell
                        if self.gameBoard(gameBoard, checkIfCellAtIndex: nextCellIndex, hasTheSameOwnerAsCellAt: lastMove)! {
                            counterCount++
                            
                            if counterCount == 5 {
                                return true
                            }
                        }
                        else {
                            break
                        }
                        
                        nextCellIndex = nextIndexPath(nextCellIndex, withCurrentCheck: currentCheck)
                    }
                }
            }
        }
        return false
    }
    
    func showNewGameDialogWithBoard(gameBoard: HSGameBoardViewController) {
        let newGameViewController = storyboard?.instantiateViewControllerWithIdentifier("HSNewGameViewController") as! HSNewGameViewController
        let navController = UINavigationController(rootViewController: newGameViewController)
        
        newGameViewController.delegate = self
        
        presentViewController(navController, animated: true, completion: nil)
    }
}
