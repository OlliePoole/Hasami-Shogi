//
//  HSUserProfileViewController.swift
//  Hasami Shogi
//
//  Created by Oliver Poole on 11/10/2015.
//  Copyright © 2015 OliverPoole. All rights reserved.
//

import UIKit

class HSUserProfileViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var bioTextView: UITextView!
    
    var user : User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = user.username;

        profileImageView.image = user.profileImage
        usernameLabel.text = user.username
        pointsLabel.text = "\(user.points as! Int) points"
        bioTextView.text = user.bio
    }
}
