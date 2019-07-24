//
//  HMMessageTableViewController.swift
//  Weibo20
//
//  Created by HM on 16/9/19.
//  Copyright © 2016年 HM. All rights reserved.
//

import UIKit

class HMMessageTableViewController: HMVisitorTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if !isLogin {
            
            visitorView?.updateVisitorInfo(message: "登录后，别人评论你的微博，发给你的消息，都会在这里收到通知", imageName: "visitordiscover_image_message")
            
        }
        
        
    }

}
