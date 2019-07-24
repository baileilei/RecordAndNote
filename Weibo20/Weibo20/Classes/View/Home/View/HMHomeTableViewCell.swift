//
//  HMHomeTableViewCell.swift
//  Weibo20
//
//  Created by HM on 16/9/23.
//  Copyright © 2016年 HM. All rights reserved.
//

import UIKit

//  首页自定义cell

/*
    1. 原创微博视图
    2. 转发微博视图
    3. 底部toolBar视图
 
 */

//  cell子控件之间的内容间距
let HMHomeTableViewCellMargin: CGFloat = 10
//  设置微博内容字体大小
let HMHomeTableViewCellFontSize: CGFloat = 14

class HMHomeTableViewCell: UITableViewCell {
    
    
    //  记录当前toolbar顶部约束
    var toolBarTopConstraint: Constraint?

    //  cell需要使用ViewModel
    var statusViewModel: HMStatusViewModel? {
        didSet {
            //  可以给cell里面相应的子控件绑定数据
            originalView.statusViewModel = statusViewModel
            toolBar.statusViewModel = statusViewModel
            
            
            //  把toolbar顶部约束卸载掉
            toolBarTopConstraint?.uninstall()
            
            //  判断其是否有转发微博
            if statusViewModel?.status?.retweeted_status != nil {
                //  有转发微博
                //  更新约束,显示转发微博,绑定数据
                retweetView.isHidden = false
                toolBar.snp_updateConstraints(closure: { (make) in
                   toolBarTopConstraint = make.top.equalTo(retweetView.snp_bottom).constraint
                })
                
                retweetView.statusViewModel = statusViewModel
            } else {
                //  没有转发微博
                //  更新约束, 隐藏转发微博视图
                retweetView.isHidden = true
                toolBar.snp_updateConstraints(closure: { (make) in
                    toolBarTopConstraint = make.top.equalTo(originalView.snp_bottom).constraint
                })
                
                
                
            }
            
            
            print(statusViewModel?.status?.pic_urls?.first?.thumbnail_pic)
            
            
            
            
            
            
            
            
            
        }
    }
    
    
    //  MARK: --    懒加载控件
    private lazy var originalView: HMStatusOriginalView = {
        let view = HMStatusOriginalView()
        
        return view
    }()
    //  toolbar视图
    private lazy var toolBar: HMStatusToolBar = HMStatusToolBar()
    
    //  转发微博视图
    private lazy var retweetView: HMStatusRetweetView = {
        let view = HMStatusRetweetView()
        
        return view
    }()
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //  添加控件设置约束
    private func setupUI() {
        
        contentView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        
        contentView.addSubview(originalView)
        contentView.addSubview(retweetView)
        
        contentView.addSubview(toolBar)
        
        
        
        //  设置约束
        originalView.snp_makeConstraints { (make) in
            make.top.equalTo(contentView).offset(8)
            make.leading.equalTo(contentView)
            make.trailing.equalTo(contentView)
        }
        
        retweetView.snp_makeConstraints { (make) in
            make.top.equalTo(originalView.snp_bottom)
            make.leading.equalTo(originalView)
            make.trailing.equalTo(originalView)
        }
        
        toolBar.snp_makeConstraints { (make) in
            toolBarTopConstraint = make.top.equalTo(retweetView.snp_bottom).constraint
            make.leading.equalTo(retweetView)
            make.trailing.equalTo(retweetView)
            make.height.equalTo(35)
            
            
            //  关键约束 -> toolbar的底部约束等于contentView的底部约束
            make.bottom.equalTo(contentView.snp_bottom)
            
        }
        
        //  在swift 2.0 这样设置约束可以,但是swift 3.0就不可以了
//        contentView.snp_makeConstraints { (make) in
//            make.bottom.equalTo(toolBar)
//            make.top.equalTo(self)
//            make.left.equalTo(self)
//            make.trailing.equalTo(self)
//        }
        
    
    }
    
  

}
