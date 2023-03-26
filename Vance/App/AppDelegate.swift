//
//  AppDelegate.swift
//  Vance
//
//  Created by Egor Molchanov on 14.09.2022.
//  Copyright © 2022 Egor and the fucked up. All rights reserved.
//

import UIKit
import Python
import PythonKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func applicationDidFinishLaunching(_ application: UIApplication) {
        guard let stdLibPath = Bundle.main.path(forResource: "python-stdlib", ofType: nil) else { return }
        guard let libDynloadPath = Bundle.main.path(forResource: "python-stdlib/lib-dynload", ofType: nil) else { return }
        guard let ytdlpPath = Bundle.main.path(forResource: "PythonModules", ofType: nil) else { return }
        
        setenv("PYTHONHOME", stdLibPath, 1)
        setenv("PYTHONPATH", "\(stdLibPath):\(libDynloadPath):\(ytdlpPath)", 1)
        
        guard let cache = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
            return
        }
        let vanceCache = cache.appendingPathComponent("net.prismade.Vance")
        try? FileManager.default.createDirectory(at: vanceCache, withIntermediateDirectories: false)
        setenv("XDG_CACHE_HOME", vanceCache.path, 1)
        
        guard let applicationSupport = try? FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
            return
        }
        let vanceApplicationSupport = applicationSupport.appendingPathComponent("net.prismade.Vance")
        try? FileManager.default.createDirectory(at: vanceApplicationSupport, withIntermediateDirectories: false)
        setenv("XDG_CONFIG_HOME", vanceApplicationSupport.path, 1)
        
        Py_Initialize()
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

