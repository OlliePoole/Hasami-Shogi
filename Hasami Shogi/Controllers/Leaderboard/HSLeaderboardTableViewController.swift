//
//  HSLeaderboardViewController.swift
//  Hasami Shogi
//
//  Created by Oliver Poole on 23/09/2015.
//  Copyright © 2015 OliverPoole. All rights reserved.
//

import UIKit

class HSLeaderboardTableViewController: UITableViewController {

    
    @IBAction func menuButtonPressed(sender: AnyObject) {
        HSSideBarDelegateStore.delegate?.toggleSideBar(self)
    }
    

}
