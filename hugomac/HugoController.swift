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
    
    enum HugoError: ErrorType {
        case NoThemeSet
        case NoContentSet
        case NoBaseURLSet
        case NoTitleSet
        case CantReachSupportPath
        case CantReadHugoOutput
        case NoPublishDirectory
        case DidntWork
    }
    
    func publish() throws {
        do {
            try writeConfig()
        } catch HugoError.NoBaseURLSet {
            print("no base url")
        } catch HugoError.NoTitleSet {
            print("no title set")
        }
        // we don't actually use the static dir but hugo doesn't
        // take static from a theme if there's no static here
        createStaticDir()
        linkContentDir()
        linkThemeDir()

        if let supportPath = supportPath() {
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
                throw HugoError.CantReadHugoOutput
            }
        } else {
            throw HugoError.CantReachSupportPath
        }
        
        _ = try? transferToS3()
    }
    
    private func transferToS3() throws {
        if let publicPath = publicPath() {
            if !NSFileManager.defaultManager().fileExistsAtPath(publicPath) {
                throw HugoError.NoPublishDirectory
            }
            
            try makeUploadsForItemsInDirectory(publicPath)
            
//            print("made these uploads: ",uploadRequests)

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
            
            uploadRequests.removeAll()
        }
    }
    
    private func makeUploadsForItemsInDirectory(path: String) throws {
        for itemName in try NSFileManager.defaultManager().contentsOfDirectoryAtPath(path) {
            let checkPath = (path as NSString).stringByAppendingPathComponent(itemName)
            
            var isDir: ObjCBool = false
            if NSFileManager.defaultManager().fileExistsAtPath(checkPath, isDirectory: &isDir) {
                if isDir {
//                    print("directory is",itemName)
                    try makeUploadsForItemsInDirectory(checkPath)
                } else {
                    let uploadRequest = AWSS3TransferManagerUploadRequest()
                    let pathURL = NSURL(fileURLWithPath: checkPath)
                    uploadRequest.body = pathURL
                    uploadRequest.ACL = AWSS3ObjectCannedACL.PublicRead
                    uploadRequest.contentType = MIMEType((checkPath as NSString).pathExtension) ?? "text/html"
                    
                    let components = (checkPath as NSString).pathComponents
//                    print("making upload for",itemName)
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
    
    private func createStaticDir() {
        if let staticPath = staticPath() {
            if !NSFileManager.defaultManager().fileExistsAtPath(staticPath) {
                do {
                    try NSFileManager.defaultManager().createDirectoryAtPath(staticPath, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print("error creating static directory")
                }
            }
        }
    }
    
    private func linkContentDir() {
        if NSFileManager.defaultManager().fileExistsAtPath(contentPath()!) {
            do {
                try NSFileManager.defaultManager().removeItemAtPath(contentPath()!)
            } catch {
                print("error deleting linked content directory")
            }
        }
        
        do {
            let userContentPath = ConfigurationManager.sharedInstance.contentPath
            if userContentPath.isEmpty {
                throw HugoError.NoContentSet
            }
            
            let origContentURL = NSURL(fileURLWithPath: userContentPath, isDirectory: true)
            let linkedContentURL = NSURL(fileURLWithPath: contentPath()!, isDirectory: true)

            try NSFileManager.defaultManager().linkItemAtURL(origContentURL, toURL: linkedContentURL)
        } catch HugoError.NoContentSet {
            print("no content")
        } catch {
            print("some content linking error")
        }
    }
    
    private func linkThemeDir() {
        if NSFileManager.defaultManager().fileExistsAtPath(themePath()!) {
            do {
                try NSFileManager.defaultManager().removeItemAtPath(themePath()!)
            } catch {
                print("error deleting linked theme directory")
            }
        }

        do {
            let userThemePath = ConfigurationManager.sharedInstance.themePath
            if userThemePath.isEmpty {
                throw HugoError.NoThemeSet
            }
            
            let origThemeURL = NSURL(fileURLWithPath: userThemePath, isDirectory: true)
            let linkedThemeURL = NSURL(fileURLWithPath: themePath()!, isDirectory: true)
            
            try NSFileManager.defaultManager().linkItemAtURL(origThemeURL, toURL: linkedThemeURL)
        } catch {
            print("some theme linking error")
        }
    }
    
    private func writeConfig() throws {
        let siteURL = ConfigurationManager.sharedInstance.siteURL
        if siteURL.isEmpty {
            throw HugoError.NoBaseURLSet
        }
        
        let siteTitle = ConfigurationManager.sharedInstance.siteTitle
        if siteTitle.isEmpty {
            throw HugoError.NoTitleSet
        }
        
        var config = Dictionary<String, AnyObject>()
        config["baseurl"] = siteURL
        config["title"] = siteTitle
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
        
        _ = try? NSFileManager.defaultManager().contentsOfDirectoryAtPath(resourcesPath)
        
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
    
    private func staticPath() -> String? {
        if let supportPath = supportPath() {
            return (supportPath as NSString).stringByAppendingPathComponent("static")
        }
        
        return nil
    }
    
    private func logPath() -> String? {
        if let supportPath = supportPath() {
            return (supportPath as NSString).stringByAppendingPathComponent("hugo.log")
        }
        
        return nil
    }
    
    private func MIMEType(fileExtension: String) -> String? {
        if !fileExtension.isEmpty {
            let UTIRef = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, nil)!
            let UTI = UTIRef.takeUnretainedValue()
            UTIRef.release()
            
            let MIMETypeRef = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType)
            if MIMETypeRef != nil {
                let MIMEType = MIMETypeRef!.takeUnretainedValue()
                MIMETypeRef!.release()
                return MIMEType as String
            }
        }
        return nil
    }
}