//
//  HMEmoticonButton.swift
//  Weibo20
//
//  Created by HM on 16/10/6.
//  Copyright © 2016年 HM. All rights reserved.
//

import UIKit
//  自定义表情按钮
class HMEmoticonButton: UIButton {

    //  设置对应的表情模型
    var emoticon: HMEmoticon? {
        didSet {
            
            guard let etn = emoticon else {
                return
            }
            
            
            self.isHidden = false
            
            
            if etn.type == "0" {
                //  表示图片,直接设置button的image,
                //  问题-> 图片的路径需要拼接完整
                self.setImage(UIImage(named: etn.path!), for: .normal)
                self.setTitle(nil, for: .normal)
                
            } else {
                //  表示emoji, 直接设置文本
                self.setTitle((etn.code! as NSString).emoji(), for: .normal)
                self.setImage(nil, for: .normal)
            }

        }
    }

}
