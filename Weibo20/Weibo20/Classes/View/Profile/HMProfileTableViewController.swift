//
//  HMProfileTableViewController.swift
//  Weibo20
//
//  Created by HM on 16/9/19.
//  Copyright © 2016年 HM. All rights reserved.
//

import UIKit

class HMProfileTableViewController: HMVisitorTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if isLogin {
            addNavRightButton()
        } else {
            visitorView?.updateVisitorInfo(message: "登录后，你的微博、相册、个人资料会显示在这里，展示给别人", imageName: "visitordiscover_image_profile")
        }
        
    }
    
    private func addNavRightButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "push", target: self, action: #selector(pushAction))
    
    }
    
    //  点击事件
    func pushAction() -> Void {
        let testVc = HMTestViewController()
        navigationController?.pushViewController(testVc, animated: true)
        
        
    }
    
    
    
  
}
