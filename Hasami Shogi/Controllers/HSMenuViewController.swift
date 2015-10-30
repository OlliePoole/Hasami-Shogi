//
//  HSMenuViewController.swift
//  Hasami Shogi
//
//  Created by Oliver Poole on 23/09/2015.
//  Copyright © 2015 OliverPoole. All rights reserved.
//

import UIKit

/// Used as a sidebar to display the options of the game
class HSMenuViewController: UIViewController {
    
    let menuOptions = ["Game", "Leaderboard", "Settings"]
    
    var gameViewController : HSGameViewController!
    var leaderboardViewController : HSLeaderboardTableViewController!
    var settingsViewController : HSSettingsTableViewController!
    
    /// Reference to the current container view controller
    var menuContainer : UIViewController!
}

extension HSMenuViewController : UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("HSMenuTableViewCell", forIndexPath: indexPath)
        
        cell.textLabel?.text = menuOptions[indexPath.section]
        cell.imageView?.image = UIImage(named: menuOptions[indexPath.section] + " Icon")
        
        return cell
    }
}

//TODO: FIX THIS
extension HSMenuViewController : UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch indexPath.section {
            
        case 0: // Game
            if menuContainer is HSGameViewController {
                HSSideBarDelegateStore.delegate?.toggleSideBar(menuContainer)
                break
            }
            else {
                if gameViewController == nil {
                    gameViewController = self.storyboard?.instantiateViewControllerWithIdentifier("HSGameViewController") as! HSGameViewController
                }
                HSSideBarDelegateStore.delegate?.toggleSideBar(gameViewController)
            }
            
            
        case 1: //Leaderboard
            if menuContainer is HSLeaderboardTableViewController {
                HSSideBarDelegateStore.delegate?.toggleSideBar(menuContainer)
                break
            }
            else {
                if leaderboardViewController == nil {
                    leaderboardViewController = self.storyboard?.instantiateViewControllerWithIdentifier("HSLeaderboardTableViewController") as! HSLeaderboardTableViewController
                }
                HSSideBarDelegateStore.delegate?.toggleSideBar(leaderboardViewController)
            }
            
            
        default: // Settings
            if menuContainer is HSSettingsTableViewController {
                HSSideBarDelegateStore.delegate?.toggleSideBar(menuContainer)
                break
            }
            else {
                if settingsViewController == nil {
                    settingsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("HSSettingsTableViewController") as! HSSettingsTableViewController
                }
                HSSideBarDelegateStore.delegate?.toggleSideBar(settingsViewController)
            }
        }
    }
}