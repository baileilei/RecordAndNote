//
//  HMDiscoverTableViewController.swift
//  Weibo20
//
//  Created by HM on 16/9/19.
//  Copyright © 2016年 HM. All rights reserved.
//

import UIKit

class HMDiscoverTableViewController: HMVisitorTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if isLogin {
            //  设置自定义titleView
            navigationItem.titleView = HMSearchView.searchView()
        } else {
        
            visitorView?.updateVisitorInfo(message: "登录后，最新、最热微博尽在掌握，不再会与实事潮流擦肩而过", imageName: "visitordiscover_image_message")
        }
       
        
        
    }
    
    

}
