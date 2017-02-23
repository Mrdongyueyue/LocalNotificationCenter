//
//  AppDelegate.swift
//  Notification
//
//  Created by 董知樾 on 2017/2/21.
//  Copyright © 2017年 董知樾. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert , .badge , .sound ], completionHandler: { (agree, error) in
            if agree {
                
                // 用户允许进行通知
                
            }
        })
        
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        let action = UNTextInputNotificationAction(identifier: "action", title: "textAction", options: [.destructive], textInputButtonTitle: "send", textInputPlaceholder: "placeholder")
        let category1 = UNNotificationCategory(identifier: "category1", actions: [action], intentIdentifiers: ["action"], options: [.customDismissAction])
        
        let btnAction = UNNotificationAction(identifier: "btnAction", title: "btnAction", options: [.foreground])
        let category2 = UNNotificationCategory(identifier: "category2", actions: [btnAction], intentIdentifiers: ["btnAction"], options: [.customDismissAction])
        
        UNUserNotificationCenter.current().setNotificationCategories([category1, category2])
        
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1, repeats: false)
        let content = UNMutableNotificationContent()
        content.title = "main title"
        content.subtitle = "sub title"
        content.sound = UNNotificationSound.init(named: "phoneRing.mp3")
        content.body = "body"
        
        ///输入框的通知扩展
//        content.categoryIdentifier = "category1"
        ///按钮
        content.categoryIdentifier = "category2"
        
        do {
            
            let attachment1 = try UNNotificationAttachment.init(identifier: "attachment01", url: URL.init(fileURLWithPath: Bundle.main.path(forResource: "IU1", ofType: "jpeg")!), options: [UNNotificationAttachmentOptionsThumbnailTimeKey:"???"])
            content.attachments = [attachment1]
            
        } catch {
            
        }
        
        
        
        
        let request = UNNotificationRequest.init(identifier: "one", content: content, trigger: trigger)
        
        
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if error == nil {
                print("success")
            } else {
                print("failure \(error)")
            }
        }
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.isKind(of: UNTextInputNotificationResponse.classForCoder()) {
            let textResponse = response as! UNTextInputNotificationResponse
            let alert = UIAlertController(title: textResponse.userText, message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            window?.rootViewController?.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: response.actionIdentifier , message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
        
        
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert,.badge,.sound])
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


}

