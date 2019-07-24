//
//  HMEmoticonCollectionViewCell.swift
//  Weibo20
//
//  Created by HM on 16/10/6.
//  Copyright © 2016年 HM. All rights reserved.
//

import UIKit
//  自定义表情视图cell
class HMEmoticonCollectionViewCell: UICollectionViewCell {
    
    //  记录当前的表情按钮
    lazy var emoticonButtonArray: [HMEmoticonButton] = [HMEmoticonButton]()
    
    //  准备cell需要的数据源
    var emotionsArray: [HMEmoticon]? {
        
        didSet {
            guard let entArray = emotionsArray else {
                return
            }
            
            //  代码执行到此,说明数组不为nil
            
            //  把表情按钮的全部隐藏
            for button in emoticonButtonArray {
                button.isHidden = true
            }
            
            
            //  遍历表情数组模型 给表情按钮绑定数据
            for (i, emoticon) in entArray.enumerated() {
            
                //  获取表情按钮
                let button = emoticonButtonArray[i]
                //  设置表情模型
                button.emoticon = emoticon
                
//                button.isHidden = false
//                
//                
//                if emoticon.type == "0" {
//                    //  表示图片,直接设置button的image, 
//                    //  问题-> 图片的路径需要拼接完整
//                    button.setImage(UIImage(named: emoticon.path!), for: .normal)
//                    button.setTitle(nil, for: .normal)
//                    
//                } else {
//                    //  表示emoji, 直接设置文本
//                    button.setTitle((emoticon.code! as NSString).emoji(), for: .normal)
//                    button.setImage(nil, for: .normal)
//                }
                
            
            }
            
            
            
            
            
        }
        
        
        
        
    }
    
    var indexPath: IndexPath? {
        didSet {
            messageLabel.text = "当前显示的是第\(indexPath!.section + 1)组第\(indexPath!.item + 1)行"
        }
    }
    
    fileprivate lazy var messageLabel: UILabel = {
        let label = UILabel(textColor: UIColor.red, fontSize: 30)
        return label
    }()
    
    //  添加删除表情按钮
    fileprivate lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(deleteButtonAction), for: .touchUpInside)
        button.setImage(UIImage(named: "compose_emotion_delete"), for: .normal)
        button.setImage(UIImage(named: "compose_emotion_delete_highlighted"), for: .highlighted)
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
        
        addChildEmoticonButton()
        
        contentView.addSubview(deleteButton)
        
//        //  添加控件
//        contentView.addSubview(messageLabel)
//        
//        messageLabel.snp_makeConstraints { (make) in
//            make.center.equalTo(contentView)
//        }
    
    }
    
    //  添加表情按钮
    func addChildEmoticonButton() {
        for _ in 0..<20 {
            let button = HMEmoticonButton()
            button.addTarget(self, action: #selector(emoticonButtonAction(btn:)), for: .touchUpInside)
            
            //  设置字体大小
            button.titleLabel?.font = UIFont.systemFont(ofSize: 33)
            //  添加到contentview上
            contentView.addSubview(button)
            emoticonButtonArray.append(button)
        }
    }
    
    //  MARK: --    点击删除按钮处理逻辑
    @objc private func deleteButtonAction() {
        print("啊哈哈")
        NotificationCenter.default.post(name: NSNotification.Name(DidSelectedDeleteEmoticonNotification), object: nil)
    }
    
    //  MARK: --    点击表情按钮处理逻辑
    @objc private func emoticonButtonAction(btn: HMEmoticonButton) {
    
        print("哈哈")
        //  获取对应的表情模型
        let emoticon = btn.emoticon!
        //
        NotificationCenter.default.post(name: NSNotification.Name(DidSelectedEmoticonNotification), object: emoticon)
        
        let popView = HMEmoticonPopView.emoticonPopView()
        //  设置popview的表情模型
        popView.emotionButton.emoticon = emoticon
        
        //  获取window
        let window = UIApplication.shared.windows.last!
        
        window.addSubview(popView)
        

        //  btn在collectionView的区域上转成window的区域
        let convertRect = contentView.convert(btn.frame, to: window)
    
        print(convertRect)
        //  获取这个范围的水平的中心点x
        popView.centerX = convertRect.midX
        popView.y = convertRect.maxY - popView.height
        
        //  延时0.25秒移除
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25) { 
            popView.removeFromSuperview()
        }
        
        
    }
    
    
    //  设置子控件的大小和位置
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //  计算每项的宽度
        let itemWidth = width / 7
        let itemHeight = height / 3
        
        //  遍历表情数组元素
        for (i, button) in emoticonButtonArray.enumerated() {
        
            button.size = CGSize(width: itemWidth, height: itemHeight)
            //  计算列的索引
            let colIndex = i % 7
            //  计算行的索引
            let rowIndex = i / 7
            
            //  设置x,y坐标
            button.x = CGFloat(colIndex) * itemWidth
            button.y = CGFloat(rowIndex) * itemHeight
            
            
        }
        
        //  设置删除按钮的大小和坐标
        deleteButton.size = CGSize(width: itemWidth, height: itemHeight)
        deleteButton.x = width - itemWidth
        deleteButton.y = height - itemHeight
        
        
    }
    
    
    
}
