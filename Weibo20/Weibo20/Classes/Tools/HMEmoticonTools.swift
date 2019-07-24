//
//  HMEmoticonTools.swift
//  Weibo20
//
//  Created by HM on 16/10/6.
//  Copyright © 2016年 HM. All rights reserved.
//

import UIKit
//  每页显示20个表情元素
let NumberOfPage = 20
//  最近表情归档和解档路径
let RecentDataPath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last! as NSString).appendingPathComponent("recentEmoticonArray.archiver")



//  读取表情工具类
class HMEmoticonTools: NSObject {

    static let shareTools: HMEmoticonTools = HMEmoticonTools()
    
    //  构造函数私有化
    private override init() {
        super.init()
        
       
        
        
    }
    //  获取bundle对象
    lazy var emoticonsBundle: Bundle = {
        //  获取emoticons.boudle的路径
        
        let path = Bundle.main.path(forResource: "Emoticons.bundle", ofType: nil)!
        
        //  通过路径创建emoticonbundle对象
        let bundle = Bundle(path: path)!
        
        return bundle
    
    }()
    
    
    //  给表情视图提供的数据结构
    lazy var allEmoticonsArray: [[[HMEmoticon]]] = {
    
        return [
            [self.recentEmoticonArray],
            self.sectionEmoticon(emoticonArray: self.defaultEmoticonsArray),
            self.sectionEmoticon(emoticonArray: self.emojiEmoticonsArray),
            self.sectionEmoticon(emoticonArray: self.lxhEmoticonsArray),
        ]
    
    }()
    
    //  最近表情
    private lazy var recentEmoticonArray: [HMEmoticon] = {
            //  获取本地最近表情数据
        if let localRecentData = self.loadRecentEmoticonArray() {
            //  本地有最近表情数据,那么直接返回最近表情数据
            return localRecentData
        } else {
            //  本地没有最近表情,返回空数组
            let emoticonArray = [HMEmoticon]()
            return emoticonArray
        }
        
        
        
    }()
    
    
    //  获取默认表情数据
    private lazy var defaultEmoticonsArray: [HMEmoticon] = {
        
        return self.loadEmoticonsArray(folderName: "default", fileName: "info.plist")
        
    }()
    
    //  获取emoji表情数据
    private lazy var emojiEmoticonsArray: [HMEmoticon] = {
        
        return self.loadEmoticonsArray(folderName: "emoji", fileName: "info.plist")
        
    }()
    
    //  获取浪小花表情数据
    private lazy var lxhEmoticonsArray: [HMEmoticon] = {
        
        return self.loadEmoticonsArray(folderName: "lxh", fileName: "info.plist")
        
    }()
    
    
    //  读取表情数据
    private func loadEmoticonsArray(folderName: String, fileName: String) -> [HMEmoticon] {
        //  self.emoticonsBundle.path(forResource: xxx)  可以透过两次文件夹 (Contents/Resources)
        //  获取info.plist文件路径
        let subPath = folderName + "/" + fileName
        let path = self.emoticonsBundle.path(forResource: subPath, ofType: nil)!
        
        //  获取资源数据
        let dicArray = NSArray(contentsOfFile: path) as! [[String: Any]]
        
        //  使用yymodel把字典转成模型
        let modelArray = NSArray.yy_modelArray(with: HMEmoticon.self, json: dicArray) as! [HMEmoticon]
        
        //  遍历数组模型,判断如果是图片类型,需要拼接路径
        for model in modelArray {
            if model.type == "0" {
                //  表示图片, 需要拼接完整路径
               
                
                let imagePath = self.emoticonsBundle.path(forResource: folderName, ofType: nil)! + "/" + model.png!
                //  设置图片的全路径
                model.path = imagePath
                //  设置图片对应的文件夹名字
                model.folderName = folderName
            }
            
        
        }
        
        
        
        return modelArray
    
    }
    
    
    //  通过表情数组拆分成二维数组
    private func sectionEmoticon(emoticonArray: [HMEmoticon]) -> [[HMEmoticon]] {
    
        //   根据数组个数计算页数
        let pageCount = (emoticonArray.count - 1) / NumberOfPage + 1
        
        var tempArray = [[HMEmoticon]]()
        
        //  遍历页数,截取相应数据
        for i in 0..<pageCount {
            
            //  开始截取的索引
            let loc = i * NumberOfPage
            //  截取的长度
            var len = NumberOfPage
            //  表示数组越界
            if loc + len > emoticonArray.count {
                //  获取截取剩余个数
                len = emoticonArray.count - loc
            }
            
            
            let subArray = (emoticonArray as NSArray).subarray(with: NSMakeRange(loc, len)) as! [HMEmoticon]
            
            tempArray.append(subArray)
        }
        return tempArray
        
    
    }
    
    //  根据点击的表情模型保存到最近表情这组数据里面
    func saveRecentEmoticon(emoticon: HMEmoticon) {
        
//        recentEmoticonArray.append(emoticon)
        //  1. 添加表情模型之前判断最近表情这组数据里面是否已经存在对应的表情, 如果存在删除指定表情
        for (i, etn) in recentEmoticonArray.enumerated() {
            
            if emoticon.type == "0" {
                //  表示图片,判断表情描述是否相同
                
                if etn.chs == emoticon.chs {
                    //  在最近表情数组里面找了这个表情
                    recentEmoticonArray.remove(at: i)
                    break
                }
                
            } else {
                //  表示emoji, 判断code是否相同
                
                if etn.code == emoticon.code {
                    recentEmoticonArray.remove(at: i)
                    break
                }
                
            }
        }
        
        //  2. 点击表情添加到最近表情数组的第一个元素
        recentEmoticonArray.insert(emoticon, at: 0)
        
        
        //  3. 如果超过20个表情,删除最近表情里面的最后一个元素
        while recentEmoticonArray.count > 20 {
            //  删除最后一个元素
            recentEmoticonArray.removeLast()
        }
        
        
        //  4. 更新数据源 (allEmoticonsArray)
        allEmoticonsArray[0][0] = recentEmoticonArray
        
        
        //  5. 把最近表情进行归档
        
        print(RecentDataPath)
        
        //  归档
        NSKeyedArchiver.archiveRootObject(recentEmoticonArray, toFile: RecentDataPath)
        
        
        
        
    }
    
    //  获取沙盒路径最近表情数据
    private func loadRecentEmoticonArray() -> [HMEmoticon]? {
        
        return NSKeyedUnarchiver.unarchiveObject(withFile: RecentDataPath) as? [HMEmoticon]

    }
    
    
    //  根据表情描述查找默认表情数组和浪小花表情数组里面的元素
    func selectedEmoticon(chs: String) -> HMEmoticon? {
        
        //  默认表情里面找
        for emoiticon in defaultEmoticonsArray {
            if emoiticon.chs == chs {
                return emoiticon
            }
        }
        
        //  浪小花表情里面找
        for emoticon in lxhEmoticonsArray {
            if emoticon.chs == chs {
                return emoticon
            }
        }
        
        
        return nil
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
}
