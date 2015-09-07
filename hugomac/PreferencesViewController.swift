//
//  PreferencesViewController.swift
//  hugomac
//
//  Created by Nick O'Neill on 8/31/15.
//  Copyright © 2015 Launch Apps. All rights reserved.
//

import Foundation
import Cocoa

class PreferencesViewController: NSViewController, CCNPreferencesWindowControllerProtocol {
    
    @IBAction func pickConfig(sender: NSButton) {
        print("config")
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
