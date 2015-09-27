
//
//  HSPlayerSelectionContainerViewController.swift
//  Hasami Shogi
//
//  Created by Oliver Poole on 27/09/2015.
//  Copyright © 2015 OliverPoole. All rights reserved.
//

import UIKit

protocol HSPlayerSelectionContainerViewControllerDelegate {
    func registerNewPlayer(sender: HSPlayerSelectionContainerViewController)
}

/**
Used to store the Guest and Register players
*/
enum MiscPlayers : Int {
    case Guest
    case Register
}

class HSPlayerSelectionContainerViewController: UIViewController {

    @IBOutlet weak var tableView : UITableView!
    @IBOutlet weak var playerNameLabel : UILabel!
    
    var delegate : HSPlayerSelectionContainerViewControllerDelegate!
    
    var selectedPlayer : User!
    var playerIsGuest : Bool!
    
    /// A single datasource where both children can access
    var datasource : Array<User> {
        get {
            let parent = parentViewController as! HSNewGameViewController
            return parent.datasource
        }
        set (newValue) {
            let parent = parentViewController as! HSNewGameViewController
            parent.datasource = newValue
        }
    }
    
    /**
    Called by the parent when the registering process is complete
    
    - parameter player: The new player
    */
    func didRegiserNewPlayer(player: User) {
        self.selectedPlayer = player
        self.playerNameLabel.text = player.username
        
        if self.playerNameLabel.hidden {
            self.playerNameLabel.hidden = false
        }
    }
    
    // MARK: Button Interactions
    @IBAction func selectPlayerButtonPressed(sender: UIButton) {
        
        // Reset the guest var
        self.playerIsGuest = false
        
        // If current user is selected, re-add to datasource
        if let selectedPlayer = self.selectedPlayer {
            self.datasource.append(selectedPlayer)
            self.selectedPlayer = nil
        }
        
        // Show the tableview
        self.tableView.hidden = false
        
        // Reload the datasource
        self.tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension HSPlayerSelectionContainerViewController : UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // One section for displaying the current name, another for Guest and Register new
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.datasource.count
        }
        else {
            return 2
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCellWithIdentifier("HSPlayerSelectionTableViewCell", forIndexPath: indexPath)
        
        if indexPath.section == 0 {
            let player = self.datasource[indexPath.row]
            
            cell.textLabel?.text = player.username
            //cell.imageView?.image = user.profileImage
        }
        else {
            if MiscPlayers(rawValue: indexPath.row) == .Guest {
                cell.textLabel?.text = "Guest"
            }
            else {
                cell.textLabel?.text = "Register"
            }
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension HSPlayerSelectionContainerViewController : UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 0 {
            let player = self.datasource[indexPath.row]
            
            self.playerNameLabel.hidden = false

            self.selectedPlayer = player
            self.playerNameLabel.text = player.username
            
            // Remove the player from the list
            self.datasource.removeAtIndex(indexPath.row)
        }
        else {
            if MiscPlayers(rawValue: indexPath.row) == .Guest {
                
                self.playerNameLabel.hidden = false

                
                self.playerIsGuest = true
                self.playerNameLabel.text = "Guest"
            }
            else {
                // Ask parent to handle adding a new player
                self.delegate.registerNewPlayer(self)
            }
        }
        
        tableView.hidden = true
    }
}
