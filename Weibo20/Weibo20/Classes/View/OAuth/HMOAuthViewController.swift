//
//  HMOAuthViewController.swift
//  Weibo20
//
//  Created by HM on 16/9/20.
//  Copyright © 2016年 HM. All rights reserved.
//

import UIKit
import SVProgressHUD

//  第三方登录视图控制器
//  新浪开发平台提供的APPKey
let WeiboAppKey = "2707543009"
//  AppSecret 
let WeiboAppSecret = "975492f53ff3df657f0c435e935ef822"
//  授权回调页
let WeiboRedirect_Uri = "http://www.itcast.cn"

class HMOAuthViewController: UIViewController {
    //  MARK: -- 懒加载
    private lazy var webView: UIWebView = UIWebView()
    
    //  重写loadView, 目的把webView作为视图控制器的view
    override func loadView() {
        
        //  解决底部webView黑条
        //  改成透明解决黑条问题
        webView.isOpaque = false

        //  设置代理
        webView.delegate = self
        
        view = webView
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        requestLogin()
        setupNavUI()
       
    }
    
    //  请求第三方登录
    private func requestLogin() {
        //  准备url地址
        let url = "https://api.weibo.com/oauth2/authorize?client_id=\(WeiboAppKey)&redirect_uri=\(WeiboRedirect_Uri)"
        print(url)
        
        //  创建urlrequest对象
        let urlRequest = URLRequest(url: URL(string: url)!)
        
        webView.loadRequest(urlRequest)
        
        
        
    }
    
    //  设置导航栏按钮
    private func setupNavUI() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", target: self, action: #selector(cancelAction))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "自动填充", target: self, action: #selector(autoFillAction))
        title = "微博"
    }
    
    //  MARK: -- 点击事件处理
    @objc private func cancelAction() {
        //  点击取消的时候让等待指示器删除
        SVProgressHUD.dismiss()
        dismiss(animated: true, completion: nil)
    
    }
    
    @objc private func autoFillAction() {
    
        print("自动填充")
        
        
        //webView.stringByEvaluatingJavaScript(from: "document.getElementById('userId').value = 'hao123guohaibin@163.com';document.getElementById('passwd').value = 'guohaibin123'")
        
        webView.stringByEvaluatingJavaScript(from: "document.getElementById('userId').value = 'hao123guohaibin@163.com';document.getElementById('passwd').value = 'guohaibin123'")
        
        
    }
    
    //  代码已经抽取到HMUserAcccountViewModel
//    //  通过code获取accesstoken
//    func requestAccesstoken(code: String) {
//        
//        HMNetworkTools.sharedTools.requestAccessToken(code: code) { (response, error) in
//            if error != nil {
//                print("网络请求异常: \(error)")
//                return
//            }
//            
//            //  代码执行到此,网络请求成功
//            guard let dic = response as? [String: Any] else {
//                print("你是不是一个正确的字典格式")
//                return
//            }
//            
//            //  代码执行到此表示字典格式没有问题
//            let userAccount = HMUserAccount(dic: dic)
//            print(userAccount.access_token)
//            //  获取用户信息
//            self.requestUserInfo(userAccount: userAccount)
//        }
//        
//        
//    }
//    
//    //  根据accesskon和用户id获取用户信息
//    func requestUserInfo(userAccount: HMUserAccount) -> Void {
//        
//        HMNetworkTools.sharedTools.requestUserInfo(accessToken: userAccount.access_token!, uid: userAccount.uid) { (response, error) in
//            
//            if error != nil {
//                print("网络请求异常: \(error)")
//                return
//            }
//            
//            //  代码执行到此网络请求成功
//            guard let dic = response as? [String: Any] else {
//                print("你不是一个正确的字典")
//                return
//            }
//            
//            let name = dic["name"]
//            let profile_image_url = dic["profile_image_url"]
//            
//            
//            userAccount.name = name as? String
//            userAccount.profile_image_url = profile_image_url as? String
//            
//            
//            print(userAccount.name)
//            
//            //  代码执行到此,表示用户登录成功
//            userAccount.saveUserAccount()
//            
//            
//        }
//        
//        
//        
//    }

}

//  MARK: --UIWebViewDelegate
extension HMOAuthViewController: UIWebViewDelegate {
    
    //  开始加载请求
    func webViewDidStartLoad(_ webView: UIWebView) {
        SVProgressHUD.show()
    }
    //  加载完成
    func webViewDidFinishLoad(_ webView: UIWebView) {
        SVProgressHUD.dismiss()
    }
    
    //  加载失败
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        SVProgressHUD.dismiss()
    }
    
    //  将要加载请求
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        //  判断url是否合法
        guard let url = request.url else {
        
            print("url 为 nil")
            
            return false
        }
        
        print( url.absoluteString)
        
        if !url.absoluteString.hasPrefix(WeiboRedirect_Uri) {
            //  表示不是我们关心
            return true
        }
        
        //  代码执行到此表示是是我们关系的请求地址
        //  取到地址栏中的参数
        if let query = url.query , query.hasPrefix("code=") {
            //  根据光标的结束位置获取子串
            let code = query.substring(from: "code=".endIndex)
            //  通过code获取accesstoken
            //requestAccesstoken(code: code)
            
            
            HMUserAccountViewModel.sharedUserAccountViewModel.requestAccesstoken(code: code, callBack: { (isSuccess) in
                
                if isSuccess {
                    //  表示登录成功
                    print("登录成功")
                    //  要等到dismis完成以后在发送切换根视图控制器的操作
                    self.dismiss(animated: false, completion: {
                        //  进入欢迎页面
                        
                        NotificationCenter.default.post(name: NSNotification.Name(SwitchRootVCNotification), object: self)
                    })
                    
                    
                    
                    
                    
                    
                }
                
                
            })
            
            
            
        } else {
            //  取消授权
            dismiss(animated: true, completion: nil)
        }
        
        
        
        
        
        return false
        
    }
    
    
    
    
}











