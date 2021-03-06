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
import SwiftyJSON

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
        
        if let mapboxToken = Keys.sharedInstance().mapboxToken {
            MGLAccountManager.setAccessToken(mapboxToken)
        }
        
        // Making status bar white
        application.statusBarStyle = UIStatusBarStyle.LightContent
        
        let status = Permissions.systemStatusForNotifications()
        if status == .Allowed {
            Permissions.registerForNotificationsPermission()
        }
        else {
            if let user = User.currentUser() {
                user.setValue(false, forKey: "pushEnabled")
                user.saveEventually()
            }
        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.

        
        //Check if user has denied notifications; save 'pushEnabled' to false if so
        let status = Permissions.systemStatusForNotifications()
        if status == .Denied {
            if let user = User.currentUser() {
                user.setValue(false, forKey: "pushEnabled")
                user.saveEventually()
            }
        }
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
        let localNotification = NSNotification(name: "showPendingAlertsIfNeeded", object: nil, userInfo: nil)
        NSNotificationCenter.defaultCenter().postNotification(localNotification)
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: Notifications -
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        // Store the deviceToken in the current Installation and save it to Parse
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        if let user = User.currentUser() {
            installation.setValue(user, forKey: "user")
            user.setValue(true, forKey: "pushEnabled")
            user.saveEventually()
        }
        installation.saveEventually()
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        // TODO: log it?
        print(error.localizedDescription)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        print("Received a remote notification")

        if application.applicationState == .Active {
            postLocalNotification(userInfo)
        }
        else {
            handleNotification(userInfo, isRemote: true)
        }
        
        // Calling the completion handler to dismiss the associated warning - not sure if we need to do more than this.
        completionHandler(UIBackgroundFetchResult.NewData)
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
        if isRemote {
            print("Notification is remote")
            // use the given keys to get the localized strings and
            // schedule an immediate local user notification with that text
            scheduleLocalUserNotification(dictionary)
        }
        else {
            print("Notification is local")
            // show the related context to the notification
        }
    }
    
    func postLocalNotification(dictionary: [ NSObject : AnyObject ]) {
        let localNotification = NSNotification(name: "pushNotificationReceived", object: nil, userInfo: dictionary)
        NSNotificationCenter.defaultCenter().postNotification(localNotification)
    }
    
    func scheduleLocalUserNotification(dictionary: [ NSObject : AnyObject]) {
        print("Scheduling a notification")
        let json = JSON(dictionary)
        let message = NotificationHelper.localizeNotificationMessage(json)
        let localNotification = UILocalNotification()
        localNotification.alertBody = message
        localNotification.fireDate = NSDate()
        localNotification.category = "Alerts"
        localNotification.userInfo = ["data" : "TBD"]
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        
        //Also posting a local notification so that the alert will appear when the app opens...
        postLocalNotification(dictionary)
    }

}
