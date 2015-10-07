//
//  HSRegisterUserViewController.swift
//  Hasami Shogi
//
//  Created by Oliver Poole on 27/09/2015.
//  Copyright © 2015 OliverPoole. All rights reserved.
//

import UIKit

import AddressBook
import AddressBookUI

import Contacts
import ContactsUI

protocol HSRegisterUserViewControllerDelegate {
    
    func didFinishRegisteringUser(user: User)
}

class HSRegisterUserViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileUsernameTextField: UITextField!
    @IBOutlet weak var profileBioTextView: UITextView!
    
    var delegate : HSRegisterUserViewControllerDelegate!
    
    var imagePicker : UIImagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("dismissKeyboard:"))
        gestureRecognizer.numberOfTapsRequired = 1
        
        self.view.addGestureRecognizer(gestureRecognizer)
    }
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    @IBAction func updateProfileImageButtonPressed(sender: UIButton) {
        // show the iphone photo library
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) {
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
            self.imagePicker.allowsEditing = false
            
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
        }
    }

    
    @IBAction func addFromContactsButtonPressed(sender: AnyObject) {
        // show some sort of dialog for displaying the contacts
        
        if #available(iOS 9.0, *) {
            let contactPicker = CNContactPickerViewController()
            contactPicker.delegate = self
            self.presentViewController(contactPicker, animated: true, completion: nil)
            
            
        } else {
            // Fallback on earlier versions
            let personViewController = ABPeoplePickerNavigationController()
            personViewController.peoplePickerDelegate = self
            self.presentViewController(personViewController, animated: true, completion: nil)
        }
        
    }
    
    
    @IBAction func registerUserButtonPressed(sender: AnyObject) {
        // Validate the fields, then register the user and return
        
        if self.profileUsernameTextField.text?.isEmpty == false {
            let username = self.profileUsernameTextField.text
            
            if self.profileBioTextView.text != "Enter a short bio..." {
                let bio = self.profileBioTextView.text
                
                let image = self.profileImageView.image
                if let image = image {
                    let user = HSDatabaseManager.createUserWith(username!, bio: bio, profileImage: image)
                    
                    if let _ = user {
                        // save was successful, return to player screen
                        self.delegate.didFinishRegisteringUser(user!)
                        
                        self.navigationController?.popViewControllerAnimated(true)
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
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    /**
    Dismisses the keyboard
    
    - parameter gestureRecognizer: The recognizer being fired
    */
    func dismissKeyboard(gestureRecognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
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

extension HSRegisterUserViewController : UIImagePickerControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        self.profileImageView.image = image
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

extension HSRegisterUserViewController : ABPeoplePickerNavigationControllerDelegate {
    
    func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController, didSelectPerson person: ABRecord) {
        
        if let firstName = ABRecordCopyValue(person, kABPersonFirstNameProperty) {
            self.profileUsernameTextField.text = firstName.takeRetainedValue() as? String
        }
        
        if let bio = ABRecordCopyValue(person, kABPersonNoteProperty) {
            self.profileBioTextView.text = bio.takeRetainedValue() as? String
        }
        
        if ABPersonHasImageData(person) {
            let imageData = ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatOriginalSize).takeRetainedValue()
            self.profileImageView.image = UIImage(data: imageData)
        }
    }
}