//
//  HMEmoticonPopView.swift
//  Weibo20
//
//  Created by HM on 16/10/6.
//  Copyright © 2016年 HM. All rights reserved.
//

import UIKit
//  自定义popView
class HMEmoticonPopView: UIView {

    @IBOutlet weak var emotionButton: HMEmoticonButton!
    
    //  xib加载视图
    class func emoticonPopView() -> HMEmoticonPopView {
        
        return UINib(nibName: "HMEmoticonPopView", bundle: nil).instantiate(withOwner: nil, options: nil).last! as! HMEmoticonPopView
        
        
    
    }
   

}
