//
//  HMNavigationViewController.swift
//  Weibo20
//
//  Created by HM on 16/9/19.
//  Copyright © 2016年 HM. All rights reserved.
//

import UIKit

class HMNavigationViewController: UINavigationController, UIGestureRecognizerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        //  设置边缘手势代理
        self.interactivePopGestureRecognizer?.delegate = self
        
    }
    
    //  重写该方法监听push的子视图控制及导航视图控制器里面有几个子视图控制器
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        
        
        //  获取导航控制器里面的子视图控制器
        print(viewControllers.count)
        //  如果个数大于0表示不是根视图控制器
        if viewControllers.count > 0 {
            //  表示当前是第二个视图控制器
            if viewControllers.count == 1 {
                
                //  获取上一级控制的title
                let title = viewControllers.first!.title!
                
                viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: title, imageName: "navigationbar_back_withtext", target: self, action: #selector(backAction))
                
                
                
                
            } else {
                
                viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "返回", imageName: "navigationbar_back_withtext", target: self, action: #selector(backAction))
                
                
            }
            
            viewController.title = "当前显示的第\(viewControllers.count + 1)级控制器"
            //  隐藏底部tabbar
            viewController.hidesBottomBarWhenPushed = true
            
        }
        
        
        
        super.pushViewController(viewController, animated: animated)
        
    }
    
    
    func backAction()  {
       
        popViewController(animated: true)
        
        
    }
    
    //  是否处理这次开始点击的手势
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        //  如果是根视图控制器的话,不处理边缘手势
        if viewControllers.count == 1 {
            return false
        }
        
        
        return true
    }
    
    
    

    

}
