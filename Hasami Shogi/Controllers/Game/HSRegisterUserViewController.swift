//
//  HSRegisterUserViewController.swift
//  Hasami Shogi
//
//  Created by Oliver Poole on 27/09/2015.
//  Copyright © 2015 OliverPoole. All rights reserved.
//

import UIKit
import AddressBook
import Contacts
import ContactsUI

protocol HSRegisterUserViewControllerDelegate {
    
    func didFinishRegisteringUser(user: User)
}

class HSRegisterUserViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileUsernameTextField: UITextField!
    @IBOutlet weak var profileBioTextView: UITextView!
    
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    @IBAction func updateProfileImageButtonPressed(sender: UIButton) {
        // show the iphone photo library
        
    }

    
    @IBAction func addFromContactsButtonPressed(sender: AnyObject) {
        // show some sort of dialog for displaying the contacts
        
        if #available(iOS 9.0, *) {
            let contactPicker = CNContactPickerViewController()
            contactPicker.delegate = self
            self.presentViewController(contactPicker, animated: true, completion: nil)
            
            
        } else {
            // Fallback on earlier versions
            requestAddressBookAccessForIOS8WithCompletion({ (addressBook) -> Void in
                // now we have access, start loading contacts
                let contacts = self.loadContactsFromAddressBook(addressBook)
            })
        }
        
    }
    
    
    @IBAction func registerUserButtonPressed(sender: AnyObject) {
        // Validate the fields, then register the user and return
    }
    
    
    // MARK: - Loading Contacts
    
    func requestAddressBookAccessForIOS8WithCompletion(completion: (addressBook : ABAddressBook) -> Void) {
        
        let addressBookRef = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
        
        ABAddressBookRequestAccessWithCompletion(addressBookRef) { (granted : Bool, error : CFError!) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                if !granted {
                    print("Access Denied")
                    self.handleContactsDenied()
                }
                else {
                    print("Autherised")
                    completion(addressBook: addressBookRef)
                }
            }
        }
    }
    
    func loadContactsFromAddressBook(addressBook : ABAddressBook) -> Array<ABRecordRef> {
        let contacts = ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue() as Array
        
        return contacts
    }
    
    
    /**
    Opens the device's settings application to the app's settings page
    */
    func openSettings() {
        let url = NSURL(string: UIApplicationOpenSettingsURLString)
        UIApplication.sharedApplication().openURL(url!)
    }
    
    
    func loadIOS9Contacts() {
        
    }
    
    /**
    Displays an error message and links to the settings app when the user denies contacts access
    */
    func handleContactsDenied() {
        let alertController = UIAlertController(title: "Cannot Access Contacts", message: "You must give the app permisson to access the contacts", preferredStyle: .Alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .Default) { (UIAlertAction) -> Void in self.openSettings() }
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        
        alertController.addAction(settingsAction)
        alertController.addAction(okAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}

extension HSRegisterUserViewController : UITextViewDelegate {
    func textViewDidBeginEditing(textView: UITextView) {
        // drop the placeholder text
        if textView.text == "Enter a short bio..." {
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        // check for input, else re-add placeholder text
        if textView.text == "" {
            textView.text = "Enter a short bio..."
        }
    }
}

extension HSRegisterUserViewController : CNContactPickerDelegate {
    
    @available(iOS 9.0, *)
    func contactPicker(picker: CNContactPickerViewController, didSelectContact contact: CNContact) {
        
        self.profileUsernameTextField.text = contact.givenName
        self.profileBioTextView.text = contact.note
        
        if contact.imageDataAvailable {
            self.profileImageView.image = UIImage(data: contact.imageData!)
        }
    }
    
}