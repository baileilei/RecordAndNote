//
//  Date+Extension.swift
//  Weibo20
//
//  Created by HM on 16/9/27.
//  Copyright © 2016年 HM. All rights reserved.
//

import Foundation

extension Date {
    //  在swift 3.0 类方法使用static关键字, 在swift 2.0 使用class
    static func sinaDate(createAt: String) -> Date {
        //  代码到此表示时间字符串不为nil
        let dt = DateFormatter()
        //  指定格式化方式
        dt.dateFormat = "EEE MMM dd HH:mm:ss z yyyy"
        //  指定本地化信息
        dt.locale = Locale(identifier: "en_US")
        //  把字符串转成时间对象
        let createAtDate = dt.date(from: createAt)!
        
        return createAtDate
    }
    
//    func  aa(createDate: Date) -> String {
//        return ""
//    }
    
    
    //  扩展
    var sinaDateString: String {
        
        let dt = DateFormatter()
        //  指定本地化信息
        dt.locale = Locale(identifier: "en_US")
        if isThisYear(createAtDate: self) {
            
            //是今年
            print("是今年")
            //  日历对象
            let currentCalendar = Calendar.current
            if currentCalendar.isDateInToday(self) {
                //  表示今天createAtDate.timeIntervalSince(<#T##date: Date##Date#>)
                let timeinterVal: TimeInterval = abs(self.timeIntervalSinceNow)
                if timeinterVal < 60 {
                    return "刚刚"
                } else if timeinterVal < 3600 {
                    let result = timeinterVal / 60
                    return "\(Int(result))分钟前"
                } else {
                    let result = timeinterVal / 3600
                    return "\(Int(result))小时前"
                }
                
                
                
                
            } else if currentCalendar.isDateInYesterday(self) {
                //  表示昨天
                dt.dateFormat = "昨天 HH:mm"
            } else {
                //  其它
                dt.dateFormat = "MM-dd HH:mm"
            }
            
            
        } else {
            //  不是今年
            dt.dateFormat = "yyyy-MM-dd HH:mm"
            
        }
        
        
        
        
        return dt.string(from: self)

        
    }
    
    
    //  根据指定时间对象判断是否是今年
    private func isThisYear(createAtDate: Date) -> Bool {
        let dt = DateFormatter()
        //  指定格式化方式
        dt.dateFormat = "yyyy"
        //  指定本地化信息
        dt.locale = Locale(identifier: "en_US")
        //  获取发微博时间的年份
        let createAtYear = dt.string(from: createAtDate)
        //  获取当前时间的年份
        let currentDateYear = dt.string(from: Date())
        //  判断时间年份是否相同
        return createAtYear == currentDateYear
        
    }
    

}





