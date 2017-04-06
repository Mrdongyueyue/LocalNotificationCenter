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
        // Do any required interface initialization here.
        
//        imageViewHeight = imageView.widthAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1)
//        NSLayoutConstraint.activate([imageViewHeight])
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
//        do {
//            let data = try Data.init(contentsOf: (notification.request.content.attachments.last?.url)!)
//            imageView.image = UIImage(data: data)
//            
//        } catch {
//        }
//        if let path = Bundle.main.path(forResource: "smile", ofType: "jpg") {
//            imageView.image = UIImage(contentsOfFile: path)
//        }
    }
    
    

}
