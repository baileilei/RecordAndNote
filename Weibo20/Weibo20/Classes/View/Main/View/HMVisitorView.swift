//
//  HMVisitorView.swift
//  Weibo20
//
//  Created by HM on 16/9/20.
//  Copyright © 2016年 HM. All rights reserved.
//

import UIKit

//  定义代理协议
protocol HMVisitorViewDelegate: NSObjectProtocol {
    func didSelectedLogin()
}

//  访客视图
class HMVisitorView: UIView {
    
    //  需要传入执行的闭包
    var loginClosure: (() -> ())?
    
    //  定义代理对象
    weak var delegate: HMVisitorViewDelegate?
    
    //  MARK: - 懒加载控件
    //  旋转视图
    private lazy var cycleImageView: UIImageView = UIImageView(image: UIImage(named: "visitordiscover_feed_image_smallicon"))
    //  罩层
    private lazy var maskImageView: UIImageView = UIImageView(image: UIImage(named: "visitordiscover_feed_mask_smallicon"))

    //  主页
    private lazy var iconImageView: UIImageView = UIImageView(image: UIImage(named: "visitordiscover_feed_image_house"))
    
    //  未登录信息视图
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.text = "关注一些人，回这里看看有什么惊喜关注一些人，回这里看看有什么惊喜"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.darkGray
        //  居中
        label.textAlignment = .center
        //  多行显示
        label.numberOfLines = 0
        return label
    
    }()
    
    //  登录按钮
    private lazy var loginButton: UIButton = {
        let button = UIButton()
        //  添加点击事件
        button.addTarget(self, action: #selector(loginAction), for: .touchUpInside)
        button.setTitle("登录", for: .normal)
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.setTitleColor(UIColor.orange, for: .highlighted)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setBackgroundImage(UIImage(named: "common_button_white_disable"), for: .normal)
        //  去掉点击的高亮效果
        button.adjustsImageWhenHighlighted = false
        return button
    }()
    
    //  注册按钮
    //  登录按钮
    private lazy var registerButton: UIButton = {
        let button = UIButton()
        //  添加点击事件
        button.addTarget(self, action: #selector(loginAction), for: .touchUpInside)
        button.setTitle("注册", for: .normal)
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.setTitleColor(UIColor.orange, for: .highlighted)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setBackgroundImage(UIImage(named: "common_button_white_disable"), for: .normal)
        //  去掉点击的高亮效果
        button.adjustsImageWhenHighlighted = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        //  设置背景色
        backgroundColor = UIColor(white: 237 / 255, alpha: 1)
        
        addSubview(cycleImageView)
        addSubview(maskImageView)
        addSubview(iconImageView)
        addSubview(messageLabel)
        addSubview(loginButton)
        addSubview(registerButton)
        
        cycleImageView.snp_makeConstraints { (make) in
            make.center.equalTo(self)
        }
        
        maskImageView.snp_makeConstraints { (make) in
            make.center.equalTo(cycleImageView)
        }
        
        iconImageView.snp_makeConstraints { (make) in
            make.center.equalTo(cycleImageView)
        }
        
        messageLabel.snp_makeConstraints { (make) in
            make.centerX.equalTo(cycleImageView)
            make.top.equalTo(cycleImageView.snp_bottom)
            make.width.equalTo(224)
        }
        
        loginButton.snp_makeConstraints { (make) in
            make.leading.equalTo(messageLabel.snp_leading)
            make.top.equalTo(messageLabel.snp_bottom).offset(10)
            make.size.equalTo(CGSize(width: 100, height: 35))
        }
        
        registerButton.snp_makeConstraints { (make) in
            make.trailing.equalTo(messageLabel.snp_trailing)
            make.top.equalTo(loginButton)
            make.size.equalTo(loginButton)
        }
        
        
        
        
        //  使用系统自动布局
//        cycleImageView.translatesAutoresizingMaskIntoConstraints = false
        
//        //  设置布局方式
//        addConstraint(NSLayoutConstraint(item: cycleImageView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
//        
//        addConstraint(NSLayoutConstraint(item: cycleImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        
        
        
        
    
    }
    
    //  修饰访客视图信息
    func updateVisitorInfo(message: String?, imageName: String?) {
        
        if let msg = message, let imgName = imageName {
            //  如果代码执行到此,表示消息,发现,我的视图控制器
            messageLabel.text = msg
            iconImageView.image = UIImage(named: imgName)
            //  隐藏 swift 3.0改成isHidden
            cycleImageView.isHidden = true
        } else {
            //  代码执行到此,表示首页
            //  执行旋转动画
            startAnimation()
        }
        
        
       
        
        
    }
    
    //  开启动画
    private func startAnimation() {
        //  创建核心动画对象
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        //  执行到的目的地
        animation.toValue = 2 * M_PI
        //  动画执行的时长
        animation.duration = 20
        //  动画执行的次数
        animation.repeatCount = MAXFLOAT
        //  失去焦点让其不释放
        animation.isRemovedOnCompletion = false
        
        cycleImageView.layer.add(animation, forKey: nil)
        
    
    }
    
    //  MARK: -- 点击事件
    @objc private func loginAction() {
        
        print("我是访客视图点击的操作")
        //  执行闭包
        loginClosure?()
        
        //  通过代理对象执行代理方法
        delegate?.didSelectedLogin()
    
    }
    
    
    
    
  

}
