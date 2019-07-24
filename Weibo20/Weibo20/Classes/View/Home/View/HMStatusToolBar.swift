//
//  HMStatusToolBar.swift
//  Weibo20
//
//  Created by HM on 16/9/23.
//  Copyright © 2016年 HM. All rights reserved.
//

import UIKit


//  微博首页底部toolBar
class HMStatusToolBar: UIView {

    //  使用ViewModel绑定数据
    var statusViewModel: HMStatusViewModel? {
    
        didSet {
            
            retweetButton.setTitle(statusViewModel?.retweetCountContent, for: .normal)
            commentButton.setTitle(statusViewModel?.commentCountContent, for: .normal)
            unlikeButton.setTitle(statusViewModel?.unlikeCountContent, for: .normal)
            
        }
    }
    
    //  MARK: -- 懒加载
    private lazy var retweetButton: UIButton = self.addChildButton(imageName: "timeline_icon_retweet", title: "转发")
    private lazy var commentButton: UIButton = self.addChildButton(imageName: "timeline_icon_comment", title: "评论")
    private lazy var unlikeButton: UIButton = self.addChildButton(imageName: "timeline_icon_unlike", title: "赞")

    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //  添加控件设置约束
    private func setupUI() {
    
      
    
        //  设置约束
        retweetButton.snp_makeConstraints { (make) in
            make.leading.equalTo(self)
            make.top.equalTo(self)
            make.bottom.equalTo(self)
            make.width.equalTo(commentButton)
        }
        
        commentButton.snp_makeConstraints { (make) in
            make.top.equalTo(self)
            make.leading.equalTo(retweetButton.snp_trailing)
            make.bottom.equalTo(self)
            make.width.equalTo(unlikeButton)
        }
        
        unlikeButton.snp_makeConstraints { (make) in
            make.trailing.equalTo(self)
            make.top.equalTo(self)
            make.bottom.equalTo(self)
            make.leading.equalTo(commentButton.snp_trailing)
        }
        
        
        let firstLineView = addChildLineView()
        let secondLineView = addChildLineView()
        
        
        firstLineView.snp_makeConstraints { (make) in
            make.centerX.equalTo(retweetButton.snp_trailing)
            make.centerY.equalTo(self)
        }
        
        secondLineView.snp_makeConstraints { (make) in
            make.centerX.equalTo(commentButton.snp_trailing)
            make.centerY.equalTo(self)
        }
        
        
        
    }
    
    //  创建button按钮
    private func addChildButton(imageName: String, title: String) -> UIButton {
        let button = UIButton()
        button.setImage(UIImage(named: imageName), for: .normal)
        button.setTitle(title, for: .normal)
        //  设置字体大小
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        //  字体颜色
        button.setTitleColor(UIColor.darkGray, for: .normal)
        //  设置背景图片
        button.setBackgroundImage(UIImage(named: "timeline_card_bottom_background"), for: .normal)
        //  去掉高亮效果
        button.adjustsImageWhenHighlighted = false
        addSubview(button)
        return button
    
    }
    
    // 创建竖线视图
    private func addChildLineView() -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: "timeline_card_bottom_line"))
        addSubview(imageView)
        return imageView
    }
    
    
    
   

}
