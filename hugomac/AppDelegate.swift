//
//  AppDelegate.swift
//  hugomac
//
//  Created by Nick O'Neill on 8/31/15.
//  Copyright © 2015 Launch Apps. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-2)
    let menuStatus = NSMenuItem()
    
    lazy var preferences: NSWindowController = {
        let generalViewController = Pre
    }()

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
        menu.addItem(NSMenuItem(title: "Quit hugomac", action: Selector("terminate:"), keyEquivalent: "q"))
        
        statusItem.menu = menu
        
    }
    
    func publish() {
        do {
            menuStatus.title = "publishing..."
            try HugoController.sharedInstance.publish()
            menuStatus.title = "published"
            print("publish success")
        } catch HugoController.Error.DidntWork {
            menuStatus.title = "publish failed"
            print("publish failed")
        } catch {
            print("something else")
        }
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

