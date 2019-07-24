//
//  HMComposeButton.swift
//  Weibo20
//
//  Created by HM on 16/9/27.
//  Copyright © 2016年 HM. All rights reserved.
//

import UIKit
//  自定义撰写菜单按钮
class HMComposeButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //  使用pop动画需要把isHighlighted改成false
    override var isHighlighted: Bool {
        get {
            return false
        } set {
        
        }
    }
    
    
    private func setupUI() {
        titleLabel?.textAlignment = .center
        
        titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.setTitleColor(UIColor.gray, for: .normal)
        
        imageView?.contentMode = .center
    
    }
    
    
    
    //  调整子控件布局
    override func layoutSubviews() {
        super.layoutSubviews()
        //  设置图片的大小
        imageView?.width = width
        imageView?.height = width
        imageView?.y = 0
        //  设置文字label的大小
        titleLabel?.width = width
        titleLabel?.height = height - width
        //  设置titleLabel的y为imageview的高度
        titleLabel?.y = width
        titleLabel?.x = 0
    }
    

}
