//
//  HSNewGameViewController.swift
//  Hasami Shogi
//
//  Created by Oliver Poole on 23/09/2015.
//  Copyright © 2015 OliverPoole. All rights reserved.
//

import UIKit

class HSNewGameViewController: UIViewController {
    
    var playerOneChild : HSPlayerSelectionContainerViewController!
    var playerTwoChild : HSPlayerSelectionContainerViewController!
    
    var datasource : Array<User>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.datasource = HSDatabaseManager.fetchAllUsers()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PlayerOnePlayerSelectionContainerViewController" {
            self.playerOneChild = segue.destinationViewController as! HSPlayerSelectionContainerViewController
            self.playerOneChild.delegate = self
        }
        else if segue.identifier == "PlayerTwoPlayerSelectionContainerViewController" {
            self.playerTwoChild = segue.destinationViewController as! HSPlayerSelectionContainerViewController
            self.playerTwoChild.delegate = self
        }
    }
    
    //MARK: - Handle Button Interactions
    
    @IBAction func popViewControllerButtonPressed(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func startGameButtonPressed(sender: AnyObject) {
        // Check two players have been selected
        // Start the game
    }
}

// MARK: - HSPlayerSelectionContainerViewControllerDelegate
extension HSNewGameViewController : HSPlayerSelectionContainerViewControllerDelegate {
    
    func registerNewPlayer(sender: HSPlayerSelectionContainerViewController) {
        // push register viewController
        
        let registerViewController = self.storyboard?.instantiateViewControllerWithIdentifier("HSRegisterUserViewController")
        self.navigationController?.pushViewController(registerViewController!, animated: true)
    }
}

extension HSNewGameViewController : HSRegisterUserViewControllerDelegate {
    
    func didFinishRegisteringUser(user: User) {
        // Update child with new user
        
    }
}


