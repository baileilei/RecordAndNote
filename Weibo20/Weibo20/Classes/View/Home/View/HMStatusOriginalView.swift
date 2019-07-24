//
//  HMStatusOriginalView.swift
//  Weibo20
//
//  Created by HM on 16/9/23.
//  Copyright © 2016年 HM. All rights reserved.
//

import UIKit
import SDWebImage
import YYText

//  微博的原创微博视图
class HMStatusOriginalView: UIView {
    //  记录原创微博内容底部约束
    var originViewBottomConstraint: Constraint?
    
    //  给原创微博里面的子控件绑定数据
    var statusViewModel: HMStatusViewModel? {
        didSet {
            screenNameLabel.text = statusViewModel?.status?.user?.screen_name
            
            if let userImageUrl = statusViewModel?.status?.user?.profile_image_url {
                //  使用SDWebImage加载图片
                userImageView.sd_setImage(with: URL(string: userImageUrl), placeholderImage: UIImage(named: "avatar_default_big"))
            }
            
            timeLabel.text = statusViewModel?.timeContent
//            contentLabel.text = statusViewModel?.status?.text
            //  设置原创微博富文本
            contentLabel.attributedText = statusViewModel?.originalAttributedString
            
            mbrankImageView.image = statusViewModel?.mbrankImage
            verifiedTypeImageView.image = statusViewModel?.verifiedTypeImage
            sourceLabel.text = statusViewModel?.sourceContent
            
            //  卸载上次约束
            originViewBottomConstraint?.uninstall()
            
            //  判断原创微博的配图个数是否大于0
            if let picUrls = statusViewModel?.status?.pic_urls, picUrls.count > 0 {
                //  表示有配图
                
                //  显示配图, 修改约束, 绑定数据
                pictureView.isHidden = false
                self.snp_updateConstraints(closure: { (make) in
                    originViewBottomConstraint = make.bottom.equalTo(pictureView).offset(HMHomeTableViewCellMargin).constraint
                })
                //  绑定数据源
                pictureView.picUrls = picUrls
            } else {
                //  表示没有配图
                //  隐藏配图, 修改约束
                pictureView.isHidden = true
            
                self.snp_updateConstraints(closure: { (make) in
                    originViewBottomConstraint = make.bottom.equalTo(contentLabel).offset(HMHomeTableViewCellMargin).constraint
                })
                
                
                
            }
            
            
            
            
            
            
            
        }
    
    }
    
    //  MARK: --    懒加载控件
    //  用户头像
    private lazy var userImageView: UIImageView = UIImageView(image: UIImage(named: "avatar_default_big"))
    //  认证类型等级
    private lazy var verifiedTypeImageView: UIImageView = UIImageView(image: UIImage(named: "avatar_vip"))
    //  昵称
    private lazy var screenNameLabel: UILabel = UILabel(textColor: UIColor.darkGray, fontSize: 14)
    //  会员等级图片
    private lazy var mbrankImageView: UIImageView = UIImageView(image: UIImage(named: "common_icon_membership"))
    
    //  时间
    private lazy var timeLabel: UILabel =  UILabel(textColor: UIColor.orange, fontSize: 11)
    //  来源
    private lazy var sourceLabel: UILabel = UILabel(textColor: UIColor.lightGray, fontSize: 11)
    //  微博内容
    private lazy var contentLabel: YYLabel = {
        //let label = UILabel(textColor: UIColor.darkGray, fontSize: HMHomeTableViewCellFontSize)
        let label = YYLabel()
        //  设置最大换行的宽度
        label.preferredMaxLayoutWidth = ScreenWidth - 2 * HMHomeTableViewCellMargin
        //  多行显示
        label.numberOfLines = 0
        return label
    
    }()
    //  配图
    private lazy var pictureView: HMStatusPictureView = {
        let view = HMStatusPictureView()
        //  原创微博配图颜色等于远程微博视图的颜色
        view.backgroundColor = self.backgroundColor
        return view
    
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //  添加控件设置约束
    private func setupUI() {
    
        backgroundColor = UIColor.white
        
        addSubview(userImageView)
        addSubview(verifiedTypeImageView)
        addSubview(screenNameLabel)
        addSubview(mbrankImageView)
        addSubview(timeLabel)
        addSubview(sourceLabel)
        addSubview(contentLabel)
        addSubview(pictureView)
        
        //  设置约束
        userImageView.snp_makeConstraints { (make) in
            make.top.equalTo(self).offset(HMHomeTableViewCellMargin)
            make.leading.equalTo(self).offset(HMHomeTableViewCellMargin)
            make.size.equalTo(CGSize(width: 35, height: 35))
        }
        verifiedTypeImageView.snp_makeConstraints { (make) in
            make.centerX.equalTo(userImageView.snp_trailing)
            make.centerY.equalTo(userImageView.snp_bottom)
        }
        
        screenNameLabel.snp_makeConstraints { (make) in
            make.top.equalTo(userImageView)
            make.leading.equalTo(userImageView.snp_trailing).offset(HMHomeTableViewCellMargin)
        }
        
        mbrankImageView.snp_makeConstraints { (make) in
            make.top.equalTo(screenNameLabel)
            make.leading.equalTo(screenNameLabel.snp_trailing).offset(HMHomeTableViewCellMargin)
        }
        
        timeLabel.snp_makeConstraints { (make) in
            make.leading.equalTo(userImageView.snp_trailing).offset(HMHomeTableViewCellMargin)
            make.bottom.equalTo(userImageView)
        }
        
        sourceLabel.snp_makeConstraints { (make) in
            make.leading.equalTo(timeLabel.snp_trailing).offset(HMHomeTableViewCellMargin)
            make.bottom.equalTo(timeLabel)
        }
        
        contentLabel.snp_makeConstraints { (make) in
            make.top.equalTo(userImageView.snp_bottom).offset(HMHomeTableViewCellMargin)
            make.leading.equalTo(userImageView)
            make.width.equalTo(ScreenWidth - 2 * HMHomeTableViewCellMargin)
        }
        
        pictureView.snp_makeConstraints { (make) in
            make.top.equalTo(contentLabel.snp_bottom).offset(HMHomeTableViewCellMargin)
            make.leading.equalTo(contentLabel)
        }
        
        //  关键约束
        
        self.snp_makeConstraints { (make) in
            originViewBottomConstraint = make.bottom.equalTo(pictureView).offset(HMHomeTableViewCellMargin).constraint
        }
        
        
        //  设置点击高亮效果执行的闭包
        
//        @param containerView 能够显示富文本的控件
//        @param text    ->NSAttributedString 能够显示富文本
//        @param range    -> 匹配高亮效果的范围
//        @param rect     -> 点击高亮效果的区域
        contentLabel.highlightTapAction = { (containerView, attributedString, range, rect) in
            //  根据匹配的范围获取对应的字符串
            let text = (attributedString.string as NSString).substring(with: range)
            /// ......判断数据是什么类型, 去做相应的处理
            if text.hasPrefix("http") {
                print("你点的是链接")
            }
            print(text)
        }
    }

   

}
