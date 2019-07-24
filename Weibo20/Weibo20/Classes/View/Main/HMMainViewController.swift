//
//  HMMainViewController.swift
//  Weibo20
//
//  Created by HM on 16/9/19.
//  Copyright © 2016年 HM. All rights reserved.
//

import UIKit
import SVProgressHUD

class HMMainViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //  设置tintColor -> 统一设置tabbar的选中颜色
        //  越早执行越好,一般会Appdelegate里面
        //UITabBar.appearance().tintColor = UIColor.orange

        //  添加子视图控制器
        //  2种方式
        //viewControllers  = []
        
        //addChildViewController(UIViewController)
        
        
        //  使用kvc方式给oc中的类设置只读属性的值
        
        let hmTabBar = HMTabBar()
        //  设置代理对象
        hmTabBar.hmDelegate = self
        
        
        //  在此使用self会产生循环引用, 解决办法使用[weak self]
        hmTabBar.composeButtonClosure = { [weak self] in
            
//            print(self)
            print("我是闭包调用过来的")
            
            if !HMUserAccountViewModel.sharedUserAccountViewModel.isLogin {
                SVProgressHUD.showError(withStatus: "请先登录, 亲~")
                return
            }
            
            if let target = self {
                //  代码执行到此表示已经登录
                let composeView = HMComposeView()
                composeView.show(target: target)

            }
            
        
        }
        
        
        
        setValue(hmTabBar, forKey: "tabBar")
        
        
//        self.tabBar = HMTabBar()
        
        
        //  添加子视图控制器
        addChildViewController(childController: HMHomeTableViewController(), title: "首页", imageName: "tabbar_home")
        addChildViewController(childController: HMMessageTableViewController(), title: "消息", imageName: "tabbar_message_center")
        addChildViewController(childController: HMDiscoverTableViewController(), title: "发现", imageName: "tabbar_discover")
        addChildViewController(childController: HMProfileTableViewController(), title: "我的", imageName: "tabbar_profile")
        
        
        
    }
    
    // 添加子视图控制器的方法重载
    func addChildViewController(childController: UIViewController, title: String, imageName: String) {
        
        
//        if title == "我的"{
//            //  设置image的位置
//            childController.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
//            
//        
//        } else {
//            //        childController.tabBarItem.title = title
//            //        childController.navigationItem.title = title
//            //  合并成一句代码显示标题
//            childController.title = title
//        }
        
        
        //  设置tabbarItem的图片和文字
        childController.tabBarItem.image = UIImage(named: imageName)
        //  修改图片的渲染方式
        childController.tabBarItem.selectedImage = UIImage(named: "\(imageName)_selected")?.withRenderingMode(.alwaysOriginal)
        //  设置文字选中的颜色
        childController.tabBarItem.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.orange], for: .selected)
        //  设置文字大小
        childController.tabBarItem.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 14)], for: .normal)
        
//                childController.tabBarItem.title = title
//                childController.navigationItem.title = title
        //  合并成一句代码显示标题
        childController.title = title
        
        //  创建导航视图控制器
        let nav = HMNavigationViewController(rootViewController: childController)
        
        
        //  添加子视图控制器
        addChildViewController(nav)
        
        
    }
    
    

   

}
//  使用extension可以实现代理方法
extension HMMainViewController: HMTabBarDelegate {
    
    func didSelectedComposeButton() {
        print("我是代理对象调用过来的")
    }
    
}












