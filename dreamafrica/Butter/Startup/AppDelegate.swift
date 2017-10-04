//
//  AppDelegate.swift
//  Butter
//
//  Created by DjinnGA on 23/07/2015.
//  Copyright (c) 2015 Butter Project. All rights reserved.
//

import UIKit
import Reachability
import FBSDKCoreKit
import FBSDKShareKit
import FBSDKLoginKit
import CleverSDK
import Braintree


let reuseIdentifier = "coverCell"
let movieCellIdentifier = "movieCell"
let TVCellIdentifier = "TVCell"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var reachability: Reachability?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Set default searchstring (empty)
        
        BTAppSwitch.setReturnURLScheme("com.pearldream.dreamafrica.payments")
        
        
        ButterAPIManager.sharedInstance.searchString = ""
        
        // Set tint color for application (used for back buttons)
        window?.tintColor = UIColor(red:0.37, green:0.41, blue:0.91, alpha:1.0)
        
        // Start reachability class to watch the users internet connection
        reachability = Reachability.forInternetConnection()
        reachability!.startNotifier()
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.reachabilityChanged(_:)), name: NSNotification.Name.reachabilityChanged, object: nil)
        
        let ud = UserDefaults.standard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginvc = storyboard.instantiateViewController(withIdentifier: "loginView") as! FacebookLoginViewConroller
        if (ud.bool(forKey: "loggedIn") == false) {
            loginvc.showLogin()
        } else if (ud.bool(forKey: "loggedIn") == true && ud.string(forKey: "facebookId") == nil) {
            loginvc.showLogin()
        }else
        {
            Payment.checkPaid()
        }
        
        ud.set(0, forKey: "numberWatched")
        
        // Start the CleverSDK with your clientID
        // Replace CLIENT_ID with your client ID
        CLVOAuthManager.start(withClientId: "f2df58c129473c7ef51d")
        print(CLVOAuthManager.redirectUri())
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
    }
    
    func reachabilityChanged(_ notification: Notification) {
        if !reachability!.isReachableViaWiFi() && !reachability!.isReachableViaWWAN() {
            DispatchQueue.main.async(execute: {
                let errorAlert = UIAlertController(title: "Oops..", message: "You are not connected to the internet anymore. Please make sure you have internet access", preferredStyle: UIAlertControllerStyle.alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in }))
                self.window?.rootViewController?.present(errorAlert, animated: true, completion: nil)
            })
        }
    }
	
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        print("###### URL - \(url)")
        if (url.scheme?.isEqual("clever-f2df58c129473c7ef51d"))!{
            return CLVOAuthManager.handle(url, sourceApplication: sourceApplication, annotation: annotation)
        }
        
        if url.scheme?.localizedCaseInsensitiveCompare("com.pearldream.dreamafrica.payments") == .orderedSame {
            return BTAppSwitch.handleOpen(url, sourceApplication: sourceApplication)
        }
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        if url.scheme?.localizedCaseInsensitiveCompare("com.your-company.Your-App.payments") == .orderedSame {
            return BTAppSwitch.handleOpen(url, options: options)
        }
        return false
    }
    
    
    
}

