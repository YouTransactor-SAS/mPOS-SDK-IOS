//
//  AppDelegate.swift
//  uCubeSampleApp
//
//  Created by Rémi Hillairet on 5/21/20.
//  Copyright © 2020 YouTransactor. All rights reserved.
//

import UIKit
import UCube

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UCubeAPI.mdmSetHostname("mdm-dev.youtransactor.com") // DEV HOSTNAME
        return true
    }
}
