//
//  HMComposeView.swift
//  Weibo20
//
//  Created by HM on 16/9/27.
//  Copyright © 2016年 HM. All rights reserved.
//

import UIKit
import pop

//  撰写视图罩层
class HMComposeView: UIView {

    //  MARK: --    懒加载控件
    private lazy var sloganImageView: UIImageView = UIImageView(image: UIImage(named: "compose_slogan"))
    
    //  记录6个菜单按钮
    private lazy var buttonArray: [HMComposeButton] = [HMComposeButton]()
    //  取到plist对象的模型数据
    private lazy var composeMenuArray: [HMComposeMenu] = self.loadComposePlistData()
    
    //  记录当前出入的控制器
    var target: UIViewController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.size = CGSize(width: ScreenWidth, height: ScreenHeight)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = RandomColor()
        //  获取模糊效果图片
        let image = UIImage.screenShot().applyLightEffect()
        let bgImageView = UIImageView(image: image)
        addSubview(bgImageView)
        
        addSubview(sloganImageView)
        
        sloganImageView.snp_makeConstraints { (make) in
            make.top.equalTo(self).offset(100)
            make.centerX.equalTo(self)
        }
        
        
       
        addChildButton()
        
       
    
    }
    
    //  开动弹簧动画效果
    private func startPopAnimation(isUp: Bool) {
        //  如果是向下的弹簧动画,那么数组需要反转
        if isUp == false {
            //  数组反转
            buttonArray = buttonArray.reversed()
        }
        
        //  遍历数组执行pop动画
        for (i, button) in buttonArray.enumerated() {
            
            let popAnimation = POPSpringAnimation(propertyNamed: kPOPViewCenter)
            //  目的地 -> toValue 不能直接传入结构体,需要转成对象
            if isUp {
                popAnimation?.toValue = NSValue(cgPoint: CGPoint(x: button.centerX, y: button.centerY - 350))
            } else {
                popAnimation?.toValue = NSValue(cgPoint: CGPoint(x: button.centerX, y: button.centerY + 350))
            }
            
            //  动画的初始速度  [0, 20]
            popAnimation?.springSpeed = 10
            //  抖动幅度 [0, 20]
            popAnimation?.springBounciness = 10
            //  开始动画时间 CACurrentMediaTime-> 系统的绝对时间
            popAnimation?.beginTime = CACurrentMediaTime() + Double(i) * 0.025
            //  执行动画
            button.pop_add(popAnimation, forKey: nil)
            
        }
        
    
    }
    
    
    
    //  添加子按钮
    private func addChildButton() {
        //  按钮的宽度
        let buttonWidth: CGFloat = 80
        //  按钮的高度
        let buttonHeight: CGFloat = 110
        //  按钮的间距
        let buttonMargin: CGFloat = (width - 3 * buttonWidth) / 4
        
        for i in 0..<composeMenuArray.count {
            //  列的索引
            let colIndex = i % 3
            //  行的索引
            let rowIndex = i / 3
            //  获取指定下标模型
            let composeMenu = composeMenuArray[i]
            let button = HMComposeButton()
            //  设置tag值
            button.tag = i
            //  添加点击事件
            button.addTarget(self, action: #selector(buttonAction(btn:)), for: .touchUpInside)
            button.x = CGFloat(colIndex) * buttonWidth + CGFloat(colIndex + 1) * buttonMargin
            button.y = CGFloat(rowIndex) * buttonHeight + CGFloat(rowIndex) * buttonMargin + ScreenHeight
            
            button.size = CGSize(width: buttonWidth, height: buttonHeight)
            button.setImage(UIImage(named: composeMenu.icon!), for: .normal)
            button.setTitle(composeMenu.title!, for: .normal)
            
            
            addSubview(button)
            buttonArray.append(button)
        }
    
    }
    
    
    //  代码抽取到UIImage+Extension
    
//    //  截取当前window的图片
//    private func screenShot() -> UIImage {
//        
//        let window = UIApplication.shared.keyWindow!
//        //  开启图片上下文
//        UIGraphicsBeginImageContext(window.size)
//        
//        //  afterScreenUpdates -> false 表示不需要等待更新后去绘制
//        window.drawHierarchy(in: window.bounds, afterScreenUpdates: false)
//        
//        //  从图片上下文中获取图片
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        
//        
//        UIGraphicsEndImageContext()
//        
//        return image!
//    }
    
    
    //  MARK: --    点击事件处理
    @objc private func buttonAction(btn: UIButton) {
        
        UIView.animate(withDuration: 0.25, animations: { 
            for button in self.buttonArray {
                button.alpha = 0.2
                if button == btn {
                    //  表示同一个按钮,那么执行放大动画
                    button.transform = CGAffineTransform(scaleX: 2, y: 2)
                } else {
                    //  执行缩小动画
                    button.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
                }
            }
            
            
            
            
            }) { (_) in
                
                UIView.animate(withDuration: 0.25, animations: { 
                    for button in self.buttonArray {
                        //  回到原始大小
                        button.transform = CGAffineTransform.identity
                        button.alpha = 1
                    }
                    
                    }, completion: { (_) in
                        //  弹出控制器
                        
                        //  1. 自定义的类直接通过类名转成相应class不行 
                                //  -> 解决办法 需要加上命名空间(工程名)
                        //  2. 转成的class不能直接初始化,需要转成相应的类型 (类名.Type)
                        
                        //  3. 最后就通过class转成相应的对象
                        
                        
//                        let name = "Weibo20.HMComposeViewController"
//                        let classType = NSClassFromString(name)! as! UIViewController.Type
//                        //  初始化对应的对象
//                        let vc = classType.init()
//                        print(vc)
                        
                        
                        //  获取指定模型
                        let composeMenu = self.composeMenuArray[btn.tag]
                        //  获取对应的class
                        let classType = NSClassFromString(composeMenu.className!)! as! UIViewController.Type
                        //  根据class创建对象
                        let vc = classType.init()
                        //  vc放到导航控制器里面
                        let nav = HMNavigationViewController(rootViewController: vc)
                        self.target?.present(nav, animated: true, completion: {
                            //  移除罩层
                            self.removeFromSuperview()
                        })
                        
                        
                })
                
                
                
        }
        
    
    }
    
    func show(target: UIViewController) {
        self.target = target
        //  最上层的window
//        let window = UIApplication.shared.windows.last!
//        window.addSubview(self)
        
        target.view.addSubview(self)
        //  开启弹簧动画效果
        startPopAnimation(isUp: true)
        
    }
    
    //  读取plist文件数据
    private func loadComposePlistData() -> [HMComposeMenu] {
        //  获取plist文件的路径
        let path = Bundle.main.path(forResource: "compose.plist", ofType: nil)!
        //  获取到plist文件里面的数据
        let dicArray = NSArray(contentsOfFile: path)!
    
        
        let modelArray = NSArray.yy_modelArray(with: HMComposeMenu.self, json: dicArray)! as! [HMComposeMenu]
        
        
        return modelArray
        
        
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       
        
        startPopAnimation(isUp: false)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) { 
            self.removeFromSuperview()
        }
        
        
    }
    
    
    
    
    

}
