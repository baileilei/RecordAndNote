//
//  HMSearchView.swift
//  Weibo20
//
//  Created by HM on 16/9/19.
//  Copyright © 2016年 HM. All rights reserved.
//

import UIKit

class HMSearchView: UIView {

    @IBOutlet weak var searchTextFieldRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchButton: UIButton!
   
    @IBOutlet weak var searchTextField: UITextField!

    @IBAction func editBeginAction(_ sender: AnyObject) {
        
        searchTextFieldRightConstraint.constant = searchButton.width
        
        UIView.animate(withDuration: 0.3) { 
            self.layoutIfNeeded()
        }
        
        
    }
    
    @IBAction func searchButtonAction(_ sender: AnyObject) {
        //  失去第一响应者
        searchTextField.resignFirstResponder()
        searchTextFieldRightConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
        
        
        
    }
    //  使用类方法创建xib对象
    class func searchView() -> HMSearchView {
        
        return UINib(nibName: "HMSearchView", bundle: nil).instantiate(withOwner: nil, options: nil).last! as! HMSearchView        
    }
    
//    override func awakeFromNib() {
//        searchTextField.layer.borderColor = UIColor.magenta.cgColor
//        searchTextField.layer.borderWidth = 2
//        searchTextField.layer.cornerRadius = 5
//        searchTextField.layer.masksToBounds = true
//    }
    
    
    
    
}
