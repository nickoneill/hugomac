//
//  HugoController.swift
//  hugomac
//
//  Created by Nick O'Neill on 8/31/15.
//  Copyright © 2015 Launch Apps. All rights reserved.
//

import Foundation

final class HugoController {
    static let sharedInstance = HugoController()
    
    enum Error: ErrorType {
        case DidntWork
    }
    
    func publish() throws {
        let task = NSTask()
        task.launchPath = hugoPath()
        task.arguments = ["-s", "/Users/nickoneill/Projects/blog.nickoneill.name"]
        
        let pipe = NSPipe()
        task.standardOutput = pipe
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = NSString(data: data, encoding: NSUTF8StringEncoding)
        
        print(output)
        
//        throw Error.DidntWork
    }
    
    private func hugoPath() -> String {
        let bundlePath = (NSBundle.mainBundle().bundlePath as NSString)
        let contentsPath = (bundlePath as NSString).stringByAppendingPathComponent("Contents")
        let resourcesPath = (contentsPath as NSString).stringByAppendingPathComponent("Resources")
        let hugoPath = (resourcesPath as NSString).stringByAppendingPathComponent("hugo_0.14_darwin_amd64")
        print("path: ",resourcesPath)
        
        let contents = try? NSFileManager.defaultManager().contentsOfDirectoryAtPath(resourcesPath)
        print("contents: ",contents)
        
        return hugoPath
    }
}