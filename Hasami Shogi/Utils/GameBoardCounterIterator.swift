//
//  GameBoardCounterIterator.swift
//  Hasami Shogi
//
//  Created by Oliver Poole on 31/10/2015.
//  Copyright © 2015 OliverPoole. All rights reserved.
//

import Foundation

class GameBoardCounterIterator {
    
    var emptyCellAction : ((indexPath: NSIndexPath) -> Void)!
    var friendlyCellAction : ((indexPath: NSIndexPath) -> Void)!
    var enemyCellAction : ((indexPath: NSIndexPath) -> Void)!
    
    var gameBoard : HSGameBoardViewController
    var currentCheck : CheckingState
    var friendlyCellState : CellState
    var shouldIterate = true
    
    init(gameBoard: HSGameBoardViewController, currentCheck: CheckingState, friendlyCellState: CellState) {
        self.gameBoard = gameBoard
        self.currentCheck = currentCheck
        self.friendlyCellState = friendlyCellState
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
        
        return indexPath.row >= 0 && indexPath.section >= 0 && indexPath.row < HSGameConstants.numberOfRows && indexPath.section < HSGameConstants.numberOfSections
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
    
    
    /**
     Start iterating through the cells in the direction specifed while the next cell
     is within the board limits
     
     - parameter startingIndex: The index to start counting from
     */
    func iterate(startingIndex: NSIndexPath) {
        
        shouldIterate = true
        var nextIndex = nextIndexPath(startingIndex, withCurrentCheck: currentCheck)
        
        // While the next cell is within the limits of the board
        while checkGameBoardBoundariesAtIndex(nextIndex, withCurrentCheck: currentCheck)! && shouldIterate {
            
            // What is the state of the next cell?
            let cellState = cellStateAtIndexPath(nextIndex, on: gameBoard)
            
            // Based on the state of the cell, perform an action
            if cellState == .Empty && emptyCellAction != nil {
                emptyCellAction(indexPath: nextIndex)
            }
            
            if cellState == friendlyCellState && friendlyCellAction != nil {
                friendlyCellAction(indexPath: nextIndex)
            }
            
            // If the cell is not friendly or empty, it must belong to the enemy
            if cellState != friendlyCellState && cellState != .Empty && enemyCellAction != nil {
                enemyCellAction(indexPath: nextIndex)
            }
            
            nextIndex = nextIndexPath(nextIndex, withCurrentCheck: currentCheck)
        }
    }
    
    func stopIterating() {
        shouldIterate = false
    }
}
