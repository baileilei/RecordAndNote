//
//  HMEmoticonKeyBoard.swift
//  Weibo20
//
//  Created by HM on 16/10/6.
//  Copyright © 2016年 HM. All rights reserved.
//

import UIKit

//  自定义表情键盘视图

/*
    1. 表情视图 -> UICollectionView
    2. 页数指示器 -> UIPageControl
    3. toolBar -> UIStackView
 */

//  重用标记
private let HMEmoticonCollectionViewCellIdentifier = "HMEmoticonCollectionViewCellIdentifier"
class HMEmoticonKeyBoard: UIView {

    
    //  页数指示器
    fileprivate lazy var pageControl: UIPageControl = {
        let ctr = UIPageControl()
        //  当前选中页数的颜色
        ctr.currentPageIndicatorTintColor = UIColor(patternImage: UIImage(named: "compose_keyboard_dot_selected")!)
        //  默认页数的颜色
        ctr.pageIndicatorTintColor = UIColor(patternImage: UIImage(named: "compose_keyboard_dot_normal")!)
        //  隐藏单页
        ctr.hidesForSinglePage = true
        
        return ctr
        
        
    }()
    
    //  toolbar
    fileprivate lazy var toolBar: HMEmoticonToolBar = HMEmoticonToolBar()
    
    //  表情视图
    fileprivate lazy var emoticonCollectionView: UICollectionView = {
        
        let flowLayout = UICollectionViewFlowLayout()
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        view.backgroundColor = self.backgroundColor
        
        //  设置水平滚动方向
        flowLayout.scrollDirection = .horizontal
        //  开启分页
        view.isPagingEnabled = true
        //  隐藏水平方向的滚动条
        view.showsHorizontalScrollIndicator = false
        //  隐藏垂直方向的滚动条
        view.showsVerticalScrollIndicator = false
        //  去掉弹簧效果
        view.bounces = false
        
        //  注册cell
        view.register(HMEmoticonCollectionViewCell.self, forCellWithReuseIdentifier: HMEmoticonCollectionViewCellIdentifier)
        //  设置数据源代理
        view.dataSource = self
        //  设置代理
        view.delegate = self
        
        return view
        
    
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
        //  把图片设为背景色
        backgroundColor = UIColor(patternImage: UIImage(named: "emoticon_keyboard_background")!)
        
        //  设置滚动到的IndexPath
        let normalIndexPath = IndexPath(item: 0, section: 1)
        //  主线程异步,等待其它视图初始化完成和绑定数据完成后,然后在执行滚动到指定IndexPath
        DispatchQueue.main.async {
            //  设置滚动默认的这组表情数据
            self.emoticonCollectionView.scrollToItem(at: normalIndexPath, at: .left, animated: false)
        }
       
        
        //  获取默认page的数据
        self.setPageControlData(indexPath: normalIndexPath)
        
        addSubview(emoticonCollectionView)
        addSubview(toolBar)
        addSubview(pageControl)
        emoticonCollectionView.snp_makeConstraints { (make) in
            make.top.equalTo(self)
            make.leading.equalTo(self)
            make.trailing.equalTo(self)
            make.bottom.equalTo(toolBar.snp_top)
        }
        
        pageControl.snp_makeConstraints { (make) in
            make.bottom.equalTo(emoticonCollectionView)
            make.centerX.equalTo(emoticonCollectionView)
            make.height.equalTo(10)
        }
        
        toolBar.snp_makeConstraints { (make) in
            make.bottom.equalTo(self)
            make.leading.equalTo(self)
            make.trailing.equalTo(self)
            make.height.equalTo(35)
        }
        //  会有循环引用,使用[weak self]解决
        toolBar.callBack = { [weak self] (type: HMEmoticonToolBarButtonType) in
            let indexPath: IndexPath
            switch type {
            case .recent:
                print("最近")
                indexPath = IndexPath(item: 0, section: 0)
            case .normal:
                print("默认")
                indexPath = IndexPath(item: 0, section: 1)
            case .emoji:
                print("emoji")
                indexPath = IndexPath(item: 0, section: 2)
            case .lxh:
                print("浪小花")
                indexPath = IndexPath(item: 0, section: 3)
            }
            
            //  把collectionView滚动到指定的indexpath上
            //  不需要开启动画, 设置flase
            self?.emoticonCollectionView.scrollToItem(at: indexPath, at: .left, animated: false)
            
            
            self?.setPageControlData(indexPath: indexPath)
            
            
        }
        
        
        
        
        
    }
    
    //  设置表情视图条目的大小
    override func layoutSubviews() {
        super.layoutSubviews()
        //  获取布局方式
        let flowLayout = emoticonCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        //  设置条目大小
        flowLayout.itemSize = emoticonCollectionView.size
        //  设置垂直间距
        flowLayout.minimumLineSpacing = 0
        //  设置水平间距
        flowLayout.minimumInteritemSpacing = 0
        
        
        
    }
    
    //  通过indexPath绑定pangecontrol数据
    func setPageControlData(indexPath: IndexPath) {
        pageControl.numberOfPages = HMEmoticonTools.shareTools.allEmoticonsArray[indexPath.section].count
        pageControl.currentPage = indexPath.item
    }
    
    
    //  提供刷新最近表情数据
    func reloadRecentData() {
        
        let indexPath = IndexPath(item: 0, section: 0)
        //  刷新指定indexPath
        emoticonCollectionView.reloadItems(at: [indexPath])
        
    }
   

}



extension HMEmoticonKeyBoard: UICollectionViewDataSource, UICollectionViewDelegate {
    //  表示显示多少组数据
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return HMEmoticonTools.shareTools.allEmoticonsArray.count
    }
    //  表示每组显示多少个cell
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return HMEmoticonTools.shareTools.allEmoticonsArray[section].count
    }
    //  创建cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HMEmoticonCollectionViewCellIdentifier, for: indexPath) as! HMEmoticonCollectionViewCell
        cell.indexPath = indexPath
        cell.emotionsArray = HMEmoticonTools.shareTools.allEmoticonsArray[indexPath.section][indexPath.item]
        
        
        return cell
    }
    
    //  监听collectionView的滚动

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //  监听其滚动
        //  获取表情视图的中心点
        let centerX = scrollView.contentOffset.x + emoticonCollectionView.width / 2
        let centerY = scrollView.contentOffset.y + emoticonCollectionView.height / 2

        //  通过坐标的转换
        //  把emoticonCollectionView在HMEmoticonKeyBoard上中心点转换成在表情视图(emoticonCollectionView)的中心点上
        
        
        
//        let pointInView = self.convert(emoticonCollectionView.center, to: emoticonCollectionView)
//        print(pointInView)
        //  获取中心点
        let center = CGPoint(x: centerX, y: centerY)
        //  通过中心点获取对应的cell的indexpath
        if let indexPath = emoticonCollectionView.indexPathForItem(at: center) {
            //  获取对应的section
            let section = indexPath.section
            
            
            //  通过section选中相应按钮
            toolBar.selectedButton(section: section)
            setPageControlData(indexPath: indexPath)
        }
        
        
    }
    
   
    
    

}



