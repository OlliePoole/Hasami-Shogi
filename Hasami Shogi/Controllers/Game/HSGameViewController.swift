//
//  HSGameViewController.swift
//  Hasami Shogi
//
//  Created by Oliver Poole on 24/09/2015.
//  Copyright © 2015 OliverPoole. All rights reserved.
//

import UIKit

/// The view controller responsible for playing the game
class HSGameViewController: UIViewController {
    
    var playerHasMadeFirstMove : Bool!
    var pieceSelected : Bool!
    
    var pieceSelectedPosition : NSIndexPath!
    
    var gamePiecePositions : [[Int]]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func menuButtonPressed(sender: AnyObject) {
        HSSideBarDelegateStore.delegate?.toggleSideBar(self)
    }
    
        
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "HSGameBoardViewController" {
            let gameBoardViewController = segue.destinationViewController as! HSGameBoardViewController
            
            gameBoardViewController.delegate = self
        }
    }
}

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
    
    
    func gameBoard(gameBoard: HSGameBoardViewController, checkForDeathAt currentIndex: NSIndexPath) -> (deathDetected: Bool!, deathIndexPath: NSIndexPath?) {
        
        let currentCell = cellForIndex(currentIndex.row, inSection: currentIndex.section, on: gameBoard)
        
        
        // Is the edge of the board within two spaces of the top of the cell?
        if currentIndex.section > 2 {
            let cellAbove = cellForIndex(currentIndex.row, inSection: currentIndex.section - 1, on: gameBoard)
            
            // Does the cell above contain an enemy counter?
            if cellAbove.currentState != currentCell.currentState && cellAbove.currentState != .Empty {
                
                let cellAboveAbove = cellForIndex(currentIndex.row, inSection: currentIndex.section - 2, on: gameBoard)
                
                // Does the cell above that contain a friendly counter?
                if cellAboveAbove.currentState == currentCell.currentState {
                    return (true, NSIndexPath(forRow: currentIndex.row, inSection: currentIndex.section - 1))
                }
            }
        }
        
        
        // Is the edge of the board within two spaces of the bottom of the cell?
        if (HSGameConstants.numberOfSections - currentIndex.section) > 2 {
            let cellBelow = cellForIndex(currentIndex.row, inSection: currentIndex.section + 1, on: gameBoard)
            
            // Does the cell below contain an enemy counter?
            if cellBelow.currentState != currentCell.currentState && cellBelow.currentState != .Empty {
                
                let cellBelowBelow = cellForIndex(currentIndex.row, inSection: currentIndex.section + 2, on: gameBoard)
                
                // Does that cell contain a friendly counter?
                if cellBelowBelow.currentState == currentCell.currentState {
                    return (true, NSIndexPath(forRow: currentIndex.row, inSection: currentIndex.section + 1))
                }
            }
        }
        
        
        // Is the edge of the board within two spaces of the left of the cell?
        if currentIndex.row > 2 {
            let leftCell = cellForIndex(currentIndex.row - 1, inSection: currentIndex.section, on: gameBoard)
            
            // Does that cell contain an enemy counter?
            if leftCell.currentState != currentCell.currentState && leftCell.currentState != .Empty {
                
                let leftLeftCell = cellForIndex(currentIndex.row - 2, inSection: currentIndex.section, on: gameBoard)
                
                // Does that cell contain a friendly counter?
                if leftLeftCell.currentState == currentCell.currentState {
                    return (true, NSIndexPath(forRow: currentIndex.row - 1, inSection: currentIndex.section))
                }
                
            }
        }
        
        
        // Is the edge of the board within two spaces of the right of the cell?
        if (HSGameConstants.numberOfRows - currentIndex.row) > 2 {
            let rightCell = cellForIndex(currentIndex.row + 1, inSection: currentIndex.section, on: gameBoard)
            
            // Does that cell contain an enemy counter?
            if rightCell.currentState != currentCell.currentState && rightCell.currentState != .Empty {
                
                let rightRightCell = cellForIndex(currentIndex.row + 2, inSection: currentIndex.section, on: gameBoard)
                
                // Does that cell contain a friendly counter?
                if rightRightCell.currentState == currentCell.currentState {
                    return (true, NSIndexPath(forRow: currentIndex.row + 1, inSection: currentIndex.section))
                }
            }
        }
        
        // All checks have been made, return 
        return (false, nil)
    }
    
    func gameBoard(gameBoard: HSGameBoardViewController, checkForWinningConditionsWith playerOneInfo: PlayerInfo, playerTwoInfo: PlayerInfo) -> Bool! {
        
        // Return true if either player only have one counter remaining
        return playerOneInfo.countersRemaining == 1 || playerTwoInfo.countersRemaining == 1
    }
}