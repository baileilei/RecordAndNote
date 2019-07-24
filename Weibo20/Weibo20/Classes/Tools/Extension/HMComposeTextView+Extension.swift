//
//  HMComposeTextView+Extension.swift
//  Weibo20
//
//  Created by HM on 16/10/7.
//  Copyright © 2016年 HM. All rights reserved.
//

import UIKit

extension HMComposeTextView {
    //  通过富文本获取对应文本内容
    var emoticonText: String {
    
        var result = ""
        self.attributedText.enumerateAttributes(in: NSMakeRange(0, self.attributedText.length), options: []) { (info, range, _) in
            
            
            
            if let attachement = info["NSAttachment"] as? HMTextAttachment {
                //  能够获取文本附件表示是图片
                let chs = attachement.emoticon?.chs
                result += chs!
                
            } else {
                //  表示文本
                //  通过范围截取富文本对应的文本内容
                let text = self.attributedText.attributedSubstring(from: range).string
                result += text
            }
            
            
            
            
        }
        
        return result
    
    }
    
    
    //  根据表情模型设置富文本
    func insertEmoticon(emoticon: HMEmoticon)  {
        
        if emoticon.type == "0" {
            //  点击图片表情
            //            let chs = emoticon.chs!
            
            //            textView.insertText(chs)
            //  想要显示图片,需要设置富文本
            //  记录上一次富文本
            let lastAttbutedString = NSMutableAttributedString(attributedString: self.attributedText)
            //  图片转成富文本的流程
//            //  1. 根据表情路径创建UIImage对象
//            let image = UIImage(named: emoticon.path!)
//            //  2. 根据UIImage对象创建文本附件(NSTextAttachment)
//            let attachment = HMTextAttachment()
//            //  设置文本附件对应的表情模型
//            attachment.emoticon = emoticon
//            //  设置图片大小
//            //  获取字体高度
//            let lineHeight = self.font!.lineHeight
//            //  通过设置文本附件的bounds调整图片显示位置
//            //  设置bounds会影响子控件的显示位置
//            attachment.bounds = CGRect(x: 0, y: -4, width: lineHeight, height: lineHeight)
//            attachment.image = image
//            //  3. 根据文本附件创建富文本(NSAttributedString)
//            let attributedStr = NSAttributedString(attachment: attachment)
            //  以上代码已经抽取到NSAttributedString+Extension分类里面
            let attributedStr = NSAttributedString.attributedStringWithEmoticon(emoticon: emoticon, font: self.font!)
            //  添加这次点击的表情富文本
            //            lastAttbutedString.append(attributedStr)
            
            //  获取文本选中的范围
            var selectedRange = self.selectedRange
            //  根据指定的选中范围替换富文本
            lastAttbutedString.replaceCharacters(in: selectedRange, with: attributedStr)
            
            //  设置富文本的字体
            lastAttbutedString.addAttribute(NSFontAttributeName, value: self.font!, range: NSMakeRange(0, lastAttbutedString.length))
            
            //  4. 设置设置富文本
            self.attributedText = lastAttbutedString
            //  修改选中位置的光标,每次点击表情光标位置加1
            selectedRange.location += 1
            //  修改选中范围的长度为0
            selectedRange.length = 0
            
            //  设置textView的选中光标范围
            self.selectedRange = selectedRange
            
            //  发送文字改变的通知 (因为添加富文本系统不会发送文字改变的通知)
            NotificationCenter.default.post(name: NSNotification.Name.UITextViewTextDidChange, object: nil)
            //  同样代理方法需要自己调用
            //  ? 表示判断我们这个代理方法是否实现, 如果实现那么直接调用,否则返回nil
            //  ! 表示向对象保证我的代理方法一定实现了你去用吧
            self.delegate?.textViewDidChange?(self)
            
        } else {
            //  点击emoji标签
            let emoji = (emoticon.code! as NSString).emoji()
            self.insertText(emoji!)
        }
    }
}
