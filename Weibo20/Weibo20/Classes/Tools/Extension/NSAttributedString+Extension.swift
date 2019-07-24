//
//  NSAttributedString+Extension.swift
//  Weibo20
//
//  Created by HM on 16/10/7.
//  Copyright © 2016年 HM. All rights reserved.
//

import UIKit

extension NSAttributedString {
    //  根据表情模型生成富文本对象
    static func attributedStringWithEmoticon(emoticon: HMEmoticon, font: UIFont) -> NSAttributedString {
        //  1. 根据表情路径创建UIImage对象
        let image = UIImage(named: emoticon.path!)
        //  2. 根据UIImage对象创建文本附件(NSTextAttachment)
        let attachment = HMTextAttachment()
        //  设置文本附件对应的表情模型
        attachment.emoticon = emoticon
        //  设置图片大小
        //  获取字体高度
    
        let lineHeight = font.lineHeight
        //  通过设置文本附件的bounds调整图片显示位置
        //  设置bounds会影响子控件的显示位置
        attachment.bounds = CGRect(x: 0, y: -4, width: lineHeight, height: lineHeight)
        attachment.image = image
        //  3. 根据文本附件创建富文本(NSAttributedString)
        let attributedStr = NSAttributedString(attachment: attachment)
        
        return attributedStr
    
    }

}
