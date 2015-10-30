//
//  HSGameViewController+GameLogic.swift
//  Hasami Shogi
//
//  Created by Oliver Poole on 29/10/2015.
//  Copyright © 2015 OliverPoole. All rights reserved.
//

import UIKit
import Foundation

// MARK: - HSGameBoardViewControllerDelegate
extension HSGameViewController: HSGameBoardViewControllerDelegate {
    
    func gameBoard(gameBoard: HSGameBoardViewController, checkIfCellAtIndex startIndex: NSIndexPath, hasTheSameOwnerAsCellAt endIndex: NSIndexPath) -> Bool! {
        
        let startCell = gameBoard.collectionView.cellForItemAtIndexPath(startIndex) as! HSGameBoardCollectionViewCell
        let endCell = gameBoard.collectionView.cellForItemAtIndexPath(endIndex) as! HSGameBoardCollectionViewCell
        
        return startCell.currentState == endCell.currentState && startCell.currentState != .Empty
    }
    
    func cellForIndex(atRow: Int, inSection: Int, on gameBoard: HSGameBoardViewController) -> HSGameBoardCollectionViewCell {
        return gameBoard.collectionView.cellForItemAtIndexPath(NSIndexPath(forRow: atRow, inSection: inSection)) as! HSGameBoardCollectionViewCell
    }
    
    func gameBoard(gameBoard: HSGameBoardViewController, canMovePieceFrom startIndex: NSIndexPath, to endIndex: NSIndexPath) -> Bool! {
        
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
        
        enum CheckingState {
            case Above
            case Below
            case Left
            case Right
        }
        
        func cellStateAtIndexPath(indexPath: NSIndexPath, on gameBoard: HSGameBoardViewController) -> CellState {
            let cell = gameBoard.collectionView.cellForItemAtIndexPath(indexPath) as! HSGameBoardCollectionViewCell
            
            return cell.currentState
        }
        
        func checkInitalGameBoardBoundariesAtIndex(indexPath: NSIndexPath) -> Bool! {
            return indexPath.section >= 0 &&
                (HSGameConstants.numberOfSections - indexPath.section) >= 0 &&
                currentIndex.row >= 0 &&
                (HSGameConstants.numberOfRows - currentIndex.row) >= 0
        }
        
        func checkRepeatGameBoardBoundariesAtIndex(indexPath: NSIndexPath, withCurrentCheck checkingState: CheckingState) -> Bool! {
            switch checkingState {
            case .Above: return indexPath.section > 0
            case .Below: return indexPath.section < HSGameConstants.numberOfSections
            case .Left: return indexPath.row > 0
            case .Right: return indexPath.row < HSGameConstants.numberOfRows
            }
        }
        
        func nextIndexPath(currentIndexPath: NSIndexPath, withCurrentCheck checkingState: CheckingState) -> NSIndexPath {
            
            switch checkingState {
            case .Above: return NSIndexPath(forRow: currentIndexPath.row, inSection: currentIndexPath.section - 1)
            case .Below: return NSIndexPath(forRow: currentIndexPath.row, inSection: currentIndexPath.section + 1)
            case .Left: return NSIndexPath(forRow: currentIndexPath.row - 1, inSection: currentIndexPath.section)
            case .Right: return NSIndexPath(forRow: currentIndexPath.row + 1, inSection: currentIndexPath.section)
            }
        }
        
        var checksToMake = [CheckingState.Above, CheckingState.Below, CheckingState.Left, CheckingState.Right]
        var deathIndexPaths = [NSIndexPath]()
        
        // Is the edge of the board within two spaces of the top of the cell?
        if checkInitalGameBoardBoundariesAtIndex(currentIndex)! {
            
            while checksToMake.count > 0 {
                
                let currentCheck = checksToMake.removeFirst()
                
                var nextCellIndex = nextIndexPath(currentIndex, withCurrentCheck: currentCheck)
                
                while checkRepeatGameBoardBoundariesAtIndex(nextCellIndex, withCurrentCheck: currentCheck)! {
                    
                    // What is the state of the next cell?
                    let cellState = cellStateAtIndexPath(nextCellIndex, on: gameBoard)
                    
                    // If it's empty we can stop checking
                    if cellState == .Empty {
                        break
                    }
                    
                    // If the cell has a differnt owner to the current cell
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
        }
        
        // All checks have been made, return empty array
        return [NSIndexPath]()
    }
    
    func gameBoard(gameBoard: HSGameBoardViewController, checkForWinningConditionsWith playerOneInfo: PlayerInfo, playerTwoInfo: PlayerInfo, lastMove indexPath: NSIndexPath) -> Bool! {
        
        // If line to win
        if HSGameConstants.lineToWin {
            
            // Check is last move resulted in a line
            
        }
        
        // Return true if either player only have one counter remaining
        return playerOneInfo.countersRemaining == HSGameConstants.numberOfPiecesToWin || playerTwoInfo.countersRemaining == HSGameConstants.numberOfPiecesToWin
    }
    
    func showNewGameDialogWithBoard(gameBoard: HSGameBoardViewController) {
        let newGameViewController = storyboard?.instantiateViewControllerWithIdentifier("HSNewGameViewController") as! HSNewGameViewController
        let navController = UINavigationController(rootViewController: newGameViewController)
        
        newGameViewController.delegate = self
        
        presentViewController(navController, animated: true, completion: nil)
    }
}
