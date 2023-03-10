//
//  AppDelegate.swift
//  dropper
//
//  Created by Andrew Tokeley on 19/02/23.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Open first view
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let module = AppModules.game.build()
        module.router.show(inWindow: self.window, embedInNavController: false, setupData: nil, makeKeyAndVisible: true)

        return true
    }
}

