//
//  UserInfo.swift
//  RecordAndLocalNote
//
//  Created by smart-wift on 2019/7/25.
//  Copyright © 2019 g. All rights reserved.
// main function------提醒功能

import UIKit

class UserInfo: NSObject,NSCoding {
    var name : String
    var phone : String
    
    //构造方法
//    required init() {
//
//    }
    required init(name:String="",phone:String="") {
        self.name = name;
        self.phone = phone
    }
    
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "Name")
        aCoder.encode(phone, forKey: "Phone")
    }
    
    //从object解析c回来
    required init?(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObject(forKey: "Name") as? String ?? ""
        self.phone = aDecoder.decodeObject(forKey: "Phone") as? String ?? ""
    }
    
}


class Bond: NSObject {
    var name :String = ""
    var picture : String = ""
    var currentTime : String = ""
    var comment :String = ""
    var futureNote : String = ""
    
    convenience init(name:String="",picture:String="") {
        self.init()
    }
    
    
}
