//
//  HMComposeViewController.swift
//  Weibo20
//
//  Created by HM on 16/9/28.
//  Copyright © 2016年 HM. All rights reserved.
//

import UIKit
import SVProgressHUD

//  撰写控制器
class HMComposeViewController: UIViewController {

    //  MARK: -- 懒加载
    private lazy var sendButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(btnSendAction), for: .touchUpInside)
        button.setBackgroundImage(UIImage(named: "common_button_orange"), for: .normal)
        button.setBackgroundImage(UIImage(named: "common_button_orange_highlighted"), for: .highlighted)
        button.setBackgroundImage(UIImage(named: "common_button_white_disable"), for: .disabled)
        button.setTitle("发送", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitleColor(UIColor.gray, for: .disabled)
        button.size = CGSize(width: 45, height: 35)
        return button
    }()
    //  标题
    private lazy var titleLabel: UILabel = {
        let label = UILabel(textColor: UIColor.darkGray, fontSize: 16)
      
        if let name = HMUserAccountViewModel.sharedUserAccountViewModel.userAccount?.name {
            //  通过富文本设置AttributedText属性
            
            let result = "发微博\n" + name
            //  获取指定内容的范围
            let range = (result as NSString).range(of: name)
            
            
            //  创建富文本
            let attributedStr: NSMutableAttributedString = NSMutableAttributedString(string: result)
            attributedStr.addAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 12), NSForegroundColorAttributeName: UIColor.brown], range: range)
            
            label.attributedText = attributedStr
            
            
        } else {
            label.text = "发微博"
        }
        
        //  多行显示
        label.numberOfLines = 0
        label.textAlignment = .center
        label.sizeToFit()
        return label
    }()
    //  输入内容的文本框
    fileprivate lazy var textView: HMComposeTextView =  {
        let view = HMComposeTextView()
        view.placeHolder = "别哭泣,老王会笑~别哭泣,老王会笑~别哭泣,老王会笑~别哭泣,老王会笑~别哭泣,老王会笑~别哭泣,老王会笑~别哭泣,老王会笑~别哭泣,老王会笑~"
        view.font = UIFont.systemFont(ofSize: 14)
        view.delegate = self
        //  垂直方向弹簧效果开启
        view.alwaysBounceVertical = true
        return view
    }()
    //  toolbar
    fileprivate lazy var toolBar: HMComposeToolBar = {
        let view = HMComposeToolBar()
        return view
    }()
    //  配图
    fileprivate lazy var pictureView: HMComposePictureView = {
        let view = HMComposePictureView()
        view.backgroundColor = self.textView.backgroundColor
        return view
    }()
    
    //  表情键盘
    fileprivate lazy var emoticonKeyBoard: HMEmoticonKeyBoard = {
        let view = HMEmoticonKeyBoard()
        //  设置大小
        view.size = CGSize(width: self.textView.width, height: 216)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
    }
    
    private func setupNavUI() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", target: self, action: #selector(cancelAction))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: sendButton)
        //  设置不可以状态
        navigationItem.rightBarButtonItem?.isEnabled = false
        navigationItem.titleView = titleLabel
    }
    
    //  添加控件设置约束
    private func setupUI() {
        //  监听键盘的改变
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardFrameChange(noti:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        //  监听表情按钮的点击
        NotificationCenter.default.addObserver(self, selector: #selector(didSelectedEmoticonNoti(noti:)), name: NSNotification.Name(DidSelectedEmoticonNotification), object: nil)
        
        //  监听删除表情按钮的点击
        NotificationCenter.default.addObserver(self, selector: #selector(didSelectedDeleteEmoticonNoti), name: NSNotification.Name(DidSelectedDeleteEmoticonNotification), object: nil)
        setupNavUI()
        
        view.backgroundColor = UIColor.white
        view.addSubview(textView)
        view.addSubview(toolBar)
        textView.addSubview(pictureView)
        textView.snp_makeConstraints { (make) in
            make.top.equalTo(view)
            make.left.equalTo(view)
            make.trailing.equalTo(view)
            make.bottom.equalTo(toolBar.snp_top)
        }
        
        toolBar.snp_makeConstraints { (make) in
            make.bottom.equalTo(view)
            make.leading.equalTo(textView)
            make.trailing.equalTo(textView)
            make.height.equalTo(35)
        }
        
        pictureView.snp_makeConstraints { (make) in
            make.centerX.equalTo(textView)
            make.top.equalTo(textView).offset(100)
            make.width.equalTo(textView).offset(-20)
            make.height.equalTo(textView.snp_width).offset(-20)
        }
        
        toolBar.callBack = { [weak self] (type: HMComposeToolBarButtonType) in
            switch type {
            case .picture:
                print("图片")
                self?.didSelectedPicture()
            case .mention:
                print("@")
            case .trend:
                print("#")
            case .emoticon:
                print("表情")
                self?.didSelectedEmoticon()
            case .add:
                print("加号")
         
                
            }
        
        }
        //  设置打开图片浏览器的闭包
        pictureView.lastCellCallBack = { [weak self] in
            //  打开图片浏览器
            self?.didSelectedPicture()
        }
        
        
    
    }
    
    //  MARK: --    点击事件处理
    
    @objc private func btnSendAction() {
        
        
        let accessToken = HMUserAccountViewModel.sharedUserAccountViewModel.userAccount?.access_token
        let text = textView.emoticonText //textView.text!
        
        //  遍历富文本通过文本附件获取对应表情模型
        
        //  通过指定的范围遍历富文本
        
        // info 表示匹配的结果
        //  range 匹配的范围
        
//        var result = ""
//        textView.attributedText.enumerateAttributes(in: NSMakeRange(0, textView.attributedText.length), options: []) { (info, range, _) in
//            
//        
//            
//            if let attachement = info["NSAttachment"] as? HMTextAttachment {
//                //  能够获取文本附件表示是图片
//                let chs = attachement.emoticon?.chs
//                result += chs!
//            
//            } else {
//                //  表示文本
//                //  通过范围截取富文本对应的文本内容
//                let text = textView.attributedText.attributedSubstring(from: range).string
//                result += text
//            }
//            
//            
//            
//            
//        }
        
       
        
        
    

        
        
        
        if pictureView.images.count > 0 {
            
            let firstImage = pictureView.images.first!
            
           HMNetworkTools.sharedTools.upload(access_token: accessToken!, status: text, image: firstImage, callBack: { (response, error) in
            
                if error != nil {
                    SVProgressHUD.showError(withStatus: "发送失败")
                    print(error)
                    return
                }
            
                //  上传成功
                SVProgressHUD.showSuccess(withStatus: "发送成功")
            
            
           })
            
            
            
        } else {
            
           
            
            SVProgressHUD.show()
            HMNetworkTools.sharedTools.update(access_token: accessToken!, status: text) { (response, error) in
                if error != nil {
                    SVProgressHUD.showError(withStatus: "网络请求异常!")
                    return
                }
                
                //  代码执行到此,表示发送成功
                SVProgressHUD.showSuccess(withStatus: "发送成功!")
            }
            
        }
        
        
        
       
    
    }
    
    @objc private func cancelAction() {
        //  textView失去第一响应者
        self.view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    //  MARK: --    监听删除表情按钮的点击方法
    @objc private func didSelectedDeleteEmoticonNoti() {
        
        //  删除内容
        textView.deleteBackward()
    
    }
    
    
    //  MARK: --    监听表情按钮点击的方法
    @objc private func didSelectedEmoticonNoti(noti: Notification) {
        //  获取表情模型
        guard let emoticon = noti.object as? HMEmoticon else {
            return
        }
        
        textView.insertEmoticon(emoticon: emoticon)
        
        
        //  每次点击一个表情,保存到最近表情这组数据里面
        HMEmoticonTools.shareTools.saveRecentEmoticon(emoticon: emoticon)
        
        //  通知表情视图(collectionView刷新数据)
        emoticonKeyBoard.reloadRecentData()
        
        
        //  代码已经抽取HMComposeTextView+Extension
//        if emoticon.type == "0" {
//            //  点击图片表情
////            let chs = emoticon.chs!
//            
////            textView.insertText(chs)
//            //  想要显示图片,需要设置富文本
//            //  记录上一次富文本
//            let lastAttbutedString = NSMutableAttributedString(attributedString: textView.attributedText)
//            //  图片转成富文本的流程
//            //  1. 根据表情路径创建UIImage对象
//            let image = UIImage(named: emoticon.path!)
//            //  2. 根据UIImage对象创建文本附件(NSTextAttachment)
//            let attachment = NSTextAttachment()
//            //  设置图片大小
//            //  获取字体高度
//            let lineHeight = textView.font!.lineHeight
//            //  通过设置文本附件的bounds调整图片显示位置
//            //  设置bounds会影响子控件的显示位置
//            attachment.bounds = CGRect(x: 0, y: -4, width: lineHeight, height: lineHeight)
//            attachment.image = image
//            //  3. 根据文本附件创建富文本(NSAttributedString)
//            let attributedStr = NSAttributedString(attachment: attachment)
//            //  添加这次点击的表情富文本
////            lastAttbutedString.append(attributedStr)
//            
//            //  获取文本选中的范围
//            var selectedRange = textView.selectedRange
//            //  根据指定的选中范围替换富文本
//            lastAttbutedString.replaceCharacters(in: selectedRange, with: attributedStr)
//            
//            //  设置富文本的字体
//            lastAttbutedString.addAttribute(NSFontAttributeName, value: textView.font!, range: NSMakeRange(0, lastAttbutedString.length))
//            
//            //  4. 设置设置富文本
//            textView.attributedText = lastAttbutedString
//            //  修改选中位置的光标,每次点击表情光标位置加1
//            selectedRange.location += 1
//            //  修改选中范围的长度为0
//            selectedRange.length = 0
//            
//            //  设置textView的选中光标范围
//            textView.selectedRange = selectedRange
//            
//            
//            
//        } else {
//            //  点击emoji标签
//            let emoji = (emoticon.code! as NSString).emoji()
//            textView.insertText(emoji!)
//        }
        
        
        
        
    }
    
    //  MARK: --    监听键盘frame的改变
    @objc private func keyBoardFrameChange(noti: Notification) {
        //  键盘的frame
        let keyBoardFrame = (noti.userInfo![UIKeyboardFrameEndUserInfoKey]! as! NSValue).cgRectValue
        //  键盘动画时长
        let duration = (noti.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        
        //  更新约束
        toolBar.snp_updateConstraints { (make) in
            make.bottom.equalTo(view).offset(keyBoardFrame.origin.y - ScreenHeight)
        }
        //  执行约束动画
        UIView.animate(withDuration: duration) { 
            self.view.layoutIfNeeded()
        }
        
        
        
        
        
        
    }
    
    
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    

   

}

//  MARK: --    处理toolbar按钮点击的逻辑
extension HMComposeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //  处理点击表情逻辑
    func didSelectedEmoticon() {
        //  设置自定义视图
        if textView.inputView == nil  {
            //  从系统键盘进入到表情键盘
            textView.inputView = emoticonKeyBoard
            //  表示是表情键盘
            toolBar.showIcon(isEmoticon: true)
        
        } else {
            //  从表情键盘进入到系统键盘
            textView.inputView = nil
            //  表示是系统键盘
            toolBar.showIcon(isEmoticon: false)
        }
        
        //  设置键盘上面的自定义视图
//        textView.inputAccessoryView
        //  设置第一响应者
        textView.becomeFirstResponder()
        //  重新刷新inputView
        textView.reloadInputViews()
        
        
    }
    
    
    
    //  处理点击图片逻辑
    func didSelectedPicture() {
        
        let imagePictureCtr = UIImagePickerController()
        
        //  设置代理
        imagePictureCtr.delegate = self
        
        
        //  是否执行传入的来源类型
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePictureCtr.sourceType = .camera
        } else {
            imagePictureCtr.sourceType = .photoLibrary
        }
        
        //  判断是否支持前置设置头
        
        if UIImagePickerController.isCameraDeviceAvailable(.front) {
            //  
            print("支持前置摄像头")
        }
        
        if UIImagePickerController.isCameraDeviceAvailable(.rear) {
            //
            print("支持后置摄像头")
        }
        
        //  允许编辑
//        imagePictureCtr.allowsEditing = true
        
        
        
        
        
        self.present(imagePictureCtr, animated: true, completion: nil)
        
        
        
        
        
    }
    
    //  MARK: -- UIImagePickerControllerDelegate -> 实现代码方法后不会给我们调用dismis需要自己手动调用
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //  取消
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //  选中那张图片
        //UIImagePickerControllerEditedImage 获取编辑的图片
        //UIImagePickerControllerOriginalImage 获取原始图片
       
        
        let image = info["UIImagePickerControllerOriginalImage"]! as! UIImage
        //  获取压缩后的图片
        let scaleImage = image.scaleImage(scaleWidth: 200)
        //  添加压缩后的图片显示
        pictureView.addImage(image: scaleImage)
        
        
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
//    //  根据指定的宽度等比压缩图片
//    func scaleImage(scaleWidth: CGFloat, image: UIImage) -> UIImage {
//        // 100, 100  -->  200, 200 
//        //  压缩后的宽度
//        let scaleHeight = scaleWidth / image.size.width * image.size.height
//        
//        let size = CGSize(width: scaleWidth, height: scaleHeight)
//        
//        //  开启图片上下文
//        UIGraphicsBeginImageContext(size)
//        //  图片绘制到指定的区域内
//        image.draw(in: CGRect(origin: CGPoint.zero, size: size))
//        //  获取压缩后的图片
//        let scaleImage = UIGraphicsGetImageFromCurrentImageContext()
//        
//        
//        UIGraphicsEndImageContext()
//        
//        return scaleImage!
//        
//        
//    }
    
    
    
    
    

}




//  MARK: --UITextViewDelegate
extension HMComposeViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        //  判断是否有内容,然后确定是否可用
        navigationItem.rightBarButtonItem?.isEnabled = textView.hasText
    }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        //  失去第一响应者
        self.view.endEditing(true)
    }
}









