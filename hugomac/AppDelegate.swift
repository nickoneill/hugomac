//
//  AppDelegate.swift
//  hugomac
//
//  Created by Nick O'Neill on 8/31/15.
//  Copyright © 2015 Launch Apps. All rights reserved.
//

import Cocoa
import CCNPreferencesWindowController

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-2)
    let menuStatus = NSMenuItem()
    let preferences = CCNPreferencesWindowController()
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        if let button = statusItem.button {
            button.image = NSImage(named: "StatusBarButtonImage")
            button.action = Selector("printQuote:")
        }
        
        let menu = NSMenu()
        
        menuStatus.title = "status"
        menuStatus.enabled = false
        menu.addItem(menuStatus)
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(NSMenuItem(title: "Publish", action: Selector("publish"), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Preferences", action: Selector("prefs"), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Quit hugomac", action: Selector("terminate:"), keyEquivalent: "q"))
        
        statusItem.menu = menu
        
        // set up preferences windows
        preferences.centerToolbarItems = false
        preferences.setPreferencesViewControllers([PreferencesViewController(),PublishingViewController()])
    }
    
    func prefs() {
        preferences.showPreferencesWindow()
    }
    
    func publish() {
        do {
            let timer = NSTimer(timeInterval: 1/30, target: self, selector: Selector("updateItem"), userInfo: nil, repeats: true)
            NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
            try HugoController.sharedInstance.publish()
            menuStatus.title = "published"
            print("publish success")
        } catch HugoController.HugoError.DidntWork {
            menuStatus.title = "publish failed"
            print("publish failed")
        } catch {
            print("something else")
        }
    }
    
    func updateItem() {
        let time = NSDate()
        let mod = time.timeIntervalSince1970 % 4
        switch mod {
        case 0..<1:
            menuStatus.title = "publishing"
        case 1..<2:
            menuStatus.title = "publishing."
        case 2..<3:
            menuStatus.title = "publishing.."
        case 3..<4:
            menuStatus.title = "publishing..."
        default:
            break
        }
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

