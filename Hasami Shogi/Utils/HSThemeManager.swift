//
//  HSThemeManager.swift
//  Hasami Shogi
//
//  Created by Oliver Poole on 10/10/2015.
//  Copyright © 2015 OliverPoole. All rights reserved.
//

import UIKit

/// Responsible for storing information about colors and fonts
class HSThemeManager: NSObject {
    
    /**
    - parameter size: The size of the font
    
    - returns: The application's 'Light' font
    */
    static func lightFontWithSize(size: CGFloat) -> UIFont {
        return UIFont(name: "SanFranciscoText-Light", size: size)!
    }
    
    /**
    - parameter size: The size of the font
    
    - returns: The application's 'Bold' font
    */
    static func boldFontWithSize(size: CGFloat) -> UIFont {
        return UIFont(name: "SanFranciscoText-Bold", size: size)!
    }

}
