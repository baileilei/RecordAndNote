//
//  HMUserAccountViewModel.swift
//  Weibo20
//
//  Created by HM on 16/9/22.
//  Copyright © 2016年 HM. All rights reserved.
//

import UIKit
//  封装授权页面的网络请求 -> 对应的视图是HMOAuthViewController
class HMUserAccountViewModel: NSObject {
    
    //  单例全局访问点, -> 用户模型对象全局共享
    static let sharedUserAccountViewModel: HMUserAccountViewModel = HMUserAccountViewModel()
    
    
    //  用户归档用户对象
    var userAccount: HMUserAccount? {
        //  从沙盒路径里面获取
        return HMUserAccount.loadUserAccount()
    }
    
    //  判断是登录操作
    var isLogin: Bool {
    
        return accessToken != nil
        
        
    }
    
    //  判断Accesstoken是否过期
    var accessToken: String? {
        
        //  1. 获取HMUserAccount里面的access_token这个属性
        
        let token = userAccount?.access_token
        
        //  2. 获取过期时间对象
        
        let expiresDate = userAccount?.expiresDate
        
        //  如果token存在, 判断Accesstoken是否过期
        
        if let t = token {
            //  表示Accesstoken不为nil
            
            if expiresDate?.compare(Date()) == .orderedDescending {
                //  如果过期时间大于我们当前时间结果是降序方式
                return t
                
            } else {
                //  过期了直接返回nil
                return nil
            }
            
        } else {
            return nil
        }
    
    }
    
    
    
    
    
    //  通过code获取accesstoken
    func requestAccesstoken(code: String, callBack: @escaping (Bool)->()) {
        
        HMNetworkTools.sharedTools.requestAccessToken(code: code) { (response, error) in
            if error != nil {
                print("网络请求异常: \(error)")
                callBack(false)
                return
            }
            
            //  代码执行到此,网络请求成功
            guard let dic = response as? [String: Any] else {
                print("你是不是一个正确的字典格式")
                callBack(false)
                return
            }
            
            //  代码执行到此表示字典格式没有问题
            let userAccount = HMUserAccount(dic: dic)
            print(userAccount.access_token)
            //  获取用户信息
            self.requestUserInfo(userAccount: userAccount, callBack: callBack)
           
        }
        
        
    }
    
    //  根据accesskon和用户id获取用户信息
    private func requestUserInfo(userAccount: HMUserAccount, callBack: @escaping (Bool)->()) -> Void {
        
        HMNetworkTools.sharedTools.requestUserInfo(accessToken: userAccount.access_token!, uid: userAccount.uid) { (response, error) in
            
            if error != nil {
                print("网络请求异常: \(error)")
                callBack(false)
                return
            }
            
            //  代码执行到此网络请求成功
            guard let dic = response as? [String: Any] else {
                print("你不是一个正确的字典")
                callBack(false)
                return
            }
            
            let name = dic["name"]
            let avatar_large = dic["avatar_large"]
            
            
            userAccount.name = name as? String
            userAccount.avatar_large = avatar_large as? String
            
            
            print(userAccount.name)
            
            //  代码执行到此,表示用户登录成功
            userAccount.saveUserAccount()
            
            //  登录成功
            callBack(true)
            
        }
        
        
        
    }
    
    
    
    
    
    
    

}
