//
//  HMStatus.swift
//  Weibo20
//
//  Created by HM on 16/9/23.
//  Copyright © 2016年 HM. All rights reserved.
//

import UIKit
//  微博数据模型
class HMStatus: NSObject {
    //  发微博时间
    var created_at: String?
    //  微博id
    var id: Int64 = 0
    //  微博内容
    var text: String?
    //  微博来源
    var source: String?
    //  用户模型
    var user: HMUser?
    //  转发数
    var reposts_count: Int = 0
    //  评论数
    var comments_count: Int = 0
    //  赞
    var attitudes_count: Int = 0
    //  转发微博
    var retweeted_status: HMStatus?
    //  微博配图模型数组
    var pic_urls: [HMStatusPictureInfo]?
    
    //  swift 写法, 指定集合属性元素类型
    class func modelContainerPropertyGenericClass() -> [String: Any] {
    
        return [
            "pic_urls": HMStatusPictureInfo.self
        ]
    
    }
    
    
    
//    + (NSDictionary *)modelContainerPropertyGenericClass {
//    // value should be Class or Class name.
//    return @{@"shadows" : [Shadow class],
//    @"borders" : Border.class,
//    @"attachments" : @"Attachment" };
//    }
    
    
    
    
//    //  kvc 构造函数
//    init(dic: [String: Any]) {
//        super.init()
//        setValuesForKeys(dic)
//    }
//    
//    override func setValue(_ value: Any?, forKey key: String) {
//        if key == "user" {
//            guard let dic = value as? [String: Any] else {
//                print("不是一个正确的字典")
//                return
//            }
//            //  自己通过kvc构造函数完成字典转模型
//            user = HMUser(dic: dic)
//            
//            
//            
//        }  else {
//            super.setValue(value, forKey: key)
//        }
//    }
//    
//    
//    
//    //  字段不匹配防止崩溃
//    override func setValue(_ value: Any?, forUndefinedKey key: String) {
//        
//    }
    
    
    
}
