//
//  HSNewGameViewController.swift
//  Hasami Shogi
//
//  Created by Oliver Poole on 23/09/2015.
//  Copyright © 2015 OliverPoole. All rights reserved.
//

import UIKit

/**
 *  Notify the presenting view controller that the user has asked to start a new game
 */
protocol HSNewGameViewControllerDelegate {
    func newGame(newGameViewController : HSNewGameViewController, shouldStartNewGameWith playerOne: User, and playerTwo: User)
}

class HSNewGameViewController: UIViewController {
    
    private enum CellSelectionState : Int {
        case PlayerOne
        case PlayerTwo
        case NotSelected
    }
    
    @IBOutlet weak var startGameButton : UIButton!
    @IBOutlet weak var tableView : UITableView!
    
    var datasource : Array<Dictionary<String, AnyObject>>!
    
    var playerOne : User!
    var playerTwo : User!
    
    var delegate : HSNewGameViewControllerDelegate!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fetch all the saved users
        let users = HSGameDataManager.fetchAllUsers()
        
        if users?.count == 0 { return }
        
        datasource = Array<Dictionary<String, AnyObject>>()
        
        for user in users! {
            var userDict = Dictionary<String, AnyObject>()
            
            userDict["User"] = user
            userDict["CellState"] = NSNumber(integer: CellSelectionState.NotSelected.rawValue)
            
            datasource.append(userDict)
        }
    }
    
    @IBAction func cancelNewGameButtonSelected(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func registerButtonPressed(sender: AnyObject) {
        let registerUserViewController = storyboard?.instantiateViewControllerWithIdentifier("HSRegisterUserTableViewController") as! HSRegisterUserTableViewController
        
        registerUserViewController.delegate = self
        
        navigationController?.pushViewController(registerUserViewController, animated: true)
    }
    
    @IBAction func startGameButtonPressed(sender: AnyObject) {
        // Save the players as the default for next time
        HSGameDataManager.saveCurrentTwoPlayersAsDefaultWithPlayerOne(playerOne, playerTwo: playerTwo)
        
        delegate?.newGame(self, shouldStartNewGameWith: playerOne, and: playerTwo)
    }
}

// MARK: - UITableViewDataSource
extension HSNewGameViewController : UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
        // The +1 is for a cell that enables the user to register a new user
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("HSNewGameTableViewCell", forIndexPath: indexPath) as! HSNewGameTableViewCell
        
        let userDict = datasource[indexPath.row]
        
        let user = userDict["User"] as! User
        let cellState = CellSelectionState(rawValue: userDict["CellState"] as! Int)
        
        cell = cell.buildCellForUser(user)
        
        // Hide or show the overlay based on if the datasource has the cell marked as selected
        if cellState == .NotSelected {
            cell.selectionOverlayView.hidden = true
        }
        else {
            cell.selectionOverlayLabel.text = (cellState == .PlayerOne) ? "Player One" : "Player Two"
            cell.selectionOverlayView.backgroundColor = (cellState == .PlayerOne) ? UIColor.redColor() : UIColor.blueColor()
            
            cell.selectionOverlayView.hidden = false
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 140
    }
}

// MARK: - UITableViewDelegate
extension HSNewGameViewController : UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var userDict = datasource[indexPath.row]
        
        // If playerOne has been selected, pick player two
        if playerOne == nil && playerTwo == nil {
            
            userDict["CellState"] = NSNumber(integer: CellSelectionState.PlayerOne.rawValue)
            playerOne = userDict["User"] as! User
        }
        else if playerOne != nil && playerTwo == nil {
            
            // Does the cell already belong to another user?
            if CellSelectionState(rawValue: userDict["CellState"] as! Int) == .PlayerOne {
                return
            }
            
            userDict["CellState"] = NSNumber(integer: CellSelectionState.PlayerTwo.rawValue)
            playerTwo = userDict["User"] as! User
        }
        else { // Both selected
            let cellSelection = CellSelectionState(rawValue: userDict["CellState"] as! Int)
            
            if cellSelection == .NotSelected {
                return
            }
            
            // Is the selection an existing selection (i.e. Player One / Player Two)
            if cellSelection == .PlayerOne {
                playerOne = nil
            }
            else {
                playerTwo = nil
            }
            userDict["CellState"] = NSNumber(integer: CellSelectionState.NotSelected.rawValue)
        }
        
        // Update the datasource
        datasource[indexPath.row] = userDict
        
        // Update the cell in the tableview
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
        
        // Check if two selections have been made
        startGameButton.hidden = !(playerOne != nil && playerTwo != nil)
    }
}

extension HSNewGameViewController : HSRegisterUserTableViewControllerDelegate {
    func registerTableViewController(registerTableViewController: HSRegisterUserTableViewController, didRegisterNewUser newUser: User) {
        
        // Add the new user to the datasource
        var userDict = Dictionary<String, AnyObject>()
        
        userDict["User"] = newUser
        userDict["CellState"] = NSNumber(integer: CellSelectionState.NotSelected.rawValue)
        
        datasource.append(userDict)
    
        // Reload data
        tableView.reloadData()
    }
}
