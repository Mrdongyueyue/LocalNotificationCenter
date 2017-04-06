//
//  NotificationService.swift
//  ServiceExtension
//
//  Created by 董知樾 on 2017/4/5.
//  Copyright © 2017年 董知樾. All rights reserved.
//

import UserNotifications
import UIKit

class NotificationService: UNNotificationServiceExtension, URLSessionDelegate {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            
            if let task = configNotificationContent(bestAttemptContent) {
                task.resume()
            } else {
                contentHandler(bestAttemptContent)
            }
            
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        print("serviceExtensionTimeWillExpire")
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
    func configNotificationContent(_ content : UNMutableNotificationContent) -> URLSessionTask?{
        
        print(content)
        let aps : NSDictionary = content.userInfo["aps"] as! NSDictionary
        if let category : NSString = aps["category"] as? NSString {
            if category.isEqual(to: "notificationButtonActionCategory") {
                content.categoryIdentifier = category as String
            } else if category.isEqual(to: "notificationTextInputCategory") {
                content.categoryIdentifier = category as String
            }
        }
        
        if content.title.isEqual("哈哈哈") {
            do {
                let url = URL(fileURLWithPath: Bundle.main.path(forResource: "smile", ofType: "jpg")!)
                
                let attachment = try UNNotificationAttachment(identifier: "smile", url: url, options: [UNNotificationAttachmentOptionsThumbnailTimeKey:"???"])
                content.attachments = [attachment]
            } catch  {
                
            }
            return nil
        }
        
        
        if let remoteImageUrl : NSString = content.userInfo["remoteImageUrl"] as? NSString {
            let url = URL(string: remoteImageUrl as String)
            let configuration = URLSessionConfiguration.default
            let session = URLSession(configuration: configuration)
            
            let task = session.dataTask(with: url!, completionHandler: { (data, response, error) in
                
                var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first?.appending("/remoteImage")
                let fileManager = FileManager.default
                if !(path?.isEmpty)!, !fileManager.fileExists(atPath: path!) {
                    print("没有文件夹～～～～")
                    do {
                        try fileManager.createDirectory(atPath: path!, withIntermediateDirectories: true, attributes: nil)
                        print("创建文件夹成功！！！！")
                    } catch let attError as Error {
                        print("创建文件夹失败～～～～\(attError.localizedDescription)")
                    }
                }
                let fileName = String(format: "%d.jpg", Date().timeIntervalSince1970 * 1000)
                path = path?.appending(fileName)
                
                if !(data?.isEmpty)!, let image = UIImage(data: data!) {
                    do {
                        try UIImageJPEGRepresentation(image, 1)?.write(to: URL(fileURLWithPath: path!))
                        print("写入图片成功！！！！")
                    } catch let attError as Error {
                        print("写入图片失败～～～～\(attError.localizedDescription)")
                    }
                }
                
                do {
                    
                    let url = URL(fileURLWithPath: path!,isDirectory: true)
                    
                    let attachment = try UNNotificationAttachment(identifier: "remoteImage", url: url, options: [UNNotificationAttachmentOptionsThumbnailTimeKey:"???"])
                    content.attachments = [attachment]
                    print("添加附件成功！！！！")
                } catch let attError as Error {
                    print("添加附件失败～～～～\(attError.localizedDescription)")
                }
                print(path ?? "")
                self.contentHandler!(content)
            })
            
            return task
        }
        
        return nil
    }

}
