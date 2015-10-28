//
//  HSGameBoardViewController.swift
//  Hasami Shogi
//
//  Created by Oliver Poole on 07/10/2015.
//  Copyright © 2015 OliverPoole. All rights reserved.
//

import UIKit

protocol HSGameBoardViewControllerDelegate {
    func gameBoard(gameBoard : HSGameBoardViewController, canMovePieceFrom startIndex: NSIndexPath, to endIndex: NSIndexPath) -> Bool!
    func gameBoard(gameBoard : HSGameBoardViewController, checkForDeathAt currentIndex: NSIndexPath) -> [NSIndexPath]?
    func gameBoard(gameBoard : HSGameBoardViewController, checkIfCellAtIndex startIndex: NSIndexPath, hasTheSameOwnerAsCellAt endIndex: NSIndexPath) -> Bool!
    func gameBoard(gameBoard : HSGameBoardViewController, checkForWinningConditionsWith playerOneInfo: PlayerInfo, playerTwoInfo: PlayerInfo, lastMove indexPath: NSIndexPath) -> Bool!
    func showNewGameDialogWithBoard(gameBoard : HSGameBoardViewController)
}

enum Player {
    case PlayerOne // Red Counters
    case PlayerTwo // Blue Counters
}

struct PlayerInfo {
    var user : User // The user object
    var countersRemaining : Int // The number of counters that user has
}

/// Responsible for displaying and updating the game board
class HSGameBoardViewController: UIViewController {
    
    var delegate : HSGameBoardViewControllerDelegate!
    
    var hasMadeFirstMove : Bool = false
    
    var currentSelectedIndexPath : NSIndexPath!
    
    var currentPlayer : Player = .PlayerOne {
        didSet {
            playerOneIndicatorImageView.hidden = true
            playerTwoIndicatorImageView.hidden = true
            
            if currentPlayer == .PlayerOne {
                playerOneIndicatorImageView.hidden = false
            }
            else {
                playerTwoIndicatorImageView.hidden = false
            }
        }
    }
    
    var playerOneInfo : PlayerInfo!
    var playerTwoInfo : PlayerInfo!
    
    @IBOutlet weak var collectionView : UICollectionView!
    @IBOutlet weak var playerOneIndicatorImageView : UIImageView!
    @IBOutlet weak var playerTwoIndicatorImageView : UIImageView!
    
    /**
     Restarts the game
    */
    func shouldRestartGame() {
        hasMadeFirstMove = false
        currentPlayer = .PlayerOne
        
        collectionView.reloadData()
    }
    
    
    func shouldStartNewGameWithPlayerOne(playerOne : User, andPlayerTwo playerTwo : User) {
        
        playerOneInfo = PlayerInfo(user: playerOne, countersRemaining: HSGameConstants.numberOfPiecesPerPlayer)
        playerTwoInfo = PlayerInfo(user: playerTwo, countersRemaining: HSGameConstants.numberOfPiecesPerPlayer)
        
        shouldRestartGame()
    }
    
    /**
    Moves a counter from one location to another
    
    - precondition: Check for move validity
    
    - parameter startLocation: The starting location of the counter
    - parameter endLocation:   The ending location of the counter
    */
    func moveCounterFromLocation(startLocation: NSIndexPath, to endLocation: NSIndexPath) {
        let startCell = collectionView.cellForItemAtIndexPath(startLocation) as! HSGameBoardCollectionViewCell
        let endCell = collectionView.cellForItemAtIndexPath(endLocation) as! HSGameBoardCollectionViewCell
        
        startCell.currentState = .Empty
        startCell.outlineImageView.image = nil
        
        endCell.currentState = currentPlayer == .PlayerOne ? .RedCounter : .BlueCounter
        
        currentSelectedIndexPath = nil
    }
    
    /**
    Used when an incorrect action has been made
    
    The method will animate a coloured square onto the cell in question
    
    - parameter indexPath: the indexpath of the error
    */
    func indicateErrorAt(indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! HSGameBoardCollectionViewCell
        
        UIView.animateWithDuration(0.25, animations: {
            () -> Void in
            cell.errorIndicatorImageView.alpha = 1.0
            })
            { (finished) -> Void in
                UIView.animateWithDuration(0.25, animations: {
                    () -> Void in
                    cell.errorIndicatorImageView.alpha = 0.0
                })
        }
    }
    
    /**
    Used to indicate a cell has been selected to the user
    
    - parameter indexPath: The index path of the cell to select
    */
    func indicateCellSelectionAt(indexPath: NSIndexPath) {
        
        if let currentSelectedIndexPath = currentSelectedIndexPath {
            // Remove the previous highlighted cell
            let oldCell = collectionView.cellForItemAtIndexPath(currentSelectedIndexPath) as! HSGameBoardCollectionViewCell
            oldCell.outlineImageView.image = nil
        }
        
        currentSelectedIndexPath = indexPath
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! HSGameBoardCollectionViewCell
        
        // Indicate that the current cell is selected
        cell.outlineImageView.image = currentPlayer == .PlayerOne ? UIImage(named: "Red Outline") : UIImage(named: "Blue Outline")
    }
    
    
    /**
    Used to indicate that a counter has been captured
    
    - parameter indexPath: The index of the cell to remove
    */
    func indicateDeathAt(indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! HSGameBoardCollectionViewCell
        
        // Remove the counter from the cell
        cell.currentState = .Empty
        
        // Update the number of counters that player has
        if currentPlayer == .PlayerOne {
            playerTwoInfo.countersRemaining--
        }
        else {
            playerOneInfo.countersRemaining--
        }
    }
    
    
    /**
    Indicates that the game has been won
    
    - parameter winningPlayer: The winning player
    */
    func indicateGameFinishedWith(winningPlayer : Player) {
        
        let winningUser = (winningPlayer == .PlayerOne) ? playerOneInfo.user : playerTwoInfo.user
        
        let alert = UIAlertController(title: "Game Won!", message: "Congratulations \(winningUser.username)", preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        
        alert.addAction(UIAlertAction(title: "New Game", style: .Default, handler: {
            (alertAction: UIAlertAction) -> Void in
            self.delegate?.showNewGameDialogWithBoard(self)
        }))
        
        parentViewController!.presentViewController(alert, animated: true, completion: nil)
        
        // Update the user
        if winningPlayer == .PlayerOne {
            playerOneInfo.user.points = Int(playerOneInfo.user.points!) + 2
        }
        else {
            playerTwoInfo.user.points = Int(playerTwoInfo.user.points!) + 2
        }
        
        // Save the points update
        HSDatabaseManager.saveCoreDataContext()
    }
}

// MARK: - UICollectionViewDelegate
extension HSGameBoardViewController : UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        // If there is an existing indexPath, the new selection is a move request
        if let _ = currentSelectedIndexPath {
            
            // Is the user selecting another counter to change his inital selection?
            let cellHasSameOwner = delegate?.gameBoard(self, checkIfCellAtIndex: currentSelectedIndexPath, hasTheSameOwnerAsCellAt: indexPath)
            
            if cellHasSameOwner! {
                indicateCellSelectionAt(indexPath)
                return
            }
            
            let canMakeMove = delegate?.gameBoard(self, canMovePieceFrom: currentSelectedIndexPath, to: indexPath)
            
            if canMakeMove! {
                moveCounterFromLocation(currentSelectedIndexPath, to: indexPath)
                
                // update the player
                currentPlayer = currentPlayer == .PlayerOne ? .PlayerTwo : .PlayerOne
                
                // Check for death
                let deathCheck = delegate?.gameBoard(self, checkForDeathAt: indexPath)
                
                if deathCheck?.count == 0 {
                    return
                }
                
                // Remove the dead counters
                for deathIndex in deathCheck! {
                    indicateDeathAt(deathIndex)
                }
                
                // Now we know a counter has been captured, check if the game is finished
                let gameFinished = delegate?.gameBoard(self, checkForWinningConditionsWith: playerOneInfo, playerTwoInfo: playerTwoInfo, lastMove: indexPath)
                
                if gameFinished! {
                    indicateGameFinishedWith(currentPlayer)
                }
            }
            else {
                // Highlight end cell with error
                indicateErrorAt(indexPath)
            }
        }
        else { // currentSelection = nil
            
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as! HSGameBoardCollectionViewCell
            
            // Is there a counter where the user has selected?
            if cell.currentState == CellState.Empty {
                indicateErrorAt(indexPath)
                return
            }
            
            // Does the counter belong to the current user?
            if cell.owner != currentPlayer {
                indicateErrorAt(indexPath)
                return
            }
            
            indicateCellSelectionAt(indexPath)
        }
    }
}


// MARK: - UICollectionViewDataSource
extension HSGameBoardViewController : UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return HSGameConstants.numberOfSections
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return HSGameConstants.numberOfRows
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("HSGameBoardCollectionViewCell", forIndexPath: indexPath) as! HSGameBoardCollectionViewCell
        
        if HSGameConstants.gameType == .HasamiShogi {
            // 9 Counters per player
            if indexPath.section == 0 {
                cell.currentState = .RedCounter
            }
            else if indexPath.section == 8 {
                cell.currentState = .BlueCounter
            }
            else {
                cell.currentState = .Empty
            }
        }
        else {
            // 18 Counters per player
            if indexPath.section == 0 || indexPath.section == 1 {
                cell.currentState = .RedCounter
            }
            else if indexPath.section == 7 || indexPath.section == 8 {
                cell.currentState = .BlueCounter
            }
            else {
                cell.currentState = .Empty
            }
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let screenWidth = view.frame.width
        let cellWidth = screenWidth / 9
        
        return CGSizeMake(cellWidth - 1, cellWidth - 1)
    }
    
    
}
