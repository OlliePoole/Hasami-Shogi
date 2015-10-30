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

    /**
     - returns: The red color associated with player one
     */
    static func redCounterColor() -> UIColor {
        return UIColor(red: 174/255.0, green: 67/255.0, blue: 49/255.0, alpha: 1.0)
    }
    
    /**
     - returns: The blue color associated with player two
     */
    static func blueCounterColor() -> UIColor {
        return UIColor(red: 46/255.0, green: 124/255.0, blue: 172/255.0, alpha: 1.0)
    }
}
