//
//  StatusViewController.swift
//  RecordAndLocalNote
//
//  Created by g on 2019/7/24.
//  Copyright © 2019 g. All rights reserved.
//

import UIKit

class StatusViewController: UIViewController {
    
    var dataModel = DataModel()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "朋友圈"
        
        let rightItem = UIBarButtonItem.init("test", target: self, action: #selector(test))
        navigationItem.rightBarButtonItem = rightItem
        
        
        let tableView = UITableView(frame: view.bounds, style: .plain)
//        tableView.delegate = self as! UITableViewDelegate
        tableView.dataSource = self as UITableViewDataSource
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "friendStatus")
        view.addSubview(tableView)
        
        writeToPlist()
        
    }
    
    @objc func test() {
        
        
    }
    
    func testImageSave() {
        let userDefault = UserDefaults.standard
        
        //UIImage对象存储
        //将对象转换成Data流
        let image1 = UIImage(named: "apple.jpg")!
        let image2 = UIImage(cgImage: image1.cgImage!, scale: image1.scale,
                             orientation: image1.imageOrientation)
        let imageData = NSKeyedArchiver.archivedData(withRootObject: image2)
        //存储Data对象
        userDefault.set(imageData, forKey: "imageData")
        
        //UIImage对象读取
        //获取Data
        let objData = userDefault.data(forKey: "imageData")
        //还原对象
        let myImage = NSKeyedUnarchiver.unarchiveObject(with: objData!) as? UIImage
        print(myImage)
    }
    
    //http://www.hangge.com/blog/cache/detail_719.html
    func writeToPlist() -> Void {
        
        dataModel.userList.append(UserInfo(name: "zhangsan", phone: "1234"))
        dataModel.userList.append(UserInfo(name: "lisi", phone: "1212"))
        dataModel.userList.append(UserInfo(name: "wangwu", phone: "1233"))
        
        dataModel.saveData()
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

extension StatusViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataModel.userList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendStatus", for: indexPath)
        cell.textLabel?.text = self.dataModel.userList[indexPath.row].name
        
        return cell
        
    }
}
