//
//  HSGameBoardCollectionViewCell.swift
//  Hasami Shogi
//
//  Created by Oliver Poole on 07/10/2015.
//  Copyright © 2015 OliverPoole. All rights reserved.
//

import UIKit

enum CellState {
    case BlueCounter
    case RedCounter
    case Empty
}

/// Class for the custom collection view cell
class HSGameBoardCollectionViewCell: UICollectionViewCell {
    
    var currentState : CellState! {
        didSet {
            
            switch currentState! {
            case .BlueCounter:
                counterImageView.image = UIImage(named: "Blue Counter")
                
            case .RedCounter:
                counterImageView.image = UIImage(named: "Red Counter")
                
            case .Empty:
                counterImageView.image = nil
            }
        }
    }
    
    var owner : Player? {
        get {
            switch currentState! {
            case .RedCounter:
                return Player.PlayerOne
                
            case .BlueCounter:
                return Player.PlayerTwo
                
            case .Empty:
                return nil
            }
        }
    }
    
    @IBOutlet weak var outlineImageView : UIImageView!
    @IBOutlet weak var counterImageView : UIImageView!
    @IBOutlet weak var errorIndicatorImageView : UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Initalise the cell as empty
        currentState = .Empty
    }
}