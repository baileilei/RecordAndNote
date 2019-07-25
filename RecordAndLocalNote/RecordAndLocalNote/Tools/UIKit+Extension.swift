//
//  UIKit+Extension.swift
//  RecordAndLocalNote
//
//  Created by g on 2019/7/24.
//  Copyright © 2019 g. All rights reserved.
//

import UIKit

extension UIBarButtonItem{
    
    convenience init(_ title:String,target:Any,action:Selector) {
        self.init()
        
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.setTitleColor(UIColor.orange, for: .highlighted)
        
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.sizeToFit()
        button.addTarget(target, action: action, for: .touchUpInside)
        
        customView = button
    }
}

extension UIView {
    
}
