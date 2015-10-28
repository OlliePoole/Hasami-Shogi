//
//  HSLeaderboardViewController.swift
//  Hasami Shogi
//
//  Created by Oliver Poole on 23/09/2015.
//  Copyright © 2015 OliverPoole. All rights reserved.
//

import UIKit

class HSLeaderboardTableViewController: UITableViewController {

    var datasource : Array<User>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let users = HSDatabaseManager.fetchAllUsers()
        
        if let users = users where users.count > 0 {
            datasource = users
        }
    }
    
    @IBAction func menuButtonPressed(sender: AnyObject) {
        HSSideBarDelegateStore.delegate?.toggleSideBar(self)
    }
}

// MARK: - UITableViewDatasource
extension HSLeaderboardTableViewController {

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let user = datasource[indexPath.row]
        var cell = tableView.dequeueReusableCellWithIdentifier("HSLeaderboardTableViewCell", forIndexPath: indexPath) as! HSLeaderboardTableViewCell
        
        cell = cell.buildCellForUser(user)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 140
    }
}

//MARK: - UITableViewDelegate
extension HSLeaderboardTableViewController {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let userProfile = storyboard?.instantiateViewControllerWithIdentifier("HSUserProfileViewController") as! HSUserProfileViewController
        
        userProfile.user = datasource[indexPath.row]
        
        navigationController?.pushViewController(userProfile, animated: true)
    }
    
}