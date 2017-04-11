/*
Copyright 2009-2017 Urban Airship Inc. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE URBAN AIRSHIP INC ``AS IS'' AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
EVENT SHALL URBAN AIRSHIP INC OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import UIKit
import AVFoundation
import AirshipKit

class PushHandler: NSObject, UAPushNotificationDelegate {

    func receivedBackgroundNotification(_ notificationContent: UANotificationContent, completionHandler: @escaping (UIBackgroundFetchResult) -> Swift.Void) {
        // Application received a background notification
        print("The application received a background notification");

        // Call the completion handler
        completionHandler(.noData)
    }

    func receivedForegroundNotification(_ notificationContent: UANotificationContent, completionHandler: @escaping () -> Swift.Void) {
        // Application received a foreground notification
        print("The application received a foreground notification");

        // iOS 10 - let foreground presentations options handle it
        if (ProcessInfo().isOperatingSystemAtLeast(OperatingSystemVersion(majorVersion: 10, minorVersion: 0, patchVersion: 0))) {
            completionHandler()
            return
        }

        // iOS 8 & 9 - show an alert dialog
        let alertController: UIAlertController = UIAlertController()
        alertController.title = notificationContent.alertTitle ?? NSLocalizedString("UA_Notification_Title", tableName: "UAPushUI", comment: "System Push Settings Label")
        alertController.message = notificationContent.alertBody

        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default){ (UIAlertAction) -> Void in

            // If we have a message ID run the display inbox action to fetch and display the message.
            let messageID = UAInboxUtils.inboxMessageID(fromNotification: notificationContent.notificationInfo)
            if (messageID != nil) {
                UAActionRunner.runAction(withName: kUADisplayInboxActionDefaultRegistryName, value: messageID, situation: UASituation.manualInvocation)
            }
        }

        alertController.addAction(okAction)


        let topController = UIApplication.shared.keyWindow!.rootViewController! as UIViewController
        alertController.popoverPresentationController?.sourceView = topController.view
        topController.present(alertController, animated:true, completion:nil)

        completionHandler()
    }

    func receivedNotificationResponse(_ notificationResponse: UANotificationResponse, completionHandler: @escaping () -> Swift.Void) {
        print("The user selected the following action identifier: \(notificationResponse.actionIdentifier)")

        // display an alert with the notification content and any response text
        let notificationContent = notificationResponse.notificationContent
        
        ///////////
    //    var window: UIWindow?
    //    var dictionary = [String:String]()
  //      dictionary   = (notificationContent as! [String : String]
//        for (key, value) in dictionary {
//            
//            if key == "^d" {
//                // do something with a deep link value here
//                print("Deep Link Found: \(value)")
//                let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//                let initialViewControlleripad : UIViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: "NewViewController") as! NewViewController
//                window = UIWindow(frame: UIScreen.main.bounds)
//                window?.rootViewController = initialViewControlleripad
//                window?.makeKeyAndVisible()
//
//            }
//        }
        
        //////////
        let alertTitle = notificationContent.alertTitle ?? NSLocalizedString("UA_Notification_Title", tableName: "UAPushUI", comment: "Notification Alert")
        
        var message = "Action Identifier:\n\(notificationResponse.actionIdentifier)"
        if let alertBody = notificationContent.alertBody {
            if !alertBody.isEmpty {
                message = "\(message)\nAlert Body:\n\(alertBody)"
            }
        }
        if let categoryIdentifier = notificationContent.categoryIdentifier {
            if !categoryIdentifier.isEmpty {
                message = "\(message)\nCategory Identifier:\n\(categoryIdentifier)"
            }
        }
        let responseText = notificationResponse.responseText
        if !responseText.isEmpty {
            message = "\(message)\nResponse:\n\(responseText)"
        }
        
        let alertController = UIAlertController(title: alertTitle, message: message, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title:"OK", style: UIAlertActionStyle.default)
        alertController.addAction(defaultAction)
        
        let topController = UIApplication.shared.keyWindow!.rootViewController! as UIViewController
        alertController.popoverPresentationController?.sourceView = topController.view
        topController.present(alertController, animated:true, completion:nil)
        
        completionHandler()
    }
    
    func launchedFromNotification(notification: [NSObject : AnyObject], fetchCompletionHandler completionHandler: ((UIBackgroundFetchResult) -> Void)) {
        NSLog("UALib: %@", "The application was launched or resumed from a notification: \(notification)");
        
        // Do something when launched via a notification
        
        for (key, value) in notification {
            
            if key as! String == "^d" {
                // do something with a deep link value here
                print("Deep Link Found: \(value)")
            }
        }
        
        completionHandler(UIBackgroundFetchResult.noData)
    }
    
    func receivedBackgroundNotification(notification: [NSObject : AnyObject], actionIdentifier identifier: String, completionHandler: () -> Void) {
        NSLog("UALib: %@", "The application was started in the background from a user notification button");
        
        /*
         Called when the app is launched/resumed by interacting with a notification button
         You can work with the notification object here
         */
        
        completionHandler()
    }
    
    func receivedBackgroundNotification(notification: [NSObject : AnyObject], fetchCompletionHandler completionHandler: ((UIBackgroundFetchResult) -> Void)) {
        NSLog("UALib: %@", "A CONTENT_AVAILABLE notification was received with the app in the background: \(notification)");
        /*
         Called when the app is in the background and a CONTENT_AVAILABLE notification is received
         Do something with the notification in the background
         
         Be sure to call the completion handler with a UIBackgroundFetchResult
         */
        completionHandler(UIBackgroundFetchResult.noData)
    }

    @available(iOS 10.0, *)
    func presentationOptions(for notification: UNNotification) -> UNNotificationPresentationOptions {
        return [.alert, .sound]
    }

}
