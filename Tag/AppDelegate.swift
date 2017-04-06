//
//  AppDelegate.swift
//  ChatApp
//
//  Created by Gavin Robertson on 1/23/17.
//  Copyright © 2017 Gavin Robertson. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import GooglePlaces
import GoogleMaps
import FBSDKCoreKit

extension UIViewController {
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
}



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FIRApp.configure()
        GMSPlacesClient.provideAPIKey("AIzaSyBP8Y5Nu5GhTtUFCxsO_AZxIV5pTVwI5Hw")
        GMSServices.provideAPIKey("AIzaSyBP8Y5Nu5GhTtUFCxsO_AZxIV5pTVwI5Hw")
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        
        
        //******* STYLING *******//
        
        let primaryColor = UIColor(red: 8/255, green: 28/255, blue: 156/255, alpha: 1.0) /* #081c9c */
        let secondaryColor = UIColor(red: 227/255, green: 201/255, blue: 0/255, alpha: 1.0)
        //let accentColor = UIColor(red: <#T##CGFloat#>, green: <#T##CGFloat#>, blue: <#T##CGFloat#>, alpha: <#T##CGFloat#>)
        
        //Navigation Bar color
        UINavigationBar.appearance().barTintColor = primaryColor
        
        
        //Search bar text color - for some reason when adding this like the "search" text moved up (out of center from the cursor.
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        
        //Nav Bar Title Color
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        //Navigation Back button color
        UINavigationBar.appearance().tintColor = secondaryColor
        
        //Nav Bar ItemButton color (items on nav bar other than back button
        UIBarButtonItem.appearance().tintColor = secondaryColor
        
        
        
        
        //***** END STYLING *****//
        
        
        
        
        return true
    }
    //    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
    //        return UIInterfaceOrientationMask(rawValue: UInt(checkOrientation(viewController: self.window?.rootViewController)))
    //    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask(rawValue: UInt(checkOrientation(viewController: self.window?.rootViewController)))
    }
    
    func checkOrientation(viewController:UIViewController?)-> Int{
        
        if(viewController == nil){
            
            return Int(UIInterfaceOrientationMask.all.rawValue)//All means all orientation
            
        }else {
            
            return Int(UIInterfaceOrientationMask.portrait.rawValue)
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String!, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        return handled;
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
}

//    func checkOrientation(viewController:UIViewController?)-> Int{
//
//        if(viewController == nil){
//
//            return Int(UIInterfaceOrientationMask.all.rawValue)//All means all orientation
//
//        }else {
//
//            return Int(UIInterfaceOrientationMask.portrait.rawValue)
//
//        }
//        //        else{
//        //
//        //            return checkOrientation(viewController: viewController!.presentedViewController)
//        //        }
//    }


}

