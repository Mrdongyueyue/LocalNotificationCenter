//
//  NotificationViewController.swift
//  ContentExtension
//
//  Created by 董知樾 on 2017/4/5.
//  Copyright © 2017年 董知樾. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet var label: UILabel?
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    
    func didReceive(_ notification: UNNotification) {
        self.label?.text = notification.request.content.title
        if let url = notification.request.content.attachments.last?.url {
            print("\(String(describing: url))")
            if url.startAccessingSecurityScopedResource() {
                let image = UIImage(contentsOfFile: url.path)
                imageView.image = image
                
//                url.stopAccessingSecurityScopedResource()
            }
        }
        
        print(NSStringFromCGRect(view.frame))

    }
    
    func didReceive(_ response: UNNotificationResponse, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        if response.actionIdentifier == "sendAction" {//发送按钮
            let textResponse = response as! UNTextInputNotificationResponse
            
            completion(.dismiss)
        } else if response.actionIdentifier == "btnAction" {//按钮点击
            completion(.dismissAndForwardAction)
        } else {
            completion(.dismissAndForwardAction)
        }
    }
    

}
