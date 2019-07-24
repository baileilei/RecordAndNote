//
//  SqliteManager.swift
//  FMDBDemo
//
//  Created by HM on 16/10/9.
//  Copyright © 2016年 HM. All rights reserved.
//

import UIKit

//  创建数据库路径
let dbPath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last! as NSString).appendingPathComponent("sinaWeibo.db")

//  数据库专用类
class SqliteManager: NSObject {

    //  单例全局访问点
    static let sharedManager: SqliteManager = SqliteManager()
    //  使用数据库操作队列创建数据库
    //  数据操作队列对象
    lazy var queue: FMDatabaseQueue = FMDatabaseQueue(path: dbPath)
    //  构造函数私有化
    private override init() {
        super.init()
        
        print(dbPath)

        //  创建表
        createTables()
        
    }
    
    //  创建表
    private func createTables() {
        //  准备sql语句
        let path = Bundle.main.path(forResource: "db.sql", ofType: nil)!
        let sql = try! String(contentsOfFile: path)
        
        queue.inDatabase { (db) in
            //  执行多条sql语句
            let result = db?.executeStatements(sql)
            if result == true {
                print("创表成功")
            } else {
                print("创表失败")
            }
        }
    
    }
    
    //  插入数据
    
    func insert() {
        //  准备sql
        let sql = "INSERT INTO T_PERSON(NAME, AGE) VALUES(?, ?)"
        //  执行sql
        queue.inDatabase { (db) in
            //  执行插入操作
            let result = db?.executeUpdate(sql, withArgumentsIn: ["杨钰莹", 18])
            if result == true {
                print("插入成功")
            } else {
                print("插入失败")
            }
        }
    }
    
    //   查询数据
    func select() {
        // 准备sql
        let sql = "SELECT ID, NAME, AGE FROM T_PERSON"
        // 执行sql
        queue.inDatabase { (db) in
            //  查询操作范围结果集
            if let resultSet = db?.executeQuery(sql, withArgumentsIn: nil) {
                //  判断结果集是否有下一条记录
                while resultSet.next() {
                    //  获取id
                    let id = resultSet.int(forColumn: "ID")
                    //  获取名字
                    let name = resultSet.string(forColumn: "NAME")
                    //  获取年龄
                    let age = resultSet.int(forColumn: "AGE")
                    print("id: \(id), name: \(name), age: \(age)")
                    
                    
                }
            }
            
        }
    }
    
    //  通过查询返回数组字典
    func selectDicArray(sql: String) -> [[String: Any]] {
        
        //  存储字典
        var tempArray = [[String: Any]]()
        
        //  执行sql语句
        queue.inDatabase { (db) in
            if let resuSet = db?.executeQuery(sql, withArgumentsIn: nil) {
                
                //  遍历结果集
                while resuSet.next() {
                
                    // 表示可以获取一条记录 -> [String: Any]
                    var dic = [String: Any]()
                    //  怎么能够获取这一条记录的键值对呢
                    //  获取列数
                    let colCount = resuSet.columnCount()
                    //  遍历列数获取对应的key和value
                    for i in 0..<colCount {
                    
                        //  获取列名
                        let colName = resuSet.columnName(for: i)!
                        //  获取列值
                        let colValue = resuSet.object(forColumnIndex: i)!
                        
                        //  添加键值对
//                        dic[colName] = colValue
                        dic.updateValue(colValue, forKey: colName)
                    
                    }
                    
                    
                    //  添加到数组里面
                    tempArray.append(dic)
                    
                }
            
            
            }
        }
        
        //  返回数组字典
        return tempArray
        
        
    }
    
    
    //  修改操作
    func update() {
        //  准备sql
        let sql = "UPDATE T_PERSON SET NAME = ?, AGE = ? WHERE ID = ?"
        //  执行sql
        queue.inDatabase { (db) in
            let result = db?.executeUpdate(sql, withArgumentsIn: ["杨幂", 28, 1])
            
            if result == true {
                
                print("修改成功")
            } else {
                print("修改失败")
            }
        }
    }
    
    //  删除
    func delete() {
        //  准备sql
        let sql = "DELETE FROM T_PERSON WHERE ID = 2"
        //  执行sql
        queue.inDatabase { (db) in
            let result = db?.executeUpdate(sql, withArgumentsIn: nil)
            if result == true {
                print("删除成功")
            } else {
                print("删除失败")
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
