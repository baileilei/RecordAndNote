//
//  HMTextField.swift
//  Weibo20
//
//  Created by HM on 16/9/19.
//  Copyright © 2016年 HM. All rights reserved.
//

import UIKit
//  实时看到xib设置后的效果
@IBDesignable
class HMTextField: UITextField {

    //  提供borderColor, 边框颜色
    //  @IBInspectable给xib提供设置属性
    @IBInspectable var borderColor: UIColor? {
        didSet {
            //  外界设置borderColor的时候会调用didSet方法
            self.layer.borderColor = borderColor?.cgColor
        }
    }
    //  设置边框的宽度
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    //  设置边框弧度
    @IBInspectable var cornerRadius: CGFloat = 0 {
    
        didSet {
            self.layer.cornerRadius = cornerRadius
            self.layer.masksToBounds = true
        }
    }
    

}
