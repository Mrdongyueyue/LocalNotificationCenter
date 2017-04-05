//
//  AppDelegate.swift
//  Notification
//
//  Created by 董知樾 on 2017/2/21.
//  Copyright © 2017年 董知樾. All rights reserved.
//
//Github地址:https://github.com/Mrdongyueyue/LocalNotificationCenter
import UIKit
import UserNotifications


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, JPUSHRegisterDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            if settings.authorizationStatus == .notDetermined {
                self.requestAuthorization(application)
            }
        }
        
        
        let action = UNTextInputNotificationAction(identifier: "action", title: "textAction", options: [.destructive], textInputButtonTitle: "send", textInputPlaceholder: "placeholder")
        let notificationTextInputCategory = UNNotificationCategory(identifier: "notificationTextInputCategory", actions: [action], intentIdentifiers: ["action"], options: [.customDismissAction])
        
        let btnAction = UNNotificationAction(identifier: "btnAction", title: "btnAction", options: [.foreground])
        let notificationButtonActionCategory = UNNotificationCategory(identifier: "notificationButtonActionCategory", actions: [btnAction], intentIdentifiers: ["btnAction"], options: [.customDismissAction])
        
        UNUserNotificationCenter.current().setNotificationCategories([notificationTextInputCategory, notificationButtonActionCategory])
        
        UNUserNotificationCenter.current().delegate = self
        
        let entity = JPUSHRegisterEntity()
        entity.types = Int(JPAuthorizationOptions.sound.rawValue | JPAuthorizationOptions.badge.rawValue | JPAuthorizationOptions.alert.rawValue)
        JPUSHService.register(forRemoteNotificationConfig: entity, delegate: self)
        JPUSHService.setup(withOption: launchOptions, appKey: "8cbbcb9ce2251a1b4291af4d", channel: "APP store", apsForProduction: false)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
        ///普通的通知
        UNUserNotificationCenter.current().add(timeIntervalNotificationRequest()) { (error) in
        ///固定时间的通知 类似闹钟的使用
//        UNUserNotificationCenter.current().add(calendarNotificationRequest()) { (error) in
            if error == nil {
                print("success")
            } else {
                print("failure \(String(describing: error))")
            }
        }
        
        
        
    }
    
    func requestAuthorization(_ application : UIApplication) -> Void {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert , .badge , .sound ], completionHandler: { (agree, error) in
            if agree {
                print("用户同意APP实用化通知权限")
            } else {
                let alert = UIAlertController(title: "你拒绝了通知发送申请", message: "可在设置中开启", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "确定", style: .`default`, handler: { (action) in
                    application.open(URL(string : UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: { (open) in
                        if open {
                            print("打开了设置页面")
                        } else {
                            print("设置页面打开失败")
                        }
                    })
                }))
                
                alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
                self.window?.rootViewController?.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    func timeIntervalNotificationRequest() -> UNNotificationRequest {
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1, repeats: false)
        let content = UNMutableNotificationContent()
        content.title = "main title"
        content.subtitle = "sub title"
        content.sound = UNNotificationSound.default()//init(named: "phoneRing.mp3")
        content.body = "body"
        
        ///输入框的通知扩展
        //        content.categoryIdentifier = "notificationTextInputCategory"
        ///按钮
        content.categoryIdentifier = "notificationButtonActionCategory"
        
        do {
            
            let attachment1 = try UNNotificationAttachment.init(identifier: "attachment01", url: URL.init(fileURLWithPath: Bundle.main.path(forResource: "IU1", ofType: "jpeg")!), options: [UNNotificationAttachmentOptionsThumbnailTimeKey:"???"])
            content.attachments = [attachment1]
            
        } catch {
            
        }
        
        
        return UNNotificationRequest.init(identifier: "one", content: content, trigger: trigger)
    }
    
    func calendarNotificationRequest() -> UNNotificationRequest {
        let calendar = Calendar.init(identifier: .chinese)
        let otherDC = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
        var dateComponents = DateComponents.init()
        let interval = 2
        //当时间每到这一秒的时候就会出现通知
        dateComponents.second = otherDC.second! > (60 - interval) ? interval : otherDC.second! + interval
        let trigger = UNCalendarNotificationTrigger.init(dateMatching:dateComponents , repeats: true)
        
        let content = UNMutableNotificationContent()
        content.title = "Hey, SB, wake up!!"
        content.subtitle = "Quickly!!!"
        content.sound = UNNotificationSound.default()//init(named: "phoneRing.mp3")
        content.body = "You'll be late!!"
        
        content.categoryIdentifier = "notificationButtonActionCategory"
        
        do {
            
            let attachment1 = try UNNotificationAttachment.init(identifier: "attachment01", url: URL.init(fileURLWithPath: Bundle.main.path(forResource: "IU1", ofType: "jpeg")!), options: [UNNotificationAttachmentOptionsThumbnailTimeKey:"???"])
            content.attachments = [attachment1]
            
        } catch {
            
        }
        
        return UNNotificationRequest.init(identifier: "two", content: content, trigger: trigger)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        JPUSHService.handleRemoteNotification(response.notification.request.content.userInfo)
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert,.badge,.sound])
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        JPUSHService.registerDeviceToken(deviceToken)
    }
    
    //MARK:~~~ JPUSHRegisterDelegate
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
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
    
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {
        print(notification.request.content.userInfo)
        completionHandler(Int(UNNotificationPresentationOptions.alert.rawValue))
    }
}

