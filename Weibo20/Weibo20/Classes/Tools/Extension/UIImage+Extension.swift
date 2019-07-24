//
//  UIImage+Extension.swift
//  Weibo20
//
//  Created by HM on 16/9/27.
//  Copyright © 2016年 HM. All rights reserved.
//

import UIKit

extension UIImage {
    
    //  截取当前window的图片
    static func screenShot() -> UIImage {
        
        let window = UIApplication.shared.keyWindow!
        //  开启图片上下文
        UIGraphicsBeginImageContext(window.size)
        
        //  afterScreenUpdates -> false 表示不需要等待更新后去绘制
        window.drawHierarchy(in: window.bounds, afterScreenUpdates: false)
        
        //  从图片上下文中获取图片
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    
    //  根据指定的宽度等比压缩图片
    func scaleImage(scaleWidth: CGFloat) -> UIImage {
        // 100, 100  -->  200, 200
        //  压缩后的宽度
        let scaleHeight = scaleWidth / self.size.width * self.size.height
        
        let size = CGSize(width: scaleWidth, height: scaleHeight)
        
        //  开启图片上下文
        UIGraphicsBeginImageContext(size)
        //  图片绘制到指定的区域内
        self.draw(in: CGRect(origin: CGPoint.zero, size: size))
        //  获取压缩后的图片
        let scaleImage = UIGraphicsGetImageFromCurrentImageContext()
        
        
        UIGraphicsEndImageContext()
        
        return scaleImage!
        
        
    }
    

}
