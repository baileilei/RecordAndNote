//
//  HMStatusPictureView.swift
//  Weibo20
//
//  Created by HM on 16/9/25.
//  Copyright © 2016年 HM. All rights reserved.
//

import UIKit
import SDWebImage

//  重用标记
private let HMStatusPictureViewCellIdentifier = "HMStatusPictureViewCellIdentifier"

//  每项之间的间距
let itemMargin: CGFloat = 5
//  每项的宽度
let itemWidth = (ScreenWidth - 2 * HMHomeTableViewCellMargin - 2 * itemMargin) / 3

//  自定义微博首页配图视图

class HMStatusPictureView: UICollectionView {
    
    //  设置配图数据源
    var picUrls: [HMStatusPictureInfo]? {
        didSet {
            messageLabel.text = "\(picUrls?.count ?? 0)"
            
            let size = calcSize(count: picUrls?.count ?? 0)
            
            //  设置约束大小
            self.snp_updateConstraints { (make) in
                make.size.equalTo(size)
            }
            
            //  加载设置数据
            self.reloadData()
            
        }
    }
    
    //  MARK: --懒加载控件
    private lazy var messageLabel: UILabel = {
        let label = UILabel(textColor: UIColor.magenta, fontSize: 20)
        return label
    }()
    
    

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        //  创建布局对象
        let flowLayout = UICollectionViewFlowLayout()
        //  设置大小
        flowLayout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        //  垂直间距
        flowLayout.minimumLineSpacing = itemMargin
        //  水平间距
        flowLayout.minimumInteritemSpacing = itemMargin
        
        super.init(frame: frame, collectionViewLayout: flowLayout)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //  添加控件设置约束
    private func setupUI() {
        
        //  注册cell
        register(HMStatusPictureViewCell.self, forCellWithReuseIdentifier: HMStatusPictureViewCellIdentifier)
        //  设置数据源代理
        self.dataSource = self
        //  设置代理
        self.delegate = self
        
        
        addSubview(messageLabel)
        
        messageLabel.snp_makeConstraints { (make) in
            make.center.equalTo(self)
        }
    
    }
    
    
    //  根据图片张数计算配图大小
    private func calcSize(count: Int) -> CGSize {
        
        //  判断图片个数是否等于1,如果图片的个数等于1 表示要从缓存中去图片
        
        if count == 1 {
            let imageUrl = picUrls!.first!.thumbnail_pic!
            //  从缓存中去取图片
            let image = SDWebImageManager.shared().imageCache.imageFromDiskCache(forKey: imageUrl)
            //  如果image不为nil表示找到了缓存中图片
            if image != nil {
                //  注意一个问题 , 单张图片的大小 绑定数据时候图片比设置条目的大小要大,那么就会出现警告
                
                var size = image!.size
                
                //  如果图片的宽度小于指定的大小,那么需要等比计算图片的高度
                //  图片过窄处理 -> 产品处理这个问题
//                if size.width < 80 {
//                    //  指定宽度
//                    let scaleWidth: CGFloat = 80
//                    let height = scaleWidth / size.width * size.height
//                    
//                    let scaleHeight = height > 150 ? 150: height
//                    
//                    
//                    size.width = scaleWidth
//                    size.height = scaleHeight
//                }
                
                
                //  直接指定成特定大小
                size = CGSize(width: itemWidth, height: itemWidth)
                
                //  怎么调整条目大小
                
                let flowLayout = self.collectionViewLayout as! UICollectionViewFlowLayout
                //  调整单张图片 条目的大小
                flowLayout.itemSize = size
                
                return size
                
            }
            
            
            
            
        
        }
        
        
        //  不是单张图片,那么还需要把条目修改成原始计算的大小
        let flowLayout = self.collectionViewLayout as! UICollectionViewFlowLayout
        //  调整单张图片 条目的大小
        flowLayout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        //  计算列数
        let cols = count > 3 ? 3 : count
        //  计算行数
        let rows = (count - 1) / 3 + 1
        //  计算当前配图宽度
        let currentWidth = itemWidth * CGFloat(cols) + CGFloat(cols - 1) * itemMargin
        //  计算当前配图的高度
        let currentHeight = itemWidth * CGFloat(rows) + CGFloat(rows - 1) * itemMargin
        
        return CGSize(width: currentWidth, height: currentHeight)
    
    }
    
    

}

//  MARK: --UICollectionViewDataSource
extension HMStatusPictureView: UICollectionViewDataSource, UICollectionViewDelegate, SDPhotoBrowserDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  picUrls?.count ?? 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HMStatusPictureViewCellIdentifier, for: indexPath) as! HMStatusPictureViewCell
        //  绑定模型数据
        cell.statusPictureInfo = picUrls![indexPath.item]
        return cell
    }
    
    
//    - (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
//    {
//    SDPhotoBrowser *photoBrowser = [SDPhotoBrowser new];
//    photoBrowser.delegate = self;
//    photoBrowser.currentImageIndex = indexPath.item;
//    photoBrowser.imageCount = self.modelsArray.count;
//    photoBrowser.sourceImagesContainerView = self.collectionView;
//    
//    [photoBrowser show];
//    }

    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoBrowser = SDPhotoBrowser()
        photoBrowser.delegate = self
        photoBrowser.currentImageIndex = indexPath.item
        photoBrowser.imageCount = picUrls!.count
        photoBrowser.sourceImagesContainerView = self
        photoBrowser.show()
    }
    
    
    
//    // 返回临时占位图片（即原来的小图）
//    - (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index
//    {
//    // 不建议用此种方式获取小图，这里只是为了简单实现展示而已
//    SDCollectionViewDemoCell *cell = (SDCollectionViewDemoCell *)[self collectionView:self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
//    
//    return cell.imageView.image;
//    
//    }
//    
//    
//    // 返回高质量图片的url
//    - (NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index
//    {
//    NSString *urlStr = [[self.modelsArray[index] thumbnail_pic] stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"];
//    return [NSURL URLWithString:urlStr];
//    }
    
    
    func photoBrowser(_ browser: SDPhotoBrowser!, placeholderImageFor index: Int) -> UIImage! {
        let cell = self.cellForItem(at: IndexPath(item: index, section: 0)) as! HMStatusPictureViewCell
        return cell.imageView.image
    }
    
    func photoBrowser(_ browser: SDPhotoBrowser!, highQualityImageURLFor index: Int) -> URL! {
        let urlStr = picUrls![index].thumbnail_pic!.replacingOccurrences(of: "thumbnail", with: "bmiddle")
        return URL(string: urlStr)
    }
    

    
    
}



//  自定义配图cell
class HMStatusPictureViewCell: UICollectionViewCell {
    //  设置模型数据
    var statusPictureInfo: HMStatusPictureInfo? {
        didSet {
            
            
            if let url = statusPictureInfo?.thumbnail_pic {
                imageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "timeline_image_placeholder"))
                //  判断后缀是否是.gif
                if url.hasSuffix(".gif") {
                    gifImageView.isHidden = false
                } else {
                    gifImageView.isHidden = true
                }
                
            }
            
            
        }
    }
    
    //  MARK: --    懒加载控件
    lazy var imageView: UIImageView = {
    
        let view = UIImageView(image: UIImage(named: "timeline_image_placeholder"))
        //  等比例原样显示
        view.contentMode = .scaleAspectFill
        //  会有超出范围显示,  剪切多余部分
        view.clipsToBounds = true
        return view
    }()
    
    //  gif图片
    private lazy var gifImageView: UIImageView = UIImageView(image: UIImage(named: "timeline_image_gif"))
    
    
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
        contentView.addSubview(gifImageView)
        //  imageView的大小等于contentView
        imageView.snp_makeConstraints { (make) in
            make.edges.equalTo(contentView).offset(UIEdgeInsets.zero)
        }
        gifImageView.snp_makeConstraints { (make) in
            make.bottom.equalTo(imageView)
            make.trailing.equalTo(imageView)
        }
        
        
    
    }
    
    
    

}
















