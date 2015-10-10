//
//  HSContainerViewController.swift
//  Hasami Shogi
//
//  Created by Oliver Poole on 06/10/2015.
//  Copyright © 2015 OliverPoole. All rights reserved.
//

import UIKit
import QuartzCore

enum SlideOutState {
    case Collapsed
    case Expanded
}

/// The container view controller for holding the current screen and the side bar
class HSContainerViewController: UIViewController {
    
    var containerNavigationController : UINavigationController!
    var currentViewController : UIViewController!
    
    var currentState : SlideOutState = .Collapsed {
        didSet {
            let shouldShowShadow = currentState != .Collapsed
            showShadowForViewController(shouldShowShadow)
        }
    }
    
    var menuViewController : HSMenuViewController!
    
    let menuPanelExpandedOffset: CGFloat = 60

    override func viewDidLoad() {
        super.viewDidLoad()

        currentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("HSGameViewController") as! HSGameViewController
        HSSideBarDelegateStore.delegate = self
        
        containerNavigationController = UINavigationController(rootViewController: currentViewController)
        view.addSubview(containerNavigationController.view)
        
        containerNavigationController.didMoveToParentViewController(self)
    }
}

extension HSContainerViewController: HSSideBarDelegate {
    
    func toggleSideBar(sender: UIViewController) {
        
        sender.view.userInteractionEnabled = false
        
        let notAlreadyExpanded = (currentState != .Expanded)
        
        if notAlreadyExpanded {
            addLeftPanelViewController(sender)
        }
        
        animateLeftPanel(notAlreadyExpanded) { () -> Void in
            sender.view.userInteractionEnabled = true
            
            if sender != self.currentViewController {
                self.changeViewController(withNew: sender)
            }
        }
    }
    
    
    func changeViewController(withNew viewController: UIViewController) {
        
        currentViewController!.view.removeFromSuperview()
        containerNavigationController.view.removeFromSuperview()
        
        currentViewController = viewController
        containerNavigationController = UINavigationController(rootViewController: currentViewController)
        view.addSubview(containerNavigationController.view)
        
        containerNavigationController.didMoveToParentViewController(self)
    }
    
    
    func addLeftPanelViewController(sender: UIViewController) {
        if (menuViewController == nil) {
            menuViewController = self.storyboard?.instantiateViewControllerWithIdentifier("HSMenuViewController") as! HSMenuViewController
            
            // Set reference to the current view controller for the menu to use
            menuViewController.menuContainer = sender
            
            addChildSidePanelController(menuViewController!)
        }
    }
    
    
    func addChildSidePanelController(sidePanelController: HSMenuViewController) {
        view.insertSubview(sidePanelController.view, atIndex:0)
        
        addChildViewController(sidePanelController)
        sidePanelController.didMoveToParentViewController(self)
    }
    
    
    func animateLeftPanel(shouldExpand: Bool, animationCompleted: () -> Void) {
        if shouldExpand {
            currentState = .Expanded
            
            animateCenterPanelXPosition(targetPosition: CGRectGetWidth(containerNavigationController.view.frame) - menuPanelExpandedOffset)
        }
        else {
            animateCenterPanelXPosition(targetPosition: 0, completion: { (finished) -> Void in
                self.currentState = .Collapsed
                
                self.menuViewController!.view.removeFromSuperview()
                self.menuViewController = nil
                
                animationCompleted()
            })
        }
    }
    
    
    func animateCenterPanelXPosition(targetPosition targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: { () -> Void in
            self.containerNavigationController.view.frame.origin.x = targetPosition
            
            },
            completion: completion)
    }
    
    
    func showShadowForViewController(shouldShowShadow: Bool) {
        
        containerNavigationController.view.layer.shadowOpacity = shouldShowShadow ? 0.8 : 0.0
    }
}
