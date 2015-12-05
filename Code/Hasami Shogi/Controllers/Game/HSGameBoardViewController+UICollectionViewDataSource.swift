//
//  HSGameBoardViewController+UICollectionViewDataSource.swift
//  Hasami Shogi
//
//  Created by Oliver Poole on 05/12/2015.
//  Copyright © 2015 OliverPoole. All rights reserved.
//

import Foundation
import UIKit

// MARK: - UICollectionViewDataSource
extension HSGameBoardViewController : UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return HSGameConstants.numberOfSections
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return HSGameConstants.numberOfRows
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("HSGameBoardCollectionViewCell", forIndexPath: indexPath) as! HSGameBoardCollectionViewCell
        
        if HSGameConstants.gameType == .HasamiShogi {
            // 9 Counters per player
            if indexPath.section == 0 {
                cell.currentState = .RedCounter
            }
            else if indexPath.section == 8 {
                cell.currentState = .BlueCounter
            }
            else {
                cell.currentState = .Empty
            }
        }
        else {
            // 18 Counters per player
            if indexPath.section == 0 || indexPath.section == 1 {
                cell.currentState = .RedCounter
            }
            else if indexPath.section == 7 || indexPath.section == 8 {
                cell.currentState = .BlueCounter
            }
            else {
                cell.currentState = .Empty
            }
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let screenWidth = view.frame.width
        let cellWidth = screenWidth / 9
        
        return CGSizeMake(cellWidth - 1, cellWidth - 1)
    }
}