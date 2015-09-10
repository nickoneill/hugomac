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
import SwiftyUserDefaults

class PreferencesViewController: NSViewController, CCNPreferencesWindowControllerProtocol, NSTextFieldDelegate {
    let contentURL = DefaultsKey<NSURL?>("contentURL")
    let themeURL = DefaultsKey<NSURL?>("themeURL")
    let siteURL = DefaultsKey<String>("siteURL")
    let siteTitle = DefaultsKey<String>("siteTitle")

    @IBOutlet weak var contentField: NSTextField! {
        didSet {
            if let contentURL = Defaults[contentURL] {
                contentField.stringValue = contentURL.absoluteString
                print("got content",contentURL)
            } else {
                print("no content url")
            }
        }
    }
    @IBOutlet weak var themeField: NSTextField! {
        didSet {
            if let themeURL = Defaults[themeURL] {
                themeField.stringValue = themeURL.absoluteString
                print("got theme",themeURL)
            } else {
                print("no theme url")
            }
        }
    }
    @IBOutlet weak var siteURLField: NSTextField! {
        didSet {
            siteURLField.stringValue = Defaults[siteURL]
        }
    }
    @IBOutlet weak var siteTitleField: NSTextField! {
        didSet {
            siteTitleField.stringValue = Defaults[siteTitle]
        }
    }
    
    override func viewDidLoad() {
        //
    }
    
    func control(control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        let control = control as! NSTextField
        
        if control == siteTitleField {
            Defaults[siteTitle] = siteTitleField.stringValue
        } else if control == siteURLField {
            Defaults[siteURL] = siteURLField.stringValue
        }
        
        return true
    }
    
    @IBAction func pickContent(sender: NSButton) {
        if let contentPath = getContentPath() {
            Defaults[contentURL] = contentPath
        }
    }
    
    func getContentPath() -> NSURL? {
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
        if let themePath = getThemePath() {
            Defaults[themeURL] = themePath
        }
    }
    
    func getThemePath() -> NSURL? {
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
