//
//  HMHomeTableViewController.swift
//  Weibo20
//
//  Created by HM on 16/9/19.
//  Copyright © 2016年 HM. All rights reserved.
//

import UIKit
import YYModel

//  重用标记
private let HMHomeTableViewCellIndentifier = "HMHomeTableViewCellIndentifier"

class HMHomeTableViewController: HMVisitorTableViewController {

    //  MARK: --    懒加载
    //  记录数据源
    //lazy var statusList: [HMStatus] = [HMStatus]()
    
    //  使用对应的ViewModel对象
    fileprivate lazy var statusListViewModel: HMStatusListViewModel = HMStatusListViewModel()
    
    //  上拉加载
    fileprivate lazy var pullUpView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        view.color = UIColor.red
        return view
        
    }()
    
    fileprivate lazy var pullDownView: UIRefreshControl = {
        let view = UIRefreshControl()
        //  添加下拉刷新事件
        view.addTarget(self, action: #selector(pullDownRefreshing), for: .valueChanged)
        return view
    
    }()
    
    //  自定义下拉刷新控件
    fileprivate lazy var pullDownCtr: HMRefreshControl = {
        let view = HMRefreshControl()
        view.addTarget(self, action: #selector(pullDownRefreshing), for: .valueChanged)
        return view
    }()
    
    //  tipLabel
    fileprivate lazy var tipLabel: UILabel = {
        let label = UILabel(textColor: UIColor.white, fontSize: 12)
        label.backgroundColor = UIColor.orange
        label.textAlignment = .center
        label.text = "没有加载到最新的微博数据"
        label.isHidden = true
        return label
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !isLogin {
            visitorView?.updateVisitorInfo(message: nil, imageName: nil)
        } else {
            setupUI()
            setupTableView()
            //  表示登录, 加载微博数据
            loadData()
            
        }
    }
    
    //  添加控件设置约束
    private func setupUI() {
       
        if let nav = self.navigationController {
            //  把tipLabel添加到导航栏下面
            nav.view.insertSubview(tipLabel, belowSubview: nav.navigationBar)
            //  设置其与导航栏底部对象
            //  nav.navigationBar.frame.maxY获取最大y轴 -> swift 3.0
            tipLabel.frame = CGRect(x: 0, y: nav.navigationBar.frame.maxY - 35, width: nav.navigationBar.width, height: 35)
        }
       
    
    }
   
    
    
    //  设置UITableView的相关操作
    private func setupTableView() {
        //  UITableViewCell.self 表示获取 Class
        tableView.register(HMHomeTableViewCell.self, forCellReuseIdentifier: HMHomeTableViewCellIndentifier)
        //  设置行高-> 自动计算行高
        tableView.rowHeight = UITableViewAutomaticDimension
        
        //  预估行高
        tableView.estimatedRowHeight = 200
        //  去掉分割线
        tableView.separatorStyle = .none
        //  上拉加载视图
        tableView.tableFooterView = pullUpView
        
        //  下拉刷新视图
    
        //tableView.addSubview(pullDownView)
        
        //self.refreshControl = pullDownView
        
        //  添加自定义下拉刷新控件
        tableView.addSubview(pullDownCtr)
        
    }
    
    private func endRefreshing() {
        //  结束刷新
        pullUpView.stopAnimating()
        //  结束下拉刷新
        pullDownView.endRefreshing()
        //  结束自定义下拉结束
        pullDownCtr.endRefreshing()
    
    
    }
    //  下拉刷新操作
    @objc private func pullDownRefreshing() {
        
        print("下拉刷新")
        
       
        loadData()
       
        
        
    }
    
    //  开启tip动画
    private func startAnimation(message: String) {
        
        //  当前tipLabel如果显示表示正在执行动画,那么不需要再次执行
        if tipLabel.isHidden == false {
            return
        }
        
        
        tipLabel.text = message
        //  显示label
        tipLabel.isHidden = false
        
        UIView.animate(withDuration: 1, animations: {
            self.tipLabel.transform = CGAffineTransform(translationX: 0, y: self.tipLabel.height)
            
            }) { (_) in
                UIView.animate(withDuration: 1, animations: { 
                    self.tipLabel.transform = CGAffineTransform.identity
                    }, completion: { (_) in
                        self.tipLabel.isHidden = true
                })
        }
        
    
    
    }
    
    
    
    //  加载首页微博数据
    func loadData() {
        
        
        statusListViewModel.loadData(isPullup: pullUpView.isAnimating) { (isSuccess, message) in
            //  如果是上拉加载其执行tip动画
            if !self.pullUpView.isAnimating {
                self.startAnimation(message: message)
            }
            
            
            //  结束刷新
            self.endRefreshing()
            if isSuccess {
                self.tableView.reloadData()
            }
        }
        
        
        
        
        //  以下代码已经抽取到HMStatusListViewModel里面
        
//        let accessToken = HMUserAccountViewModel.sharedUserAccountViewModel.accessToken!
//        
//        HMNetworkTools.sharedTools.requestStatuses(accessToken: accessToken) { (response, error) in
//            if error != nil {
//                print("网络请求异常: \(error)")
//                return
//            }
//            
//            //  代码执行到此表示网络请求成功
////            print(response)
//            
//            guard let dic = response as? [String: Any] else {
//                print("你不是一个正确的字典格式")
//                return
//            }
//           
//            
//           
//            
//            guard let statusArray = dic["statuses"] as? [[String: Any]] else {
//                print("你不是一个正确的字典格式")
//                return
//            }
//            //  代码执行到此表示字典的格式没有问题
//            
////            var tempArray = [HMStatus]()
////            //  遍历数组字典
////            for statusDic in statusArray {
////                //  字典转模型
////                let status = HMStatus(dic: statusDic)
////                tempArray.append(status)
////            
////            }
//            
//            
//            //  记录返回的数组模型,重新加载数据
//            
//            //self.statusList = tempArray
//            
//            
//            //  使用yymodel进行数组字典转成数组模型
//            let statusArr = NSArray.yy_modelArray(with: HMStatus.self, json: statusArray) as! [HMStatus]
//            
//            self.statusList = statusArr
//            
//            self.tableView.reloadData()
//            
//            
//            
//            
//        }
        
        
    }
    
    
    
    
    
    
}

//  MARK: -- UITableViewDataSource
extension HMHomeTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statusListViewModel.statusList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HMHomeTableViewCellIndentifier, for: indexPath) as! HMHomeTableViewCell
        //  获取cell对应的ViewModel
        let viewModel: HMStatusViewModel = statusListViewModel.statusList[indexPath.row]
        //  绑定数据
        cell.statusViewModel = viewModel
        //  取消选中的颜色
        cell.selectionStyle = .none
        
        return cell
    }
    //  将要显示cell的时候判断是否是最后一个cell
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == statusListViewModel.statusList.count - 1 && !pullUpView.isAnimating {
            pullUpView.startAnimating()
            print("已经滚动到最后一个cell了")
            
            
            loadData()
        }
        
        
        
    }
    
    

}











