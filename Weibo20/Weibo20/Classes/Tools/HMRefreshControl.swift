//
//  HMRefreshControl.swift
//  Weibo20
//
//  Created by HM on 16/9/25.
//  Copyright © 2016年 HM. All rights reserved.
//

import UIKit
//  下拉刷新控件的高度
private let HMRefreshControlHeight: CGFloat = 50
//  下拉刷新控件状态
enum HMRefreshControlState {
    //  下拉刷新
    case normal
    //  松手就刷新
    case pulling
    //  正在刷新
    case refreshing
}


class HMRefreshControl: UIControl {

    //  记录当前滚动视图
    var currentScrollView: UIScrollView?
    
    //  当前的控件的刷新状态
    var hmState: HMRefreshControlState = .normal {
        didSet {
            switch hmState {
            case .normal:
                print("normal")
                //  箭头重置,箭头显示, 停止风火轮, 更新显示内容
                iconImageView.isHidden = false
                indicatorView.stopAnimating()
                UIView.animate(withDuration: 0.25, animations: {
                    self.iconImageView.transform = CGAffineTransform.identity
                })
                //  判断上次刷新状态如果是正在刷新那么让其回到原始位置
                //  oldValue表示上一次记录的结果
                if oldValue == .refreshing {
                    //  设置停留 初始化成原始位置
                    UIView.animate(withDuration: 0.25, animations: {
                        self.currentScrollView?.contentInset.top -= HMRefreshControlHeight
                    })
                }
                
                
                messageLabel.text = "下拉刷新"
                
                
            case .pulling:
                print("pulling")
                //  箭头调转, 更新内容
                UIView.animate(withDuration: 0.25, animations: { 
                    self.iconImageView.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
                })
                messageLabel.text = "松手就刷新"
                
            case .refreshing:
                print("refreshing")
                
                //  隐藏箭头, 开启菊花转, 更新显示内容
                iconImageView.isHidden = true
                
                indicatorView.startAnimating()
                
                messageLabel.text = "正在刷新..."
                
                
                //  设置停留 核心点
                UIView.animate(withDuration: 0.25, animations: { 
                    self.currentScrollView?.contentInset.top += HMRefreshControlHeight
                })
                
                
                //  主动发送事件,刷新数据请求
                //  核心点
                sendActions(for: .valueChanged)
                
                
                
                
            }
           
            
            
        }
    
    }
    
    //  MARK: --    懒加载
    //  下拉箭头
    private lazy var iconImageView: UIImageView = UIImageView(image: UIImage(named: "tableview_pull_refresh"))
    //  风火轮
    private lazy var indicatorView: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    //  文本
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.gray
        label.textAlignment = .center
        label.text = "下拉刷新"
        return label
    
    }()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupUI() {
        
        backgroundColor = UIColor.red
        addSubview(iconImageView)
        addSubview(messageLabel)
        addSubview(indicatorView)
        
        
        //  使用手写方式布局
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        
        addConstraint(NSLayoutConstraint(item: iconImageView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: -35))
        
        addConstraint(NSLayoutConstraint(item: iconImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        
        addConstraint(NSLayoutConstraint(item: messageLabel, attribute: .leading, relatedBy: .equal, toItem: iconImageView, attribute: .trailing, multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: messageLabel, attribute: .centerY, relatedBy: .equal, toItem: iconImageView, attribute: .centerY, multiplier: 1, constant: 0))
        
        
        addConstraint(NSLayoutConstraint(item: indicatorView, attribute: .centerX, relatedBy: .equal, toItem: iconImageView, attribute: .centerX, multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: indicatorView, attribute: .centerY, relatedBy: .equal, toItem: iconImageView, attribute: .centerY, multiplier: 1, constant: 0))
        
        
//        indicatorView.startAnimating()
        
        
    }
    
    //  怎么获取父控件 -> 使用该方法获取父控件
    override func willMove(toSuperview newSuperview: UIView?) {
        guard let scrollView = newSuperview as? UIScrollView else {
            return
        }
        
        //  代码执行到此表示我们的父视图可以滚动
        self.frame.size = CGSize(width: scrollView.frame.size.width, height: HMRefreshControlHeight)
        self.frame.origin.y = -HMRefreshControlHeight
        
        //  kvo的方式监听 垂直方向的偏移量
        //  [.new, .old]->关系多个枚举
        scrollView.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
        //  记录当前的滚动的视图
        currentScrollView = scrollView
    }
    //  kvo监听方法, 只要contentOffset属性发生了改变,那么就会回到这个方法
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
      
        
        
        
        let contentOffSetY = currentScrollView!.contentOffset.y
        //  临界点
        let maxY = -(currentScrollView!.contentInset.top + HMRefreshControlHeight)
       
        //  怎么判断现在是拖动状态
        //
        if currentScrollView!.isDragging {
            //  拖动情况下只有两种状态, 1. 下拉刷新状态, 2, 松手就刷新的状态
            
            //  拖动状态
            if contentOffSetY < maxY && hmState == .normal {
                print("松手就刷新puling")
                hmState = .pulling
            } else if contentOffSetY >= maxY && hmState == .pulling {
                print("下拉刷新normal")
                hmState = .normal
            }
        } else {
            //  没有拖动
            //  要想进入正在刷新,其它是第一条件松手,第二个条件松手就刷新的状态才可以进入正在刷新
            if hmState == .pulling  {
                print("正在刷新")
                hmState = .refreshing
            }
            
            
            
        
        }
        
       
    }
    
    //  结束刷新
    func endRefreshing() -> Void {
        hmState = .normal
    }
    
    deinit {
        //  移除kvo
        currentScrollView?.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    

}
