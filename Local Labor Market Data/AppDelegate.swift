//
//  AppDelegate.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 7/2/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

#if false
        loadData()
#endif
        
        setupApprearance()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        CoreDataManager.shared().saveContext()
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if let rootViewController = self.topViewControllerWithRootViewController(rootViewController: window?.rootViewController) {
            if let orientationProtocol = rootViewController as? OrientationProtocol {
                return orientationProtocol.orientation
            }
        }

        // Only allow portrait (standard behaviour)
        return .portrait;
    }

    private func topViewControllerWithRootViewController(rootViewController: UIViewController!) -> UIViewController? {
        if (rootViewController == nil) { return nil }
        if (rootViewController is UITabBarController) {
            return topViewControllerWithRootViewController(rootViewController: (rootViewController as! UITabBarController).selectedViewController)
        } else if (rootViewController is UINavigationController) {
            return topViewControllerWithRootViewController(rootViewController: (rootViewController as! UINavigationController).visibleViewController)
        } else if (rootViewController.presentedViewController != nil) {
            return topViewControllerWithRootViewController(rootViewController: rootViewController.presentedViewController)
        } else if let splitViewController = rootViewController as? UISplitViewController {
            return topViewControllerWithRootViewController(rootViewController: splitViewController.viewControllers.last)
        }
        
        return rootViewController
    }
    
    func setupApprearance() {
//        UIApplication.shared.statusBarStyle = .lightContent
        UINavigationBar.appearance().barTintColor = UIColor(named: "AppColor")
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
    }
    
    func displayHome() {
        let searchVC = SearchViewController.instantiateFromStoryboard()
        let navVC = UINavigationController(rootViewController: searchVC)
        let splitVC = UISplitViewController()
        splitVC.viewControllers = [navVC]
        splitVC.delegate = searchVC
        splitVC.presentsWithGesture = false
        window?.rootViewController = splitVC
        window?.makeKeyAndVisible()
    }
    
    
    // This function loads the ZIP_COUNTY and ZIP_CBSA files in CoreData
    // This needs to be done, only if files have changed, before app release.
    // When releasingn th app, run this function to preload CoreData.
    // Copy the sqllite files in the bundle and release the app so that app is released with
    // preloaded data.
    func loadData() {
        let dataUtil = LoadDataUtil(managedContext: CoreDataManager.shared().viewManagedContext)
        dataUtil.loadZipCountyMap()
        dataUtil.loadZipNectaMap()
        dataUtil.loadZipCBSAMap()
        dataUtil.loadMSACountyMap()
        dataUtil.loadLAUSData()
        dataUtil.loadCESIndustries()
        dataUtil.loadOESOccupations()
        dataUtil.loadQCEWIndustries()
    }
}

