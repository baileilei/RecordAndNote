//
//  StatusViewController.swift
//  RecordAndLocalNote
//
//  Created by g on 2019/7/24.
//  Copyright © 2019 g. All rights reserved.
//

import UIKit

class StatusViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "朋友圈"
        
        loadData()
        
        let tableView = UITableView(frame: view.bounds, style: .plain)
        view.addSubview(tableView)
        
        writeToPlist()
        
    }
    
    //http://www.hangge.com/blog/cache/detail_719.html
    func writeToPlist() -> Void {
        var json : [[String : String]] = [
        [
            "name" : "json1",
            "title" : "测试1",
            ],
        [
            "name" : "json2",
            "title" : "测试2",
            ],
        [
            "name" : "json3",
            "title" : "测试3",
            ]
        ]
        
        var data = NSMutableData()
        data.write(toFile: <#T##String#>, atomically: <#T##Bool#>)
        
        
//        JSONSerialization.write
        
        
    }
    
    
    func loadData() -> Void {
        let path = Bundle.main.path(forResource: "test.plist", ofType: nil)
        print(path)
        
        if let jsonPath = path {
            let jsonData = NSData(contentsOfFile: jsonPath)
//            try! let jsonData = Data(contentsOf: URL.init(fileURLWithPath: jsonPath))
//            print(jsonData)
            do{
                let dictArr = try JSONSerialization.jsonObject(with: jsonData! as Data, options: .mutableContainers)
                
                for dict in dictArr as! [[String:String]]{
                    print(dict)
                }
            }catch{
                print(error)
            }
        }
        
    }

}
