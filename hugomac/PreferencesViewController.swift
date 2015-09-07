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

class PreferencesViewController: NSViewController, CCNPreferencesWindowControllerProtocol {
    @IBOutlet weak var contentText: NSTextField!
    let contentURL = DefaultsKey<NSURL?>("contentURL")
    
    override func viewDidLoad() {
        if let contentURL = Defaults[contentURL] {
            print("got content",contentURL)
        } else {
            print("no content url")
        }
    }
    
    @IBAction func pickContent(sender: NSButton) {
        print("content")
        
        if let contentPath = getContentPath() {
            Defaults[contentURL] = contentPath
            print("content path",contentPath)
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
        print("theme")
        
        let themePath = getThemePath()
        print("theme path",themePath)
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
