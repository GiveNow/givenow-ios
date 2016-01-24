//
//  AppDelegate.swift
//  GiveNow
//
//  Created by Brennan Stehling on 12/16/15.
//  Copyright © 2015 GiveNow. All rights reserved.
//

import UIKit
import Parse
import Mapbox
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // Initialize Parse
        if let parseApplicationId = Keys.sharedInstance().parseApplicationId,
            let parseClientKey = Keys.sharedInstance().parseClientKey {
                Parse.registerSubclasses()
                Parse.setApplicationId(parseApplicationId, clientKey: parseClientKey)
                PFUser.enableAutomaticUser()
        }
        
        // MapBox
        if let mapboxToken = Keys.sharedInstance().mapboxToken {
            MGLAccountManager.setAccessToken(mapboxToken)
        }
        
        // Crashlytics
        Fabric.with([MGLAccountManager.self, Crashlytics.self])
        Backend.sharedInstance().logUserForCrashlytics()
        
        // Making status bar white
        application.statusBarStyle = UIStatusBarStyle.LightContent
        
        let status = Permissions.systemStatusForNotifications()
        if status == .Allowed {
            Permissions.registerForNotificationsPermission()
        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: Notifications -
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        // Store the deviceToken in the current Installation and save it to Parse
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveEventually()
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        // TODO: log it?
        print(error.localizedDescription)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        handleNotification(userInfo, isRemote: true)
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        guard let userInfo = notification.userInfo else {
            // do nothing
            assert(false)
            return
        }
        
        handleNotification(userInfo, isRemote: false)
    }
    
    // MARK: Private -
    
    func handleNotification(dictionary : [ NSObject : AnyObject ], isRemote : Bool) {
        // TODO: implement
        
        print(dictionary)
        
        if isRemote {
            // use the given keys to get the localized strings and
            // schedule an immediate local user notification with that text
            scheduleLocalUserNotification("Test Notification for GiveNow")
        }
        else {
            // show the related context to the notification
        }
    }
    
    func scheduleLocalUserNotification(text : String) {
        let localNotification = UILocalNotification()
        localNotification.alertBody = text
        localNotification.fireDate = NSDate()
        localNotification.category = "Alerts"
        localNotification.userInfo = ["data" : "TBD"]
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }

}
