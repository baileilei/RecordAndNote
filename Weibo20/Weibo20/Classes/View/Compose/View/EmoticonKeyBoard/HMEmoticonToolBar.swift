//
//  HMEmoticonToolBar.swift
//  Weibo20
//
//  Created by HM on 16/10/6.
//  Copyright © 2016年 HM. All rights reserved.
//

import UIKit

//  toolBar按钮的枚举类型

enum HMEmoticonToolBarButtonType: Int {
    //  最近
    case recent = 1000
    //  默认
    case normal = 1001
    //  emoji
    case emoji = 1002
    //  浪小花
    case lxh = 1003
}


//  自定义表情键盘的toolbar
class HMEmoticonToolBar: UIStackView {

    //  记录上次选中的按钮
    var lastSelectedButton: UIButton?
    //  点击按钮执行的闭包
    var callBack: ((HMEmoticonToolBarButtonType)->())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupUI() {
        //  设置布局方式
        axis = .horizontal
        //  设置子控件的填充方式
        distribution = .fillEqually
        
        addChildButton(title: "最近", imageName: "compose_emotion_table_left", type: .recent)
        addChildButton(title: "默认", imageName: "compose_emotion_table_mid", type: .normal)
        addChildButton(title: "Emoji", imageName: "compose_emotion_table_mid", type: .emoji)
        addChildButton(title: "浪小花", imageName: "compose_emotion_table_right", type: .lxh)
        
        
    }
    
    //  添加子按钮的方法
    private func addChildButton(title: String, imageName: String, type: HMEmoticonToolBarButtonType) {
        let button = UIButton()
        //  把枚举的原始值作为tag使用
        button.tag = type.rawValue
        button.addTarget(self, action: #selector(buttonAction(btn:)), for: .touchUpInside)
        button.setTitle(title, for: .normal)
        //  设置背景色
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitleColor(UIColor.darkGray, for: .selected)
        //  设置字体大小
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        //  设置背景图片
        button.setBackgroundImage(UIImage(named: imageName + "_normal"), for: .normal)
        button.setBackgroundImage(UIImage(named: imageName + "_selected"), for: .selected)
        //  去掉高亮
        button.adjustsImageWhenHighlighted = false
        //  添加按钮
        addArrangedSubview(button)
        //  默认选中默认表情这个按钮
        if type == .normal {
            lastSelectedButton?.isSelected = false
            button.isSelected = true
            lastSelectedButton = button
        }
    
    }
    
    //  MARK: --处理点击事件
    @objc private func buttonAction(btn: UIButton) {
        //  判断如果点击的按钮和上次选中按钮的一样,那么闭包不执行
        if lastSelectedButton == btn {
            return
        }
        
        
        lastSelectedButton?.isSelected = false
        btn.isSelected = true
        lastSelectedButton = btn
        //  根据枚举的原始值初始化枚举
        let type = HMEmoticonToolBarButtonType(rawValue: btn.tag)!
        
        //  执行闭包
        callBack?(type)
    
    }
    
    //  根据组数的索引选中相应的按钮
    func selectedButton(section: Int) {
        
        
        
        //  使用tag 0 表示取到的是当前视图自己
        let button = viewWithTag(section + 1000) as! UIButton
        
        if lastSelectedButton == button {
            return
        }
        
        
        lastSelectedButton?.isSelected = false
        button.isSelected = true
        lastSelectedButton = button
        print(section)
        
        
        
        
    }
    
    
    

}
