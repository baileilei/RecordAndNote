//
//  HMComposeToolBar.swift
//  Weibo20
//
//  Created by HM on 16/9/28.
//  Copyright © 2016年 HM. All rights reserved.
//

import UIKit

enum HMComposeToolBarButtonType: Int {
    //  图片
    case picture = 0
    // @
    case mention = 1
    // #
    case trend = 2
    //  表情
    case emoticon = 3
    //  加号
    case add = 4
}


//  只是一个容器控件,不具备渲染效果
class HMComposeToolBar: UIStackView {
    //  闭包的回调
    var callBack: ((HMComposeToolBarButtonType)->())?
    //  表情按钮
    var emotcionButton: UIButton?
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        //  水平布局
        axis = .horizontal
        //  子控件的填充方式
        distribution = .fillEqually
        
        backgroundColor = UIColor.yellow
        addChildButton(imageName: "compose_toolbar_picture", type: .picture)
        addChildButton(imageName: "compose_mentionbutton_background", type: .mention)
        addChildButton(imageName: "compose_trendbutton_background", type: .trend)
        emotcionButton = addChildButton(imageName: "compose_emoticonbutton_background", type: .emoticon)
        addChildButton(imageName: "compose_add_background", type: .add)
    }
    
    //  添加子控件
    @discardableResult //   可以忽略返回值的不关心返回结果
    private func addChildButton(imageName: String, type: HMComposeToolBarButtonType) -> UIButton {
        let button = UIButton()
        //  枚举值设置为tag, rawValue 表示枚举的原始值对应后面的等号数字
        button.tag = type.rawValue
        button.addTarget(self, action: #selector(btnAction(btn:)), for: .touchUpInside)
        button.setImage(UIImage(named: "\(imageName)"), for: .normal)
        button.setImage(UIImage(named: "\(imageName)_highlighted"), for: .highlighted)
        button.setBackgroundImage(UIImage(named: "compose_toolbar_background"), for: .normal)
        //  去掉高亮效果
        button.adjustsImageWhenHighlighted = false
        //  添加子控件使用
        addArrangedSubview(button)
        return button
    }
    
    //  MARK: --    点击事件
    @objc private func btnAction(btn: UIButton) {
        //  根据枚举的原值创建枚举
        let type = HMComposeToolBarButtonType(rawValue: btn.tag)!
        
        callBack?(type)
        
    
    }
    
    //  根据表情键盘类型显示不同的icon
    func showIcon(isEmoticon: Bool) {
        //  如果是表情键盘那么显示系统icon
        if isEmoticon {
            emotcionButton?.setImage(UIImage(named: "compose_keyboardbutton_background"), for: .normal)
            emotcionButton?.setImage(UIImage(named: "compose_keyboardbutton_background_highlighted"), for: .highlighted)
        } else {
            //  如果是系统键盘那么显示表情icon
            emotcionButton?.setImage(UIImage(named: "compose_emoticonbutton_background"), for: .normal)
            emotcionButton?.setImage(UIImage(named: "compose_emoticonbutton_background_highlighted"), for: .highlighted)
        }
        
        
        
        
        
    }
    

}
