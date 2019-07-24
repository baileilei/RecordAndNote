//
//  HMStatusDAL.swift
//  Weibo20
//
//  Created by HM on 16/10/9.
//  Copyright © 2016年 HM. All rights reserved.
//

import UIKit

//  删除7天前天缓存数据
let MaxTimeinterval: TimeInterval = 7 * 24 * 3600
//  数据库访问层, 用加载网络请求和缓存新浪微博数据
class HMStatusDAL: NSObject {

    //  加载数据
    class func loadData(accessToken: String, maxId: Int64, sinceId: Int64, callBack: @escaping ([[String : Any]])->()) {
        //  1. 检测本地是否有缓存数据(完成)
        let localArray = checkCacheData(maxId: maxId, sinceId: sinceId)
        //  2. 如果本地有缓存数据那么直接返回本地的缓存数据
        if localArray.count > 0 {
            //  回调本地数据
            callBack(localArray)
            return
        }
        
        //  3. 如果本地没有缓存数据那么直接从网络加载新浪微博数据
        HMNetworkTools.sharedTools.requestStatuses(accessToken: accessToken, maxId: maxId, sinceId: sinceId) { (response, error) in
            if error != nil {
                print("网络请求异常: \(error)")
                callBack(localArray)
                return
            }
            
            //  代码执行到此表示网络请求成功
            //            print(response)
            
            guard let dic = response as? [String: Any] else {
                print("你不是一个正确的字典格式")
                 callBack(localArray)
                return
            }
            
            
            
            
            guard let statusArray = dic["statuses"] as? [[String: Any]] else {
                print("你不是一个正确的字典格式")
                 callBack(localArray)
                return
            }
            
            //  代码执行到此表示网络请求成功
            //  4. 网络数据加载成功后缓存到本地(完成)
            cacheData(statusDicArray: statusArray)
            //  5. 缓存数据成功后, 把网络请求的数据返回
            callBack(statusArray)
        }
        
        
        
        
        
        
        
    
    
    }
    
    //  根据外界传入的maxid或者sinceid查询本地微博数据
    class func checkCacheData(maxId: Int64, sinceId: Int64) -> [[String: Any]] {
        //  SELECT * FROM statuses where statusid < 4028699428997831 and userid = 5826086647 order by statusid desc limit 20
        //  拼接sql的时候要么使用空格,要么使用换行
        //  准备sql
        var sql = "SELECT * FROM statuses\n"
        if maxId > 0 {
            //  上拉加载操作
            sql += "where statusid < \(maxId)\n"
        } else {
            //  下拉刷新操作
            sql += "where statusid > \(sinceId)\n"
        }
        //  拼接用户id
        sql += "and userid = \(HMUserAccountViewModel.sharedUserAccountViewModel.userAccount!.uid)\n"
        
        //  拼接排序方式
        sql += "order by statusid desc\n"
        //  拼接返回的最大条数
        sql += "limit 20\n"
        
        
        // 查询数据结果
        let dicArray = SqliteManager.sharedManager.selectDicArray(sql: sql)
        //  存储微博字典数据
        var tempArray = [[String: Any]]()
        //  遍历数组字典获取微博数据
        for dic in dicArray {
            //  获取微博二进制数据
            let statusData = dic["status"]! as! Data
            //  获取微博字典
            let statusDic = try! JSONSerialization.jsonObject(with: statusData, options: []) as! [String: Any]
            tempArray.append(statusDic)
        }
        
        
        return tempArray
        
        
        
        
    }
    
    //  缓存新浪微博数据
    //  根据微博数组字典缓存数据
    class func cacheData(statusDicArray: [[String: Any]]) {
        //  准备sql
        let sql = "INSERT OR REPLACE INTO Statuses(statusid, status, userid) VALUES(?, ?, ?)"
        //  获取登录用户的id
        let userid = HMUserAccountViewModel.sharedUserAccountViewModel.userAccount?.uid
        //  为了数据的完整型,我们使用事物的方式保存数据
        SqliteManager.sharedManager.queue.inTransaction { (db, rollBack) in
            //  通过遍历数组字典依次插入数据
            for statusDic in statusDicArray {
                //  获取微博id
                let statusid = statusDic["id"]!
                //  把微博数据转成二进制存储
                let statusData = try! JSONSerialization.data(withJSONObject: statusDic, options: [])
                //  执行插入操作
                let result = db?.executeUpdate(sql, withArgumentsIn: [statusid, statusData, userid!])
                
                if result == false {
                    //  取到指针对应的内容设置成回滚操作
                    rollBack?.pointee = true
                    break
                }
                
                
            }
            
            
            
        }
    
    }
    
    //  清除缓存数据
    class func clearCacheData() {
        //  设置删除时间
        let deleteDate = Date().addingTimeInterval(-MaxTimeinterval)
        let dt = DateFormatter()
        //  指定本地化信息
        dt.locale = Locale(identifier: "en_US")
        //  设置时间格式化方式
        dt.dateFormat = "yyyy-MM-dd HH:mm:ss"
        //  获取删除时间字符串
        let deleteDateString = dt.string(from: deleteDate)
        
        //  准备sql语句
        let sql = "DELETE FROM statuses  where time < '\(deleteDateString)'"
        
        SqliteManager.sharedManager.queue.inDatabase { (db) in
            let result = db?.executeUpdate(sql, withArgumentsIn: nil)
            if result == true {
                print("缓存数据删除成功, 影响了\(db!.changes())条数据")
            } else {
                print("删除失败")
            }
        }
    
    }
    
    
    
    
    
}
