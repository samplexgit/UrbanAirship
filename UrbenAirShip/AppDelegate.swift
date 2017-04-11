//
//  AppDelegate.swift
//  UrbenAirShip
//
//  Created by Shilp_m on 4/5/17.
//  Copyright © 2017 Photon. All rights reserved.
//

import UIKit
import AirshipKit
import Gimbal


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let pushHandler = PushHandler()
    var inboxDelegate: InboxDelegate?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UAirship.takeOff()
        UAirship.push().userPushNotificationsEnabled = true
        UAirship.push().defaultPresentationOptions = [.alert, .badge, .sound]
        //UAirship.push().tags = ["one", "two", "three"]
        UAirship.push().addTag("testtag")
        UAirship.push().updateRegistration()
        
        // Set the icon badge to zero on startup (optional)
        UAirship.push()?.resetBadge()
        
        // User notifications will not be enabled until userPushNotificationsEnabled is
        // enabled on UAPush. Once enabled, the setting will be persisted and the user
        // will be prompted to allow notifications. You should wait for a more appropriate
        // time to enable push to increase the likelihood that the user will accept
        // notifications.
        // UAirship.push()?.userPushNotificationsEnabled = true
        
        // Set a custom delegate for handling message center events
        self.inboxDelegate = InboxDelegate(rootViewController: (window?.rootViewController)!)
        UAirship.inbox().delegate = self.inboxDelegate
        UAirship.push().pushNotificationDelegate = pushHandler
        UAirship.push().registrationDelegate = self as? UARegistrationDelegate
        
        NotificationCenter.default.addObserver(self, selector:#selector(AppDelegate.refreshMessageCenterBadge), name: NSNotification.Name.UAInboxMessageListUpdated, object: nil)
        
       let channelID = UAirship.push().channelID
       print("My Application Channel ID: \(String(describing: channelID))")
        
       //Gimbal.start()
       UAirship.location().isLocationUpdatesEnabled = true
       UAirship.location().isBackgroundLocationUpdatesAllowed = true 
        return true
    }
    
    private func application(application: UIApplication, didReceiveRemoteNotification
        userInfo: [NSObject : AnyObject], fetchCompletionHandler
        completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let pushUtilUserInfo = userInfo
        print(pushUtilUserInfo)
        //pushUtilUserInfo["zendesk_sdk_request_id"] = userInfo["tid"]
        
//        ZDKPushUtil.handlePush(
//            pushUtilUserInfo,
//            for: application,
//            presentationStyle: .formSheet,
//            layoutGuide: ZDKLayoutRespectTop,
//            withAppId: "<your-app-id>",
//            zendeskUrl: "<your-zendesk-url>",
//            clientId: "<your-client-id>")
    }
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        print("my urlllllll",url)
        
        let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                      let initialViewControlleripad : UIViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: "NewViewController") as! NewViewController
                    window = UIWindow(frame: UIScreen.main.bounds)
                       window?.rootViewController = initialViewControlleripad
                       window?.makeKeyAndVisible()
        return true
    }
    func showInvalidConfigAlert() {
        let alertController = UIAlertController.init(title: "Invalid AirshipConfig.plist", message: "The AirshipConfig.plist must be a part of the app bundle and include a valid appkey and secret for the selected production level.", preferredStyle:.actionSheet)
        alertController.addAction(UIAlertAction.init(title: "Exit Application", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            exit(1)
        }))
        
        DispatchQueue.main.async {
            alertController.popoverPresentationController?.sourceView = self.window?.rootViewController?.view
            
            self.window?.rootViewController?.present(alertController, animated:true, completion: nil)
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        refreshMessageCenterBadge()
    }
    
    func refreshMessageCenterBadge() {
        
        if self.window?.rootViewController is UITabBarController {
            let messageCenterTab: UITabBarItem = (self.window!.rootViewController! as! UITabBarController).tabBar.items![2]
            
            if (UAirship.inbox().messageList.unreadCount > 0) {
                messageCenterTab.badgeValue = String(stringInterpolationSegment:UAirship.inbox().messageList.unreadCount)
            } else {
                messageCenterTab.badgeValue = nil
            }
        }
    }


    
   
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

