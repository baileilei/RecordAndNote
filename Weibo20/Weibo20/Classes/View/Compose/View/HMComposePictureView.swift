//
//  HMComposePictureView.swift
//  Weibo20
//
//  Created by HM on 16/9/28.
//  Copyright © 2016年 HM. All rights reserved.
//

import UIKit
//  重用标记
private let HMComposePictureViewCellIdentifier = "HMComposePictureViewCellIdentifier"

//  自定义撰写微博配图
class HMComposePictureView: UICollectionView {
    //  点击最后一个cell执行的闭包
    var lastCellCallBack: (()->())?
    //  MARK: --    记录绑定图片数据
    lazy var images: [UIImage] = [UIImage]()
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        let flowLayout = UICollectionViewFlowLayout()
        super.init(frame: frame, collectionViewLayout: flowLayout)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        //  注册cell
        register(HMComposePictureViewCell.self, forCellWithReuseIdentifier: HMComposePictureViewCellIdentifier)
        
        
        //  数据源代理
        dataSource = self
        
        //  设置代理
        delegate = self
        
        isHidden = true
        
        
    }
    
    
    //  添加图片
    func addImage(image: UIImage) -> Void {
        //  判断是否是最大张数
        if images.count == 9 {
            return
        }
        
        isHidden = false
        
        images.append(image)
        //  重新加载数据
        reloadData()
        
    }
    
    //  调整子控件布局
    override func layoutSubviews() {
        super.layoutSubviews()
        let itemMargin: CGFloat = 5
        //  计算每项的宽度
        let itemWidth = (width - 2 * itemMargin) / 3
        
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        //  每项的条目的大小
        flowLayout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        //  垂直方向的间距
        flowLayout.minimumLineSpacing = itemMargin
        //  水平方向间距
        flowLayout.minimumInteritemSpacing = itemMargin
        
        
        
        
    }
    
    
   

}

//  MARK: --    UICollectionViewDataSource
extension HMComposePictureView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if images.count == 0 || images.count == 9 {
            return images.count
        } else {
            return images.count + 1
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HMComposePictureViewCellIdentifier, for: indexPath) as! HMComposePictureViewCell
        
        if indexPath.item == images.count {
            //  表示最后一个cell,那么就不能直接通过数组去取值
            cell.image = nil
        } else {
            cell.image = images[indexPath.item]
            cell.indexPath = indexPath
//            cell.callBack = { (index: IndexPath) in
//                self.images.remove(at: index.item)
//                self.reloadData()
//            }
            
            cell.deleteCallBack = {
                self.images.remove(at: indexPath.item)
                
                if self.images.count == 0 {
                    //  隐藏配图
                    self.isHidden = true
                }
                
                self.reloadData()
                
            }
            
        }
        
        
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if images.count == indexPath.item {
            //  表示点击的是最后一个cell , 打开图片浏览器
            lastCellCallBack?()
        }
    }
    
    

}

//  发微博配图cell
class HMComposePictureViewCell: UICollectionViewCell {
    //  执行删除的闭包
    var callBack: ((IndexPath)->())?
    //  执行删除的闭包
    var deleteCallBack: (()->())?
    //  记录当前的indexPath
    var indexPath: IndexPath?
    //  MARK: --    懒加载
    private lazy var imageView: UIImageView = UIImageView(image: UIImage(named: "timeline_image_placeholder"))
    //  删除按钮
    private lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(deleteButtonAction), for: .touchUpInside)
        button.setImage(UIImage(named: "compose_photo_close"), for: .normal)
        return button
    }()
    
    //  设置图片
    var image: UIImage? {
        didSet {
            if image == nil {
                //  加号按钮
                imageView.image = UIImage(named: "compose_pic_add")
                //  隐藏删除按钮
                deleteButton.isHidden = true
            } else {
                imageView.image = image
                //  显示删除按钮
                deleteButton.isHidden = false
            }
            
            
        }
    
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //  添加控件设置约束
    private func setupUI() {
    
        contentView.addSubview(imageView)
        contentView.addSubview(deleteButton)
        imageView.snp_makeConstraints { (make) in
            make.edges.equalTo(contentView).offset(UIEdgeInsets.zero)
        }
        
        deleteButton.snp_makeConstraints { (make) in
            make.top.equalTo(imageView)
            make.trailing.equalTo(imageView)
        }
        
    
    }
    //  MARK: --    点击事件
    @objc private func deleteButtonAction() {
    
        print("你删除我了")
//        if let index = indexPath {
//            callBack?(index)
//        }

        deleteCallBack?()
        
    }
    
    
}












