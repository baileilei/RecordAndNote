//
//  AppDelegate.swift
//  Weibo20
//
//  Created by HM on 16/9/19.
//  Copyright © 2016年 HM. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        
//        //  从沙盒里面获取用户对象
//        let userAccount = HMUserAccount.loadUserAccount()
//        print(userAccount)

        //  监听切换根视图控制器的通知
        NotificationCenter.default.addObserver(self, selector: #selector(switchRootVC(noti:)), name: NSNotification.Name(SwitchRootVCNotification), object: nil)
       
        
        
        //  1. 创建window
        window = UIWindow(frame: UIScreen.main.bounds)
        //  2. 创建根视图控制器
        let rootVc = HMMainViewController()
        //  3. 设置window的根视图控制器
        window?.rootViewController = rootVc
        //  4. 设置为主window并显示
        window?.makeKeyAndVisible()
        
        
        
        
        return true
    }
    
    //  处理监听通过的函数
    @objc private func switchRootVC(noti: Notification) {
    
        let vc = noti.object
        
        
        if vc is HMOAuthViewController {
            window?.rootViewController = HMWelcomeViewController()
        } else {
            window?.rootViewController = HMMainViewController()
        }
        
        
        
      
        
    
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        //  进行后台
        HMStatusDAL.clearCacheData()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

