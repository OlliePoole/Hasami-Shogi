//
//  HSGameLogicDelegate.swift
//  Hasami Shogi
//
//  Created by Oliver Poole on 30/10/2015.
//  Copyright © 2015 OliverPoole. All rights reserved.
//

import Foundation

protocol HSGameLogicDelegate {
    
    /**
     Asks the delegate if, based on the current positions of the counters on the board, a counter can move from one square to another
     
     - parameter gameBoard:  The board where the counter is moving
     - parameter startIndex: The current position of the counter
     - parameter endIndex:   The proposed destination of the counter
     
     - returns: True, if the move is legal
     */
    func gameBoard(gameBoard : HSGameBoardViewController, canMovePieceFrom startIndex: NSIndexPath, to endIndex: NSIndexPath) -> Bool!
    
    
    /**
     Asks the delegate if, moving a counter to a certain index 'currentIndex' has resulted in the death of any enemy counters
     surrounding it
     
     - parameter gameBoard:    The board
     - parameter currentIndex: The current index of the counter after it's move operation
     - parameter player:       The player who just completed the move
     
     - returns: An array of index paths, where each index path is the location of a counter that has died
     */
    func gameBoard(gameBoard : HSGameBoardViewController, checkForDeathAt currentIndex: NSIndexPath, currentPlayer player: Player) -> [NSIndexPath]?
    
    
    /**
     Asks the delegate if, based on the current positions of the counters on the board, two cells have the same owner
     
     - parameter gameBoard:  The game board
     - parameter startIndex: The location of the first cell
     - parameter endIndex:   The location of the second cell
     
     - returns: True, if the cells have the same owner
     */
    func gameBoard(gameBoard : HSGameBoardViewController, checkIfCellAtIndex startIndex: NSIndexPath, hasTheSameOwnerAsCellAt endIndex: NSIndexPath) -> Bool!
    
    
    /**
     Asks the delegate if, based on the current positions of the counters on the board the last move which resulted
     in the death of another counter, has met the 'counters remaining' win conditions of the game
     
     - parameter gameBoard:     The game board
     - parameter playerOneInfo: The information structure on player one
     - parameter playerTwoInfo: The information sructure on player two
     
     - returns: True, if the win conditions have been met
     */
    func gameBoard(gameBoard : HSGameBoardViewController, checkForWinningConditionsWith playerOneInfo: PlayerInfo, playerTwoInfo: PlayerInfo) -> Bool!
    
    
    /**
     Asks the delegate if, based on the current positions of the counters on the board and following a completed move
     request, the new position meets the requirements for the 5 in-a-row winning conditions
     
     - parameter gameBoard: The game board
     - parameter lastMove:  The end location of the last move that was made
     - parameter sections:  The section(s) of the starting location(s) of the current player
     - parameter player:    The player who just completed the move
     
     - returns: True, if the win conditions have been met
     */
    func gameBoard(gameBoard : HSGameBoardViewController, checkForFiveInARowWinningConditionsWithLastMove lastMove: NSIndexPath, andPlayerHomeSections sections: [Int], currentPlayer player: Player) -> Bool!
    
    
    /**
     Asks the delegate to show the new game dialog and signal the start of a new game
     
     - parameter gameBoard: The game board
     */
    func showNewGameDialogWithBoard(gameBoard : HSGameBoardViewController)
}
