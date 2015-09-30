//
//  HSGameViewController.swift
//  Hasami Shogi
//
//  Created by Oliver Poole on 24/09/2015.
//  Copyright © 2015 OliverPoole. All rights reserved.
//

import UIKit

/// The view controller responsible for playing the game
class HSGameViewController: UIViewController {
    
    var playerHasMadeFirstMove : Bool!
    var pieceSelected : Bool!
    
    var pieceSelectedPosition : NSIndexPath!
    
    var gamePiecePositions : [[Int]]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the game board
        
    }
        
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "HSMenuNavigationControllerSegue" {
            let navController = segue.destinationViewController
            navController.modalPresentationStyle = .OverCurrentContext
        }
    }
}



// MARK: - UICollectionViewDataSource
extension HSGameViewController : UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return HSGameConstants.numberOfSections
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return HSGameConstants.numberOfRows
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCellWithReuseIdentifier("HSGameCollectionViewCell", forIndexPath: indexPath)
    }
}

// MARK: - UICollectionViewDelegate
extension HSGameViewController : UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        
        cell?.backgroundColor = UIColor.redColor()
    }
    
}