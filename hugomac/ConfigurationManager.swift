//
//  ConfigurationManager.swift
//  hugomac
//
//  Created by Nick O'Neill on 9/11/15.
//  Copyright © 2015 Launch Apps. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

final class ConfigurationManager {
    static let sharedInstance = ConfigurationManager()
    
    private let contentPathKey = DefaultsKey<String>("contentPath")
    var contentPath: String {
        get {
            return Defaults[contentPathKey]
        }
        set(newPath) {
            Defaults[contentPathKey] = newPath
        }
    }
    
    private let themePathKey = DefaultsKey<String>("themePath")
    var themePath: String {
        get {
            return Defaults[themePathKey]
        }
        set(newPath) {
            Defaults[themePathKey] = newPath
        }
    }
    
    private let siteURLKey = DefaultsKey<String>("siteURL")
    var siteURL: String {
        get {
            return Defaults[siteURLKey]
        }
        set(newURL) {
            Defaults[siteURLKey] = newURL
        }
    }
    
    private let siteTitleKey = DefaultsKey<String>("siteTitle")
    var siteTitle: String {
        get {
            return Defaults[siteTitleKey]
        }
        set(newTitle) {
            Defaults[siteTitleKey] = newTitle
        }
    }
}