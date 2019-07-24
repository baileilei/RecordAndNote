//
//  HMUser.swift
//  Weibo20
//
//  Created by HM on 16/9/23.
//  Copyright © 2016年 HM. All rights reserved.
//

import UIKit
//  登录用户关注的用户模型
class HMUser: NSObject {
    //  用户id
    var id: Int64 = 0
    //  用户昵称
    var screen_name: String?
    //  头像地址
    var profile_image_url: String?
    //  认证类型等级 -1：没有认证，1，认证用户，2,3,5: 企业认证，220: 达人
    var verified_type: Int = 0
    //  会员等级 1 - 6
    var mbrank: Int = 0
    
//    //  kvc构造函数
//    init(dic: [String: Any]) {
//        super.init()
//        setValuesForKeys(dic)
//    }
//    //  字段不匹配 防止崩溃
//    override func setValue(_ value: Any?, forUndefinedKey key: String) {
//        
//    }
    
    
    
    
}
