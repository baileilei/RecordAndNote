//
//  HMNetworkTools.swift
//  Swift网络请求封装
//
//  Created by HM on 16/9/20.
//  Copyright © 2016年 HM. All rights reserved.
//

import UIKit
import AFNetworking

//  网络请求类型
enum RequestType: Int {
    // get请求
    case GET
    // post请求
    case POST
}

//  网络请求封装类
class HMNetworkTools: AFHTTPSessionManager {

    
    //  闭包回调类型的别名
    typealias CallBackType = (Any?, Error?)->()
    
    //  单例全局访问点
    static let sharedTools: HMNetworkTools = {
        let tools = HMNetworkTools()
        //  添加可以接受的响应数据类型
        tools.responseSerializer.acceptableContentTypes?.insert("text/html")
        tools.responseSerializer.acceptableContentTypes?.insert("text/plain")
        return tools
        
        
    
    }()
    
    //  封装get/post请求
    fileprivate func request(type: RequestType, url: String, params: Any?, callBack: @escaping CallBackType) {
        
        if type == .GET {
            get(url, parameters: params, progress: nil, success: { (_, response) in
                    callBack(response, nil)
                }, failure: { (_, error) in
                    callBack(nil, error)
            })
            
        } else {
            post(url, parameters: params, progress: nil, success: { (_, response) in
                callBack(response, nil)
                }, failure: { (_, error) in
                callBack(nil, error)
            })
            
        }
        
    }
    
    
    
    
}

//  发微博相关接口
extension HMNetworkTools {
    
    func upload(access_token: String, status: String, image: UIImage, callBack: @escaping CallBackType) -> Void {
        //  准备url地址
        let url = "https://upload.api.weibo.com/2/statuses/upload.json"
        //  准备参数
        let params = [
            "access_token": access_token,
            "status": status
        ]
        
        //let imageData = UIImagePNGRepresentation(image)!
        //  compressionQuality 质量系数0-1, 质量系数越大表示图片越清晰
        let imageData = UIImageJPEGRepresentation(image, 0.5)!
        
        
        
        
        //  上传请求接口
        post(url, parameters: params, constructingBodyWith: { (formData) in
            
            //  withFileData 图片的二进制数据
            //  name 表示服务端获取图片的所需要的参数
            //  fileName 表示图片的文件名字 -> 可以随便写,因为服务的会给我们生成一个唯一的图片名
            //  mimeType 图片的资源
            formData.appendPart(withFileData: imageData, name: "pic", fileName: "test", mimeType: "image/jpeg")            
            }, progress: nil, success: { (_, response) in
                callBack(response, nil)
            }) { (_, error) in
                callBack(nil, error)
        }
        
    }
    
    
    //  option + cmd + /
    ///
    ///  发送文字微博接口
    /// - parameter access_token: 令牌
    /// - parameter status:       微博内容
    /// - parameter callBack:     闭包回调
    func update(access_token: String, status: String, callBack: @escaping CallBackType) -> Void {
        //  准备url地址
        let url = "https://api.weibo.com/2/statuses/update.json"
        //  准备参数
        let params = [
            "access_token": access_token,
            "status": status
        ]
        //  执行请求
        request(type: .POST, url: url, params: params, callBack: callBack)
        
    }
    
    

}



//  MARK: -- 微博首页相关接口
extension HMNetworkTools {
    //  获取用户所关注的微博数据
    func requestStatuses(accessToken: String, maxId: Int64, sinceId: Int64, callBack: @escaping CallBackType) {
        //  准备接口地址
        let url = "https://api.weibo.com/2/statuses/friends_timeline.json"
        //  准备参数
        let params: [String: Any] = [
            "access_token": accessToken,
            "max_id": maxId,
            "since_id": sinceId
        ]
        
        print("----------")
        print(url + "?access_token=\(accessToken)")
        print("----------")
        
        //  执行接口请求
        request(type: .GET, url: url, params: params, callBack: callBack)
        
    }

}




//  MARK: -- OAuth登录相关接口
extension HMNetworkTools {
    
    //  通过Accesstoken获取用户信息
    func requestUserInfo(accessToken: String, uid: Int64, callBack: @escaping CallBackType) -> Void {
        //  请求接口地址
        let url = "https://api.weibo.com/2/users/show.json"
        //  准备请求需要的参数
        let params: [String: Any] = [
            "access_token": accessToken,
            "uid": uid
        ]
       
        request(type: .GET, url: url, params: params, callBack: callBack)
        
        
    }
    
    

    //  根据code获取accesstoken
    func requestAccessToken(code: String, callBack: @escaping CallBackType) {
        //  请求接口地址
        let url = "https://api.weibo.com/oauth2/access_token"
        //  准备请求需要的参数
        let params = [
            "client_id": WeiboAppKey,
            "client_secret": WeiboAppSecret,
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": WeiboRedirect_Uri
            
        ]
        //  使用封装好的get/post请求
        request(type: .POST, url: url, params: params, callBack: callBack)
    }
    

}










