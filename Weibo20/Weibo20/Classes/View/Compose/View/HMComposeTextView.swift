//
//  HMComposeTextView.swift
//  Weibo20
//
//  Created by HM on 16/9/28.
//  Copyright © 2016年 HM. All rights reserved.
//

import UIKit

//  自定义UITextView
@IBDesignable
class HMComposeTextView: UITextView {
    //  占位label
    private lazy var placeHolderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "别低头,绿帽会掉~"
        label.textColor = UIColor.lightGray
        //  多行显示
        label.numberOfLines = 0
        return label
    }()
    
    //  提供设置占位文字属性
    @IBInspectable var placeHolder: String? {
        didSet {
            placeHolderLabel.text = placeHolder
        }
    }
    //  重写font属性
    override var font: UIFont? {
        didSet {
            if font != nil {
                placeHolderLabel.font = font
            }
        }
    }
    
    //  重写text属性
    override var text: String? {
        didSet {
            placeHolderLabel.isHidden = hasText
        }
    }

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        //  xib的写法
        super.init(coder: aDecoder)
        setupUI()
    }
    
    
    
    private func setupUI() {
        
        //  监听文字改变的通知
        //  系统的通知名需要使用NSNotification.Name.系统通知名
        NotificationCenter.default.addObserver(self, selector: #selector(textChange), name: NSNotification.Name.UITextViewTextDidChange, object: nil)
    
        
        addSubview(placeHolderLabel)
        //  使用手写代码方式进行autoLayout布局
        placeHolderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: placeHolderLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 5))
        
        addConstraint(NSLayoutConstraint(item: placeHolderLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 8))
        
        addConstraint(NSLayoutConstraint(item: placeHolderLabel, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: -10))
        
        
        
    }
    
    //  MARK: --    文本内容改变
    @objc private func textChange() {
        //  有内容隐藏掉,否则显示
        placeHolderLabel.isHidden = hasText
        
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
   

}
