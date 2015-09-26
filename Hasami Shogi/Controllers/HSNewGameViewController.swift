//
//  HSNewGameViewController.swift
//  Hasami Shogi
//
//  Created by Oliver Poole on 23/09/2015.
//  Copyright © 2015 OliverPoole. All rights reserved.
//

import UIKit

enum SelectedButton : Int {
    case PlayerOne = 1
    case PlayerTwo
}

/**
Used to store the Guest and Register players
*/
enum MiscPlayers : Int {
    case Guest
    case Register
}

class HSNewGameViewController: UIViewController {
    
    @IBOutlet weak var playerOneTableView : UITableView!
    @IBOutlet weak var playerTwoTableView : UITableView!
    
    @IBOutlet weak var playerOneLabel : UILabel!
    @IBOutlet weak var playerTwoLabel : UILabel!
    
    @IBOutlet weak var playerOneButton : UIButton!
    @IBOutlet weak var playerTwoButton : UIButton!
    
    var playerOne : User!
    var playerTwo : User!
    
    var playerOneIsGuest : Bool!
    var playerTwoIsGuest : Bool!
    
    var datasource : Array<User>!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.datasource = HSDatabaseManager.fetchAllUsers()
    }
    
    //MARK: - Handle Button Interactions
    
    @IBAction func popViewControllerButtonPressed(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func selectUserButtonPressed(sender: AnyObject) {
        
        // Get the selected button
        let selectedButton = SelectedButton(rawValue: (sender as! UIButton).tag)
        
        
        // Hide/Show tableviews and reload data
        switch (selectedButton!) {
            case .PlayerOne:
                
                // If current user is selected, re-add to datasource
                if let playerOne = self.playerOne {
                    self.datasource.append(playerOne)
                    self.playerOne = nil
                }
            
                // Hide/Show tableviews
                self.playerOneTableView.hidden = false
                self.playerTwoTableView.hidden = true
                
                // Disable other button
                self.playerTwoButton.enabled = false
                
                self.playerOneTableView.reloadData()
            
                break
            
            case .PlayerTwo:
            
                if let playerTwo = self.playerTwo {
                    self.datasource.append(playerTwo)
                    self.playerTwo = nil
                }
                
                // Hide/Show tableviews
                self.playerTwoTableView.hidden = false
                self.playerOneTableView.hidden = true
            
                //Disable other button
                self.playerOneButton.enabled = false
                
                self.playerTwoTableView.reloadData()
            
                break
        }
    }
    
    @IBAction func startGameButtonPressed(sender: AnyObject) {
        // Check two players have been selected
        // Start the game
    }
}

// MARK: - UITableViewDataSource
extension HSNewGameViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // One section for displaying the current name, another for Guest and Register new
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.datasource!.count
        }
        else {
            return 2
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("HSNewGameUserTableViewCell", forIndexPath: indexPath)
        
        if indexPath.section == 0 {
        
            let user = self.datasource[indexPath.row]
            cell.textLabel?.text = user.username
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
extension HSNewGameViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 0 {
            let selectedUser = self.datasource[indexPath.row]
            
            switch (SelectedButton(rawValue: tableView.tag)!) {
                case SelectedButton.PlayerOne:
                
                    self.playerOneLabel.text = selectedUser.username
                    self.playerOne = selectedUser
                
                    break;
                
                case SelectedButton.PlayerTwo:
                
                    self.playerTwoLabel.text = selectedUser.username
                    self.playerTwo = selectedUser
                    break
            }
            
            // remove the player from the list
            self.datasource.removeAtIndex(indexPath.row)
            
        }
        else { // The user has tapped on either Guest or Register
            if MiscPlayers(rawValue: indexPath.row) == .Guest {
                
                switch (SelectedButton(rawValue: tableView.tag)!) {
                    case SelectedButton.PlayerOne:
                    
                        self.playerOneIsGuest = true
                        self.playerOneLabel.text = "Guest"
                        
                        break
                    
                    case SelectedButton.PlayerTwo:
                    
                        self.playerTwoIsGuest = true
                        self.playerTwoLabel.text = "Guest"
                        
                        break
                }
            }
            else {
                // push new user view controller
                
            }
        }
        
        // hide the tableview
        tableView.hidden = true
        
        // Enabled the buttons again
        self.playerOneButton.enabled = true
        self.playerTwoButton.enabled = true
    }
    
}