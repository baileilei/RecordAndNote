//
//  UIBarButtonItem+Extension.swift
//  Weibo20
//
//  Created by HM on 16/9/19.
//  Copyright © 2016年 HM. All rights reserved.
//

import UIKit

//  给UIBarButtonItem扩展一个便利构造函数来创建对象
extension UIBarButtonItem {

    //  给其设置默认参数,意思如果外界不传入参数,那么使用默认值,如果设置参数使用传入的参数
    convenience init(title: String, imageName: String? = nil,  target: Any?, action: Selector) {
        //  使用self调用其他构造函数
        self.init()
        
        
        let button = UIButton()
        
        if imageName != nil {
            //  设置图片
            button.setImage(UIImage(named: imageName!), for: .normal)
        }
        
        //  添加点击事件
        button.addTarget(target, action: action, for: .touchUpInside)
        button.setTitle(title, for: .normal)
        //  设置文字颜色
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.setTitleColor(UIColor.orange, for: .highlighted)
        //  设置字体大小
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.sizeToFit()
        
        customView = button
        
        
    }

    
    
}
