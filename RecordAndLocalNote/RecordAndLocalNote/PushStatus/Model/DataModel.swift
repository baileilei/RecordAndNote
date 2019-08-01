//
//  DataModel.swift
//  RecordAndLocalNote
//
//  Created by smart-wift on 2019/7/25.
//  Copyright © 2019 g. All rights reserved.
//

import UIKit

class DataModel: NSObject {
    
    var userList = [UserInfo]()
    
    override init() {
        super.init()
        print("沙盒路径：\(documentsDirectory())")
        print("数据文件路径：\(dataFilePath())")
    }
    
    func saveData() -> Void {
        let data = NSMutableData()
        
        let archiver = NSKeyedArchiver(forWritingWith: data)
//        let archiver = NSKeyedArchiver(requiringSecureCoding: true)
        
        archiver.encode(userList, forKey: "userList")
        
        archiver.finishEncoding()
        
//        data.write(toFile: dataFilePath(), options: <#T##NSData.WritingOptions#>)
        data.write(toFile: dataFilePath(), atomically: true)
        
    }
    
    func loadData() {
        let path = self.dataFilePath()
        
        let defaultManager = FileManager()
        
        if defaultManager.fileExists(atPath: path) {
            let url = URL(fileURLWithPath: path)
            let data = try! Data(contentsOf: url)
            
            let unarchiver = try! NSKeyedUnarchiver.init(forReadingFrom: data)
            
            userList = unarchiver.decodeObject(forKey: "userList") as! Array
            
            unarchiver.finishDecoding()
            
        }
        
        
    }

    func documentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        
        let documentsDir = paths.first!
        return documentsDir
        
    }
    
    func dataFilePath() -> String {
        return self.documentsDirectory().appendingFormat("/userList.plist")
    }
}
