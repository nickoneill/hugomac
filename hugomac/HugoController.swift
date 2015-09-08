//
//  HugoController.swift
//  hugomac
//
//  Created by Nick O'Neill on 8/31/15.
//  Copyright © 2015 Launch Apps. All rights reserved.
//

import Foundation
import AWSS3

final class HugoController {
    static let sharedInstance = HugoController()
    
    var uploadRequests: [AWSS3TransferManagerUploadRequest] = []
    
    enum Error: ErrorType {
        case CantReachSupportPath
        case CantReadHugoOutput
        case NoPublishDirectory
        case DidntWork
    }
    
    func publish() throws {
//        writeConfig()
//        linkContentDir()
//        linkThemeDir()
        _ = try? transferToS3()
        return

        if let supportPath = supportPath(), let logPath = logPath() {
            let task = NSTask()
            task.launchPath = hugoPath()
            task.arguments = ["-s", supportPath, "-t", "current_theme"]
            
            let pipe = NSPipe()
            task.standardOutput = pipe
            task.launch()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = NSString(data: data, encoding: NSUTF8StringEncoding)
            
            if let output = output {
                print(output)
            } else {
                throw Error.CantReadHugoOutput
            }
        } else {
            throw Error.CantReachSupportPath
        }
    }
    
    private func transferToS3() throws {
        if let publicPath = publicPath() {
            if !NSFileManager.defaultManager().fileExistsAtPath(publicPath) {
                throw Error.NoPublishDirectory
            }
            
            try makeUploadsForItemsInDirectory(publicPath)
            
            print("made these uploads: ",uploadRequests)

            let credentialsProvider = AWSStaticCredentialsProvider(accessKey: "AKIAJI5JMQGAWZ6CKXOA", secretKey: "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")
            let configuration = AWSServiceConfiguration(region: AWSRegionType.USWest1, credentialsProvider: credentialsProvider)
            AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration

            let transferManager = AWSS3TransferManager.defaultS3TransferManager()
            for req in uploadRequests {
                transferManager.upload(req).continueWithBlock({ (awsTask) -> AnyObject! in
//                    print("ok",awsTask)
                    return nil
                })
            }
        }
    }
    
    private func makeUploadsForItemsInDirectory(path: String) throws {
        for itemName in try NSFileManager.defaultManager().contentsOfDirectoryAtPath(path) {
            let checkPath = (path as NSString).stringByAppendingPathComponent(itemName)
            
            var isDir: ObjCBool = false
            if NSFileManager.defaultManager().fileExistsAtPath(checkPath, isDirectory: &isDir) {
                if isDir {
                    print("directory is",itemName)
                    try makeUploadsForItemsInDirectory(checkPath)
                } else {
                    let uploadRequest = AWSS3TransferManagerUploadRequest()
                    let pathURL = NSURL(fileURLWithPath: checkPath)
                    uploadRequest.body = pathURL
                    uploadRequest.contentType = "text/html"
                    
                    let components = (checkPath as NSString).pathComponents
                    print("making upload for",itemName)
                    let inPublicComponents = (components as NSArray).subarrayWithRange(NSMakeRange(7, components.count - 7)) as! [String]
                    uploadRequest.key = NSString.pathWithComponents(inPublicComponents)
                    uploadRequest.bucket = "nickoneill-blog-test"
                    uploadRequests.append(uploadRequest)
                }
            } else {
                print("no file exists at",itemName)
            }
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
    
    private func linkThemeDir() {
        let origThemeURL = NSURL(fileURLWithPath: "/Users/nickoneill/Projects/blog.nickoneill.name/themes/blog-nickoneill/", isDirectory: true)
        let linkedThemeURL = NSURL(fileURLWithPath: themePath()!, isDirectory: true)
        
        do {
            try NSFileManager.defaultManager().linkItemAtURL(origThemeURL, toURL: linkedThemeURL)
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
    
    // MARK - path generators
    
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

    private func themePath() -> String? {
        if let supportPath = supportPath() {
            let themesPath = (supportPath as NSString).stringByAppendingPathComponent("themes")
            return (themesPath as NSString).stringByAppendingPathComponent("current_theme")
        }
        
        return nil
    }

    private func publicPath() -> String? {
        if let supportPath = supportPath() {
            return (supportPath as NSString).stringByAppendingPathComponent("public")
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