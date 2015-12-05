//
//  HSSettingsViewController.swift
//  Hasami Shogi
//
//  Created by Oliver Poole on 23/09/2015.
//  Copyright © 2015 OliverPoole. All rights reserved.
//

import UIKit

class HSSettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var gameTypeSegmentControl: UISegmentedControl!

    @IBOutlet weak var countersToWinStepper: UIStepper!
    @IBOutlet weak var counterToWinLabel: UILabel!
    
    @IBOutlet weak var horizontalToWinSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gameTypeSegmentControl.selectedSegmentIndex = HSGameConstants.gameType.rawValue
        
        countersToWinStepper.value = Double(HSGameConstants.numberOfPiecesToWin)
        updateStepperConstraints(HSGameConstants.gameType)
        counterToWinLabel.text = "\(Int(countersToWinStepper.value))"
        
        horizontalToWinSwitch.on = HSGameConstants.lineToWin
        horizontalToWinSwitch.enabled = HSGameConstants.gameType == .DiaHasamiShogi
    }
    
    @IBAction func menuButtonPressed(sender: AnyObject) {
        HSSideBarDelegateStore.delegate?.toggleSideBar(self)
    }
    
    private func updateStepperConstraints(gameType: GameType) {
        countersToWinStepper.maximumValue = (gameType == .HasamiShogi) ? 8.0 : 17.0
    }


    /**
    Called when the game type UISegmentControl has it's value
    updated
    
    - parameter sender: the UISegmentControl
    */
    @IBAction func gameTypeUpdated(sender: AnyObject) {
        
        let segControl = sender as! UISegmentedControl
        if segControl.selectedSegmentIndex == 0 {
            HSGameConstants.gameType = GameType.HasamiShogi
            horizontalToWinSwitch.enabled = false
        }
        else {
            HSGameConstants.gameType = GameType.DiaHasamiShogi
            horizontalToWinSwitch.enabled = true
        }
        
        updateStepperConstraints(HSGameConstants.gameType)
    }
    
    /**
    Called when the value is changed on the UIStepper indicating
    the number of counters required to win
    
    - parameter sender: The UIStepper
    */
    @IBAction func stepperValueChanged(sender: AnyObject) {
        let stepper = sender as! UIStepper
        
        HSGameConstants.numberOfPiecesToWin = Int(stepper.value)
        
        counterToWinLabel.text = "\(Int(stepper.value))"
    }
    
    
    /**
    Called when the value of the Horizontal To Win switch is changed
    
    - parameter sender: the UISwitch
    */
    @IBAction func horizontalToWinSwitchValueChanged(sender: AnyObject) {
        let horizontalSwitch = sender as! UISwitch
        
        HSGameConstants.lineToWin = horizontalSwitch.on
    }
    
    
}
