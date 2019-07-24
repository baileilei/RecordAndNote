//
//  HMEmoticon.swift
//  Weibo20
//
//  Created by HM on 16/10/6.
//  Copyright © 2016年 HM. All rights reserved.
//

import UIKit
//  表情模型
class HMEmoticon: NSObject, NSCoding {

    //  表情描述
    var chs: String?
    //  图片名称
    var png: String?
    //  表情类型  0 -> 图片, 1 -> emoji
    var type: String?
    
    //  emoji字符串 , 16进制的字符串
    var code: String?
    //  图片的全路径
    var path: String?
    //  图片对应的文件夹名字
    var folderName: String?
    
    //  使用yymodel 如果进行归档了,那么需要提供默认的构造函数
    override init() {
        super.init()
    }
    
    
    //  MARK: --    归档与解档
    func encode(with aCoder: NSCoder) {
        aCoder.encode(chs, forKey: "chs")
        aCoder.encode(png, forKey: "png")
        aCoder.encode(type, forKey: "type")
        aCoder.encode(code, forKey: "code")
        aCoder.encode(path, forKey: "path")
        aCoder.encode(folderName, forKey: "folderName")
    }
    
    required init?(coder aDecoder: NSCoder) {
        chs = aDecoder.decodeObject(forKey: "chs") as? String
        png = aDecoder.decodeObject(forKey: "png") as? String
        type = aDecoder.decodeObject(forKey: "type") as? String
        code = aDecoder.decodeObject(forKey: "code") as? String
        path = aDecoder.decodeObject(forKey: "path") as? String
        folderName = aDecoder.decodeObject(forKey: "folderName") as? String
        
//        let path1 = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
//        print(path1)
        
        if type == "0" {
            //  如果是图片,需要重写拼接图片全路径
            let imagePath = HMEmoticonTools.shareTools.emoticonsBundle.path(forResource: folderName, ofType: nil)! + "/" + png!
            //  重写设置全路径
            path = imagePath
        }
        
        
        
    }
    
    
}
