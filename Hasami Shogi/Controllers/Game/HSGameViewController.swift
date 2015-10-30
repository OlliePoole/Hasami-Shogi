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
    
    @IBOutlet weak var playerOneNameLabel: UILabel!
    @IBOutlet weak var playerTwoNameLabel: UILabel!
    
    @IBOutlet weak var playerOneCountersRemainingLabel: UILabel!
    @IBOutlet weak var playerTwoCountersRemainingLabel: UILabel!
    
    /// The game board child view controller
    var gameBoardViewController : HSGameBoardViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gameBoardViewController = childViewControllers.first as! HSGameBoardViewController
        
        gameBoardViewController.delegate = self
        
        let players : (playerOne: User, playerTwo: User)
        
        if (HSGameDataManager.fetchAllUsers()?.count == 0) {
            players = HSGameDataManager.createDummyUsersForFirstLaunch()
        }
        else {
            // Load the previous two players and start a match with them
            players = HSGameDataManager.loadDefaultPlayers()
        }
        
        // Update player labels with player names
        playerOneNameLabel.text = players.playerOne.username
        playerOneNameLabel.textColor = HSThemeManager.redCounterColor()
        
        playerTwoNameLabel.text = players.playerTwo.username
        playerTwoNameLabel.textColor = HSThemeManager.blueCounterColor()
        
        // Start a new game with the players
        gameBoardViewController.shouldStartNewGameWithPlayerOne(players.playerOne, andPlayerTwo: players.playerTwo)
    }
    
    @IBAction func menuButtonPressed(sender: AnyObject) {
        HSSideBarDelegateStore.delegate?.toggleSideBar(self)
    }
    
    @IBAction func restartGameButtonPressed(sender: AnyObject) {
        let gameBoard = childViewControllers.first as! HSGameBoardViewController
        
        gameBoard.shouldRestartGame()
    }
    
    @IBAction func newGameButtonPressed(sender: AnyObject) {
        let newGameViewController = storyboard?.instantiateViewControllerWithIdentifier("HSNewGameViewController") as! HSNewGameViewController
        newGameViewController.delegate = self
        
        // embed new game controller in nav controller
        let navController = UINavigationController(rootViewController: newGameViewController)
    
        presentViewController(navController, animated: true, completion: nil)
    }
}

// MARK: - HSNewGameViewControllerDelegate
extension HSGameViewController : HSNewGameViewControllerDelegate {
    func newGame(newGameViewController: HSNewGameViewController, shouldStartNewGameWith playerOne: User, and playerTwo: User) {
        // Dismiss the view controller
        dismissViewControllerAnimated(true) { () -> Void in
            // Start a new game
            self.gameBoardViewController.shouldStartNewGameWithPlayerOne(playerOne, andPlayerTwo: playerTwo)
        }
    }
}