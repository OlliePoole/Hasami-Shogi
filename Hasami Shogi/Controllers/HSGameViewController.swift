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
    
    var gameType : GameType!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - UICollectionViewDataSource
extension HSGameViewController : UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 81
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