//
//  HSNewGameTableViewCell.swift
//  Hasami Shogi
//
//  Created by Oliver Poole on 10/10/2015.
//  Copyright © 2015 OliverPoole. All rights reserved.
//

import UIKit

class HSNewGameTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var bioTextView: UITextView!
    
    @IBOutlet weak var selectionOverlayView: UIView!
    @IBOutlet weak var selectionOverlayLabel: UILabel!
    
    /**
    Given an empty HSNewGameTableViewCell, the method customises it to the user object
    
    - parameter user: The user to display in the cell
    
    - returns: The customised cell
    */
    func buildCellForUser(user: User) -> HSNewGameTableViewCell! {
        
        usernameLabel?.text = user.username
        bioTextView?.text = user.bio
        profileImageView?.image = user.profileImage
        
        // Customise the image view
        profileImageView?.layer.cornerRadius = ((profileImageView?.frame.size.height)! / 2)
        profileImageView?.layer.masksToBounds = true
        profileImageView?.layer.borderWidth = 0
        
        selectionOverlayView.hidden = true

        return self
    }
}
