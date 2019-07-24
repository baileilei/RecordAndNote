//
//  HMTabBar.swift
//  Weibo20
//
//  Created by HM on 16/9/19.
//  Copyright © 2016年 HM. All rights reserved.
//

import UIKit

//  定义代理协议
protocol HMTabBarDelegate: NSObjectProtocol {
    func didSelectedComposeButton()
}

//  自定义tabbar
class HMTabBar: UITabBar {
    //  点击撰写按钮执行的闭包
    var composeButtonClosure: (()->())?
    
    //  定义代理对象
    //  使用weak关键那么协议必须要继承NSObjectProtocol
    weak var hmDelegate: HMTabBarDelegate?
    
    //  MARK: --懒加载
    private lazy var composeButton: UIButton = {
        let button = UIButton()
        //  添加点击事件
        button.addTarget(self, action: #selector(composeButtonAction), for: .touchUpInside)
        
        //  设置图片
        button.setImage(UIImage(named: "tabbar_compose_icon_add"), for: .normal)
        button.setImage(UIImage(named: "tabbar_compose_icon_add_highlighted"), for: .highlighted)
        
        //  设置背景图片
        button.setBackgroundImage(UIImage(named: "tabbar_compose_button"), for: .normal)
        button.setBackgroundImage(UIImage(named: "tabbar_compose_button_highlighted"), for: .highlighted)
        
        //  设置大小
        button.sizeToFit()
        
        return button
    
    
    }()
    
    //  表示使用手写代码去创建对象
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    
    //  使用xib或者storyboard创建对象的时候会调用该方法, 提示为不支持xib创建
    required init?(coder aDecoder: NSCoder) {
        //  支持xib写法
        super.init(coder: aDecoder)
        setupUI()
    }
    
    //  添加控件的函数
    private func setupUI() {
        
        //  设置背景图片,防止push的右边出现黑色效果
        backgroundImage = UIImage(named: "tabbar_background")
        
        //  添加子视图控件
        addSubview(composeButton)
    }
    
    //  MARK: -- 点击事件
    //  private 修饰的这个事件函数,在swift运行循环里面是找不到
    //  oc基于运行时使用kvc动态派发调用该方法, @objc 告诉编译器我们使用oc机制去调用这个方法
    @objc private func composeButtonAction() {
        print("哈哈")
        
        //  执行闭包
        composeButtonClosure?()
        //  使用代理对象调用代理方法
        //  ? 表示判断前面的对象是否为nil,如果为nil那么后面的代码就不执行,否则执行后面的代码
        hmDelegate?.didSelectedComposeButton()
    }
    
    
    
    //  设置子控件位置
    override func layoutSubviews() {
        super.layoutSubviews()
        //  设置撰写按钮的中心点
        composeButton.centerX = width / 2
        composeButton.centerY = height / 2
        
        //  计算每项按钮的宽度
        let itemWidth = width / 5
        
        
        //  记录遍历到的是第几个系统按钮的索引
        var index = 0
        
        //  获取系统按钮的控件
        for value in subviews {
            
            //  找到我们关系的按钮, UITabBarButton系统的私有类,不能直接使用
            if value.isKind(of: NSClassFromString("UITabBarButton")!)  {
                value.width = itemWidth
                //  设置系统按钮的x坐标
                value.x = CGFloat(index) * itemWidth
                
                index += 1
                //  当前将要显示第三个系统按钮的时候让其多加上一个加号按钮的宽度
                if index == 2 {
                    index += 1
                }
                
            }
            
            
            
            
        }
        
        
        
        
    }
    
    
    

}
