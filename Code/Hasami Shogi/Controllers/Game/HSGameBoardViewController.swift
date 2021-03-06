//
//  HSGameBoardViewController.swift
//  Hasami Shogi
//
//  Created by Oliver Poole on 07/10/2015.
//  Copyright © 2015 OliverPoole. All rights reserved.
//

import UIKit

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
    
    var delegate : HSGameLogicDelegate!
    
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
        currentSelectedIndexPath = nil
        currentPlayer = .PlayerOne
        
        if let _ = collectionView {
            collectionView.reloadData()
        }
        
        resetScores()
        updateScoreLabels()
        
    }
    
    /**
     Indicates that the game board should start a new game with two players
     
     - parameter playerOne: player one
     - parameter playerTwo: player two
     */
    func shouldStartNewGameWithPlayerOne(playerOne : User, andPlayerTwo playerTwo : User) {
        
        playerOneInfo = PlayerInfo(user: playerOne, countersRemaining: HSGameConstants.numberOfPiecesPerPlayer)
        playerTwoInfo = PlayerInfo(user: playerTwo, countersRemaining: HSGameConstants.numberOfPiecesPerPlayer)
        
        shouldRestartGame()
    }
    
    
    /**
     Resets the scores of the two current players
     */
    func resetScores() {
        playerOneInfo.countersRemaining = HSGameConstants.numberOfPiecesPerPlayer
        playerTwoInfo.countersRemaining = HSGameConstants.numberOfPiecesPerPlayer
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
        
        endCell.currentState = (currentPlayer == .PlayerOne) ? .RedCounter : .BlueCounter
        
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
        
        updateScoreLabels()
    }

    
    /**
    Indicates that the game has been won
    
    - parameter winningPlayer: The winning player
    */
    func indicateGameFinishedWith(winningPlayer : Player) {
        
        let winningUsername = (winningPlayer == .PlayerOne) ? playerOneInfo.user.username : playerTwoInfo.user.username
        
        let alert = UIAlertController(title: "Game Won!", message: "Congratulations \(winningUsername!)", preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: "New Game", style: .Default, handler: {
            (alertAction: UIAlertAction) -> Void in
            self.shouldRestartGame()
            
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
        HSGameDataManager.saveCoreDataContext()
    }
    
    
    /**
     Updates the score labels when a piece is taken
     */
    func updateScoreLabels() {
        let parent = parentViewController as! HSGameViewController
        
        parent.playerOneCountersRemainingLabel.text = "\(playerOneInfo.countersRemaining) counters"
        parent.playerOneCountersRemainingLabel.textColor = HSThemeManager.redCounterColor()
        
        parent.playerTwoCountersRemainingLabel.text = "\(playerTwoInfo.countersRemaining) counters"
        parent.playerTwoCountersRemainingLabel.textColor = HSThemeManager.blueCounterColor()
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
                // Set as made first move
                hasMadeFirstMove = true
                
                moveCounterFromLocation(currentSelectedIndexPath, to: indexPath)
                
                // Check for death
                let deathCheck = delegate?.gameBoard(self, checkForDeathAt: indexPath, currentPlayer: currentPlayer)
                
                if deathCheck?.count != 0 {
                    
                    // Remove the dead counters
                    for deathIndex in deathCheck! {
                        indicateDeathAt(deathIndex)
                    }
                    
                    // Now we know a counter has been captured, check if the game is finished
                    let gameFinished = delegate?.gameBoard(self, checkForWinningConditionsWith: playerOneInfo, playerTwoInfo: playerTwoInfo)
                    
                    if gameFinished! {
                        indicateGameFinishedWith(currentPlayer)
                    }
                }
                
                // Check if move has met the 5 in-a-row win conditions
                // Calculate the home sections of the current player to exclude those from the check
                var homeSections : [Int]
                
                if HSGameConstants.gameType == .HasamiShogi {
                    homeSections = [(currentPlayer == .PlayerOne) ? 0 : HSGameConstants.numberOfSections - 1]
                }
                else {
                    homeSections = [(currentPlayer == .PlayerOne) ? 0 : HSGameConstants.numberOfSections - 1,
                        (currentPlayer == .PlayerOne) ? 1 : HSGameConstants.numberOfSections - 2]
                }
                
                let gameFinished = delegate?.gameBoard(self, checkForFiveInARowWinningConditionsWithLastMove: indexPath, andPlayerHomeSections: homeSections, currentPlayer: currentPlayer)
                
                if gameFinished! {
                    indicateGameFinishedWith(currentPlayer)
                }
                
                // update the player
                currentPlayer = (currentPlayer == .PlayerOne) ? .PlayerTwo : .PlayerOne
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

