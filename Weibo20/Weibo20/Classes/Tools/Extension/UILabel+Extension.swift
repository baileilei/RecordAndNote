//
//  UILabel+Extension.swift
//  Weibo20
//
//  Created by HM on 16/9/23.
//  Copyright © 2016年 HM. All rights reserved.
//

import UIKit
//  给UILabel扩展一个便利构造函数
extension UILabel {
    
    convenience init(textColor: UIColor, fontSize: CGFloat) {
        //  使用当前self调用其他构造函数
        self.init()
        self.font = UIFont.systemFont(ofSize: fontSize)
        self.textColor = textColor
    
    }
    
    
    

}
