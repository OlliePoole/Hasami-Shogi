//
//  HSNewGameViewController.swift
//  Hasami Shogi
//
//  Created by Oliver Poole on 23/09/2015.
//  Copyright © 2015 OliverPoole. All rights reserved.
//

import UIKit

class HSNewGameViewController: UIViewController {

    @IBAction func popViewControllerButtonPressed(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
}

extension HSNewGameViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("HSNewGameUserTableViewCell", forIndexPath: indexPath)
        
        cell.textLabel?.text = "Register New User"
        
        return cell
    }
    
}

extension HSNewGameViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
}