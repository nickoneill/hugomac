//
//  PublishingViewController.swift
//  
//
//  Created by Nick O'Neill on 9/14/15.
//
//

import Foundation
import Cocoa
import CCNPreferencesWindowController

class PublishingViewController: NSViewController, CCNPreferencesWindowControllerProtocol, NSTextFieldDelegate {
    
    @IBOutlet weak var bucketNameField: NSTextField! {
        didSet {
            bucketNameField.stringValue = ConfigurationManager.sharedInstance.bucketName
        }
    }
    @IBOutlet weak var accessKeyField: NSTextField! {
        didSet {
            accessKeyField.stringValue = ConfigurationManager.sharedInstance.accessKey
        }
    }
    @IBOutlet weak var secretKeyField: NSTextField! {
        didSet {
            if ConfigurationManager.sharedInstance.secretKey != nil {
                secretKeyField.stringValue = "123456789"
            }
        }
    }
//    @IBOutlet weak var siteURLField: NSTextField! {
//        didSet {
//            siteURLField.stringValue = ConfigurationManager.sharedInstance.siteURL
//        }
//    }
//    @IBOutlet weak var siteTitleField: NSTextField! {
//        didSet {
//            siteTitleField.stringValue = ConfigurationManager.sharedInstance.siteTitle
//        }
//    }
    
    override func viewDidLoad() {
        //
    }
    
    func control(control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        let control = control as! NSTextField
        
        if control == bucketNameField {
            ConfigurationManager.sharedInstance.bucketName = bucketNameField.stringValue
        } else if control == accessKeyField {
            ConfigurationManager.sharedInstance.accessKey = accessKeyField.stringValue
        } else if control == secretKeyField {
            if secretKeyField.stringValue != "123456789" && !secretKeyField.stringValue.isEmpty {
                ConfigurationManager.sharedInstance.secretKey = secretKeyField.stringValue
            }
        }
        
        return true
    }
    
    
    // prefs
    
    func preferenceIdentifier() -> String! {
        return "publishing";
    }
    
    func preferenceTitle() -> String! {
        return "Publishing"
    }
    
    func preferenceIcon() -> NSImage! {
        return NSImage(named: "StatusBarButtonImage")
    }
}
