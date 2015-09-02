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
        case CantReachSupportPath
        case CantReadHugoOutput
        case DidntWork
    }
    
    func publish() throws {
//        writeConfig()
//        linkContentDir()

        if let supportPath = supportPath() {
            let task = NSTask()
            task.launchPath = hugoPath()
            task.arguments = ["-s", supportPath]
            
            let pipe = NSPipe()
            task.standardOutput = pipe
            task.launch()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = NSString(data: data, encoding: NSUTF8StringEncoding)
            
            if let output = output {
                print(output)
                if let logPath = logPath() {
                    _ = try? output.writeToFile(logPath, atomically: true, encoding: NSUTF8StringEncoding)
                }
            } else {
                throw Error.CantReadHugoOutput
            }
        } else {
            throw Error.CantReachSupportPath
        }
    }
    
    private func linkContentDir() {
        let origContentURL = NSURL(fileURLWithPath: "/Users/nickoneill/Dropbox/Blog/content/", isDirectory: true)
        let linkedContentURL = NSURL(fileURLWithPath: contentPath()!, isDirectory: true)
 
        do {
            try NSFileManager.defaultManager().linkItemAtURL(origContentURL, toURL: linkedContentURL)
        } catch {
            print("some linking error")
        }
    }
    
    private func writeConfig() {
        var config = Dictionary<String, AnyObject>()
        config["baseurl"] = "http://blog.nickoneill.name/"
        config["title"] = "authenticgeek"
        config["canonifyurls"] = true
        
        if let configPath = configPath() {
            let configData = try? NSJSONSerialization.dataWithJSONObject(config, options: .PrettyPrinted)
            configData?.writeToFile(configPath, atomically: true)
        }
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
    
    private func supportPath() -> String? {
        let configPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.ApplicationSupportDirectory, NSSearchPathDomainMask.UserDomainMask, true).first
        
        if let configPath = configPath {
            let supportPath = (configPath as NSString).stringByAppendingPathComponent("hugomac")
            if !NSFileManager.defaultManager().fileExistsAtPath(supportPath) {
                do {
                    try NSFileManager.defaultManager().createDirectoryAtPath(supportPath, withIntermediateDirectories: false, attributes: nil)
                } catch {
                    return nil
                }
            }

            return supportPath
        }

        return nil
    }
    
    private func configPath() -> String? {
        if let supportPath = supportPath() {
            return (supportPath as NSString).stringByAppendingPathComponent("config.json")
        }

        return nil
    }

    private func contentPath() -> String? {
        if let supportPath = supportPath() {
            return (supportPath as NSString).stringByAppendingPathComponent("content")
        }
        
        return nil
    }
    
    private func logPath() -> String? {
        if let supportPath = supportPath() {
            return (supportPath as NSString).stringByAppendingPathComponent("hugo.log")
        }
        
        return nil
    }
}