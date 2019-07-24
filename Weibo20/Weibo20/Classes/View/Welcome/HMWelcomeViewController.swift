//
//  HMWelcomeViewController.swift
//  Weibo20
//
//  Created by HM on 16/9/22.
//  Copyright © 2016年 HM. All rights reserved.
//

import UIKit
import SDWebImage

//  欢迎页面控制器
class HMWelcomeViewController: UIViewController {

    //  MARK: --懒加载
    //  背景图片
    private lazy var bgImageView: UIImageView = UIImageView(image: UIImage(named: "ad_background"))
    
    //  头像
    private lazy var userImageView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "avatar_default_big"))
       
        if let imageUrl = HMUserAccountViewModel.sharedUserAccountViewModel.userAccount?.avatar_large {
            //  表示url不为nil
            view.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: "avatar_default_big"))
            
        }
//         view.size =  CGSize(width: 85, height: 85)
        
        view.layer.cornerRadius = 85 / 2
        view.layer.masksToBounds = true
    
        return view
    }()
    //  文本信息
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        
        if let name = HMUserAccountViewModel.sharedUserAccountViewModel.userAccount?.name {
             label.text = "欢迎回来, \(name)"
        } else {
             label.text = "欢迎回来"
        }
        
        
        
        label.font = UIFont.systemFont(ofSize: 15)
       
        label.textColor = UIColor.darkGray
        //  透明
        label.alpha = 0
        return label
        
    }()
    
    
    override func loadView() {
        view = bgImageView
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    //  添加控件设置约束
    private func setupUI() {
        view.addSubview(userImageView)
        view.addSubview(messageLabel)
        
        userImageView.snp_makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.top.equalTo(view).offset(200)
            make.size.equalTo(CGSize(width: 85, height: 85))
        }
        
        messageLabel.snp_makeConstraints { (make) in
            make.centerX.equalTo(userImageView)
            make.top.equalTo(userImageView.snp_bottom).offset(10)
        }
        
    
    }
    
    
    //  界面已经显示出来的时候调用动画
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startAnimation()
    }
    
    
    //  开启动画
    private func startAnimation() {
        
        userImageView.snp_updateConstraints { (make) in
            make.top.equalTo(view).offset(100)
        }
        
        //  执行约束动画
        //  usingSpringWithDamping 阻尼 0 - 1, 阻尼越大弹簧效果越小
        //  initialSpringVelocity 初始速度
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [], animations: {
            
            self.view.layoutIfNeeded()
            
            
            }) { (_) in
                
                UIView.animate(withDuration: 1, animations: { 
                    self.messageLabel.alpha = 1
                    }, completion: { (_) in
                        //  完成切换界面到首页
                        NotificationCenter.default.post(name: NSNotification.Name(SwitchRootVCNotification), object: nil)
                        
                        
                        
                })
                
                
        }
        
        
    
    
    }
    

 
}
