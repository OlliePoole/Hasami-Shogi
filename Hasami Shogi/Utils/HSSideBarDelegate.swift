//
//  HSSideBarDelegate.swift
//  Hasami Shogi
//
//  Created by Oliver Poole on 06/10/2015.
//  Copyright © 2015 OliverPoole. All rights reserved.
//

import Foundation
import UIKit

protocol HSSideBarDelegate {
    
    /**
    Instruct the delegate to toggle the sidebar in or out
    
    - parameter sender: The sender of the request
    */
    func toggleSideBar(sender: UIViewController)
}

/// Stores a static variable to the delegate property
class HSSideBarDelegateStore {
    static var delegate : HSSideBarDelegate!
}