//
//  PreferencesViewController.swift
//  hugomac
//
//  Created by Nick O'Neill on 8/31/15.
//  Copyright © 2015 Launch Apps. All rights reserved.
//

import Foundation
import Cocoa
import CCNPreferencesWindowController

class PreferencesViewController: NSViewController, CCNPreferencesWindowControllerProtocol, NSTextFieldDelegate {

    @IBOutlet weak var contentField: NSTextField! {
        didSet {
            contentField.stringValue = ConfigurationManager.sharedInstance.contentPath
        }
    }
    @IBOutlet weak var themeField: NSTextField! {
        didSet {
            themeField.stringValue = ConfigurationManager.sharedInstance.themePath
        }
    }
    @IBOutlet weak var siteURLField: NSTextField! {
        didSet {
            siteURLField.stringValue = ConfigurationManager.sharedInstance.siteURL
        }
    }
    @IBOutlet weak var siteTitleField: NSTextField! {
        didSet {
            siteTitleField.stringValue = ConfigurationManager.sharedInstance.siteTitle
        }
    }
    
    override func viewDidLoad() {
        //
    }
    
    func control(control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        let control = control as! NSTextField
        
        if control == siteTitleField {
            ConfigurationManager.sharedInstance.siteTitle = siteTitleField.stringValue
        } else if control == siteURLField {
            ConfigurationManager.sharedInstance.siteURL = siteURLField.stringValue
        }
        
        return true
    }
    
    @IBAction func pickContent(sender: NSButton) {
        if let contentURL = getContentURL(), let path = contentURL.path {
            ConfigurationManager.sharedInstance.contentPath = path
            contentField.stringValue = path
        }
    }
    
    func getContentURL() -> NSURL? {
        let myPanel = NSOpenPanel()
        myPanel.allowsMultipleSelection = false
        myPanel.canChooseDirectories = true
        myPanel.canChooseFiles = false
        if ( myPanel.runModal() != NSFileHandlingPanelOKButton ) {
            return nil
        }
        return myPanel.URLs[0]
    }

    @IBAction func pickTheme(sender: NSButton) {
        if let themeURL = getThemeURL(), let path = themeURL.path {
            ConfigurationManager.sharedInstance.themePath = path
            themeField.stringValue = path
        }
    }
    
    func getThemeURL() -> NSURL? {
        let myPanel = NSOpenPanel()
        myPanel.allowsMultipleSelection = false
        myPanel.canChooseDirectories = true
        myPanel.canChooseFiles = false
        if ( myPanel.runModal() != NSFileHandlingPanelOKButton ) {
            return nil
        }
        return myPanel.URLs[0]
    }

    // prefs
    
    func preferenceIdentifier() -> String! {
        return "preferences";
    }
    
    func preferenceTitle() -> String! {
        return "Prefs"
    }
    
    func preferenceIcon() -> NSImage! {
        return NSImage(named: "StatusBarButtonImage")
    }
}
