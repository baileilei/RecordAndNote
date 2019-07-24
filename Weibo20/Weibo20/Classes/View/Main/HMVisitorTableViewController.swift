//
//  HMVisitorTableViewController.swift
//  Weibo20
//
//  Created by HM on 16/9/20.
//  Copyright © 2016年 HM. All rights reserved.
//

import UIKit

class HMVisitorTableViewController: UITableViewController, HMVisitorViewDelegate {

    //  是否登录的标识
    var isLogin: Bool = HMUserAccountViewModel.sharedUserAccountViewModel.isLogin
    
    //  访客视图
    var visitorView: HMVisitorView?
    
    //  自定义view视图, 重写loadView是自定义控制器中的视图view
    override func loadView() {
        
        if isLogin {
            super.loadView()
        } else {
            //  自己提供一个视图
            visitorView = HMVisitorView()
            //  设置代理
            visitorView?.delegate = self
            //  设置闭包
            visitorView?.loginClosure = { [weak self] in
                
                print("我是访客视图闭包调用过来的")
                self?.requestLoginOperation()
                
            }
            
            view = visitorView
            
            //  未登录情况下执行添加导航栏按钮
            setupNavUI()
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    
    //  设置导航栏按钮
    private func setupNavUI() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "登录", target: self, action: #selector(loginAction))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "注册", target: self, action: #selector(loginAction))
    }
    
    
    //  MARK: -- 点击事件
    @objc private func loginAction() {
        print("你点击了登录操作")
        requestLoginOperation()
    
    }
    
    //  MARK:  --HMVisitorViewDelegate 实现代理方法
    func didSelectedLogin() {
        print("我是访客视图代理对象调用过来的")
    }
    
    //  请求登录的操作
    private func requestLoginOperation() {
        let oAuthVC = HMOAuthViewController()
        let nav = HMNavigationViewController(rootViewController: oAuthVC)
        present(nav, animated: true, completion: nil)
    
    }
    
    
    
    
    
    
}
