//
//  HMUserAccount.swift
//  Weibo20
//
//  Created by HM on 16/9/22.
//  Copyright © 2016年 HM. All rights reserved.
//

import UIKit
//  存储或读取沙盒路径
private let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last! as NSString).appendingPathComponent("userAccount.archiver")

//  用户账号模型
class HMUserAccount: NSObject, NSCoding {
    //  用户授权的唯一票据
    var access_token: String?
    //  access_token的生命周期，单位是秒数。
    var expires_in: TimeInterval = 0 {
        didSet {
            
            //  过期时间 =  当前时间 + 过去秒数
            expiresDate = Date().addingTimeInterval(expires_in)
        }
    }
    //  过期时间对象
    var expiresDate: Date?
    
    
    //	授权用户的UID
    var uid: Int64 = 0
    //  用户名
    var name: String?
    //  用户头像
    var avatar_large: String?
    
    
    //  kvc构造函数
    init(dic: [String: Any]) {
        
        super.init()
        setValuesForKeys(dic)
        
    }
    
    //  防止字段不匹配导致崩溃
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }
    
    //  MARK: --  归档与解档
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(access_token, forKey: "access_token")
        aCoder.encode(expiresDate, forKey: "expiresDate")
        aCoder.encode(uid, forKey: "uid")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(avatar_large, forKey: "avatar_large")
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        access_token = aDecoder.decodeObject(forKey: "access_token") as? String
        expiresDate = aDecoder.decodeObject(forKey: "expiresDate") as? Date
        uid = aDecoder.decodeInt64(forKey: "uid")
        name = aDecoder.decodeObject(forKey: "name") as? String
        avatar_large = aDecoder.decodeObject(forKey: "avatar_large") as? String
    }
    
    
    //  保存当前用户对象
    func saveUserAccount() -> Void {
        
        NSKeyedArchiver.archiveRootObject(self, toFile: path)        
    }
    
    //  从指定的沙盒路径里面加载用户对象
    class func loadUserAccount() -> HMUserAccount? {
        
        return NSKeyedUnarchiver.unarchiveObject(withFile: path) as? HMUserAccount
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
}
