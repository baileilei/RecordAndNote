//
//  HMStatusListViewModel.swift
//  Weibo20
//
//  Created by HM on 16/9/23.
//  Copyright © 2016年 HM. All rights reserved.
//

import UIKit
import SDWebImage


//  封装首页微博数据网络请求 -> 首页的TableView
class HMStatusListViewModel: NSObject {
    //  关注用户的微博数据源
    lazy var statusList: [HMStatusViewModel] = [HMStatusViewModel]()
    
    //  加载首页微博数据
    //  isPullup 是否上拉加载
    func loadData(isPullup: Bool, callBack: @escaping (Bool, String)->()) {
        
        let accessToken = HMUserAccountViewModel.sharedUserAccountViewModel.accessToken!
        
        //  获取上拉加载请求需要的微博id
        var maxId: Int64 = 0
        //  获取下拉属性请求需要的微博id
        var sinceId: Int64 = 0
        if isPullup {
            //  上拉加载
            maxId = statusList.last?.status?.id ?? 0
            //  解决数据重复问题, 需要让其微博id减去1
            if maxId > 0 {
                maxId -= 1
            }
        
        } else {
            //  下拉刷新
            sinceId = statusList.first?.status?.id ?? 0
            
            
        }
        
        
        //  检测本地是否有缓存数据
//        let localArray = HMStatusDAL.checkCacheData(maxId: maxId, sinceId: sinceId)
//        print(localArray)
        
        
        var message: String = "没有加载到最新微博数据"
        HMStatusDAL.loadData(accessToken: accessToken, maxId: maxId, sinceId: sinceId) { (statusArray) in
            
//        }
//        HMNetworkTools.sharedTools.requestStatuses(accessToken: accessToken, maxId: maxId, sinceId: sinceId) { (response, error) in
//            if error != nil {
//                print("网络请求异常: \(error)")
//                callBack(false, message)
//                return
//            }
//            
//            //  代码执行到此表示网络请求成功
//            //            print(response)
//            
//            guard let dic = response as? [String: Any] else {
//                print("你不是一个正确的字典格式")
//                callBack(false, message)
//                return
//            }
//            
//            
//            
//            
//            guard let statusArray = dic["statuses"] as? [[String: Any]] else {
//                print("你不是一个正确的字典格式")
//                callBack(false, message)
//                return
//            }
//            
//            //  缓存新浪微博数据
////            HMStatusDAL.cacheData(statusDicArray: statusArray)
            
            //  代码执行到此表示字典的格式没有问题
            
            //            var tempArray = [HMStatus]()
            //            //  遍历数组字典
            //            for statusDic in statusArray {
            //                //  字典转模型
            //                let status = HMStatus(dic: statusDic)
            //                tempArray.append(status)
            //
            //            }
            
            
            //  记录返回的数组模型,重新加载数据
            
            //self.statusList = tempArray
            
            
            //  使用yymodel进行数组字典转成数组模型
            let statusArr = NSArray.yy_modelArray(with: HMStatus.self, json: statusArray) as! [HMStatus]
            
            var tempArray = [HMStatusViewModel]()
            
            //  创建调度组
            let group = DispatchGroup()
            
            //  遍历模型数组
            for status in statusArr {
                //  把模型转成viewModel让cell使用
                let viewModel = HMStatusViewModel(status: status)
                //viewModel.status = status
                tempArray.append(viewModel)
                
                
                //  判断是否有单张图片
                if status.pic_urls?.count == 1 {
                    //  原创微博配图等于1张,需要下载
                    
                    if let url = status.pic_urls?.first?.thumbnail_pic {
                        //  在调度组中执行任务
//                        DispatchQueue.global().async(group: group, qos: DispatchQoS.default, flags: [], execute: {
//                            SDWebImageManager.shared().downloadImage(with: URL(string: url), options: [], progress: nil, completed: { (image, error, _, _, url) in
//                                print("下载完成: \(url)")
//                            })
//                            
//                            
//                            print("哈哈")
//                        })
                       
                        
                        group.enter()
                        SDWebImageManager.shared().downloadImage(with: URL(string: url), options: [], progress: nil, completed: { (image, error, _, _, url) in
                            print("下载完成: \(url)")
                            group.leave()
                        })
                        
                        
                        

                        
                        
                    }
                    
                    
                }
                if status.retweeted_status?.pic_urls?.count == 1 {
                    //  转发微博图片等于1张,需要下载
                    
                    if let url = status.retweeted_status?.pic_urls?.first?.thumbnail_pic {
                        //  在调度组中执行任务
//                       DispatchQueue.global().async(group: group, qos: DispatchQoS.default, flags: [], execute: {
//                            SDWebImageManager.shared().downloadImage(with: URL(string: url), options: [], progress: nil, completed: { (image, error, _, _, url) in
//                                print("下载完成: \(url)")
//                            })
//                        
//                            print("嘿嘿")
//                        })
                        group.enter()
                        SDWebImageManager.shared().downloadImage(with: URL(string: url), options: [], progress: nil, completed: { (image, error, _, _, url) in
                            print("下载完成: \(url)")
                            group.leave()
                        })
                       
                    }
                    
                }
                
                
                
                
                
                
            }
            
            //  给数据源赋值
//            self.statusList = tempArray
            if isPullup {
                //  如果上拉加载需要把数据追加到原始数组后面
                self.statusList.append(contentsOf: tempArray)
            
            } else {
                //  下拉刷新
                self.statusList.insert(contentsOf: tempArray, at: 0)
            }
            
            //  判断服务器返回的数据个数是否大于0
            if tempArray.count > 0 {
                message = "加载了\(tempArray.count)条微博数据"
            }
            
            
            //  把获取到网络数据设置给stausList
            //self.statusList = statusArr
            
            //self.tableView.reloadData()
            //  数据加载完成进行数据回调
            
            //  要想执行数据回调, 前提单张图片全部下载完成,然后才能调用
            //  要使用调度组这个技术,等待其他任务完成以后再回调
            
            
//            group.notify(queue: DispatchQueue.main) {
//                print("任务完成")
//            }
            group.notify(queue: DispatchQueue.main, execute: {
                //  等待单张图片全部执行完成后,回调数据
                print("单张图片全部下载完成")
                 callBack(true, message)
//                DispatchQueue.main.asyncAfter(wallDeadline: DispatchWallTime.now() + 2, execute: {
//                    callBack(true, message)
//                })
                
                
            })
            
            
            
            
            
        }
        
        
    }
    

}
