//
//  HSRegisterUserTableViewController.swift
//  Hasami Shogi
//
//  Created by Oliver Poole on 11/10/2015.
//  Copyright © 2015 OliverPoole. All rights reserved.
//

import UIKit

import AddressBook
import AddressBookUI

import Contacts
import ContactsUI

/**
 *  Notify the presenting view controller that a new user has been added.
 *  This will ensure that the presenting view controller knows to update the choices
 */
protocol HSRegisterUserTableViewControllerDelegate {
    func registerTableViewController(registerTableViewController: HSRegisterUserTableViewController, didRegisterNewUser newUser: User)
}

class HSRegisterUserTableViewController: UITableViewController, UINavigationControllerDelegate {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileUsernameTextField: UITextField!
    @IBOutlet weak var profileBioTextView: UITextView!
    
    var imagePicker : UIImagePickerController = UIImagePickerController()
    
    var delegate : HSRegisterUserTableViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("dismissKeyboard:"))
        gestureRecognizer.numberOfTapsRequired = 1
        
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    @IBAction func updateProfileImageButtonPressed(sender: UIButton) {
        // show the iphone photo library
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) {
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
            imagePicker.allowsEditing = false
            
            presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func addFromContactsButtonPressed(sender: AnyObject) {
        // show some sort of dialog for displaying the contacts
        
        if #available(iOS 9.0, *) {
            let contactPicker = CNContactPickerViewController()
            contactPicker.delegate = self
            presentViewController(contactPicker, animated: true, completion: nil)
            
            
        } else {
            // Fallback on earlier versions
            let personViewController = ABPeoplePickerNavigationController()
            personViewController.peoplePickerDelegate = self
            presentViewController(personViewController, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func registerUserButtonPressed(sender: AnyObject) {
        // Validate the fields, then register the user and return
        
        if profileUsernameTextField.text?.isEmpty == false {
            let username = profileUsernameTextField.text
            
            if profileBioTextView.text != "Enter a short bio..." {
                let bio = profileBioTextView.text
                
                let image = profileImageView.image
                if let image = image {
                    let user = HSGameDataManager.createUserWith(username!, bio: bio, profileImage: image, isDefaultUser: false)
                    
                    if let _ = user {
                        // save was successful, return to player screen
                        delegate?.registerTableViewController(self, didRegisterNewUser: user!)
                        self.navigationController?.popViewControllerAnimated(true)
                        return
                    }
                }
            }
        }
        
        // One of the if statements has failed - display an alert controller
        displayErrorAlertController()
    }
    
    /**
    Displays an alert controller with a generic error
    */
    func displayErrorAlertController () {
        let alertController = UIAlertController(title: "Error", message: "One or more fields not complete", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    /**
    Dismisses the keyboard
    
    - parameter gestureRecognizer: The recognizer being fired
    */
    func dismissKeyboard(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
}

extension HSRegisterUserTableViewController : UITextViewDelegate {
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

extension HSRegisterUserTableViewController : UIImagePickerControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        dismissViewControllerAnimated(true, completion: nil)
        
        profileImageView.image = image
    }
}

extension HSRegisterUserTableViewController : CNContactPickerDelegate {
    
    @available(iOS 9.0, *)
    func contactPicker(picker: CNContactPickerViewController, didSelectContact contact: CNContact) {
        
        profileUsernameTextField.text = contact.givenName
        profileBioTextView.text = contact.note
        
        if contact.imageDataAvailable {
            profileImageView.image = UIImage(data: contact.imageData!)
        }
    }
}

extension HSRegisterUserTableViewController : ABPeoplePickerNavigationControllerDelegate {
    
    func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController, didSelectPerson person: ABRecord) {
        
        if let firstName = ABRecordCopyValue(person, kABPersonFirstNameProperty) {
            profileUsernameTextField.text = firstName.takeRetainedValue() as? String
        }
        
        if let bio = ABRecordCopyValue(person, kABPersonNoteProperty) {
            profileBioTextView.text = bio.takeRetainedValue() as? String
        }
        
        if ABPersonHasImageData(person) {
            let imageData = ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatOriginalSize).takeRetainedValue()
            profileImageView.image = UIImage(data: imageData)
        }
    }
}
