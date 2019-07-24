//
//  HMTestViewController.swift
//  Weibo20
//
//  Created by HM on 16/9/19.
//  Copyright © 2016年 HM. All rights reserved.
//

import UIKit
//  测试进入的视图控制器
class HMTestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
     
        addNavRightButton()
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
