//
//  CommonTools.swift
//  Weibo20
//
//  Created by HM on 16/9/22.
//  Copyright © 2016年 HM. All rights reserved.
//

import UIKit

//  切换根视图控制器的通知名
let SwitchRootVCNotification = "SwitchRootVCNotification"
//  点击表情按钮的通知名
let DidSelectedEmoticonNotification = "DidSelectedEmoticonNotification"
//  点击删除标签的通知名
let DidSelectedDeleteEmoticonNotification = "DidSelectedDeleteEmoticonNotification"

//  屏幕的宽度
let ScreenWidth = UIScreen.main.bounds.size.width
//  屏幕的高度
let ScreenHeight = UIScreen.main.bounds.size.height


//  创建随机颜色的函数
func RandomColor() -> UIColor {
    //  产生随机的色值
    let red = arc4random() % 256
    let green = arc4random() % 256
    let blue = arc4random() % 256

    return UIColor(red: CGFloat(red) / 255, green: CGFloat(green) / 255, blue: CGFloat(blue) / 255, alpha: 1)
    
    
    
    

}
