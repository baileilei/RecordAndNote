//
//  ViewController.swift
//  RecordAndLocalNote
//
//  Created by g on 2019/7/24.
//  Copyright © 2019 g. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        let statusVC = StatusViewController()
//
//        self.present(UINavigationController.init(rootViewController: statusVC), animated: false, completion: nil)
//        self.invokeSystemCamera()
        self.invokeSystemPhoto()
//        self.invokeSystemCamera()
        
//        self.reloadViewWithImg(img: imge)
        
    }

}

extension UIViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate, PropertyStoring {
    
    public typealias T = String
    public typealias AlbumT = Int
    private struct CustomProperties {
        static var imgType = UIImagePickerController.InfoKey.originalImage
        static var isAlbum = UIImagePickerController.SourceType.photoLibrary
    }
    var imgType: String {
        get {
            return getAssociatedObject(&CustomProperties.imgType, defaultValue: CustomProperties.imgType.rawValue)
        }
        set {
            return objc_setAssociatedObject(self, &CustomProperties.imgType, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    var albumType: Int {
        get {
            return getAssociatedObject(&CustomProperties.isAlbum, defaultValue: CustomProperties.isAlbum.rawValue)
        }
        set {
            return objc_setAssociatedObject(self, &CustomProperties.isAlbum, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func invokingSystemAlbumOrCamera(type: String, albumT: Int) -> Void {
        
        self.imgType = type
        self.albumType = albumT
        if albumT == UIImagePickerController.SourceType.photoLibrary.rawValue {
            self.invokeSystemPhoto()
        }else {
            self.invokeSystemCamera()
        }
    }
    
    func invokeSystemPhoto() -> Void {
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            
            UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.delegate = self
            imagePickerController.allowsEditing = false
            if self.imgType == UIImagePickerController.InfoKey.editedImage.rawValue {
                imagePickerController.allowsEditing = true
            }else {
                imagePickerController.allowsEditing = false
            }
            if #available(iOS 11.0, *) {
                UIScrollView.appearance().contentInsetAdjustmentBehavior = .automatic
            }
            self.present(imagePickerController, animated: true, completion: nil)
        }else {
            print("请打开允许访问相册权限")
        }
    }
    
    func invokeSystemCamera() -> Void {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .camera
            imagePickerController.delegate = self
            imagePickerController.allowsEditing = false
            imagePickerController.cameraCaptureMode = .photo
            imagePickerController.mediaTypes = ["public.image"]
            self.imgType = UIImagePickerController.InfoKey.originalImage.rawValue
            if #available(iOS 11.0, *) {
                UIScrollView.appearance().contentInsetAdjustmentBehavior = .automatic
            }
            self.present(imagePickerController, animated: true, completion: nil)
        }else {
            print("请打开允许访问相机权限")
        }
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if #available(iOS 11.0, *) {
            UIScrollView.appearance().contentInsetAdjustmentBehavior = .never
        }
        picker.dismiss(animated: true, completion: nil)
        let img = info[self.imgType] as! UIImage
        if self.albumType == UIImagePickerController.SourceType.photoLibrary.rawValue {
            self.reloadViewWithImg(img: img)
        }else {
            self.reloadViewWithCameraImg(img: img)
        }
        
    }
    
    @objc func reloadViewWithImg(img: UIImage) -> Void {
        print(img)
    }
    
    @objc func reloadViewWithCameraImg(img: UIImage) -> Void {
        print(img)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        if #available(iOS 11.0, *) {
            UIScrollView.appearance().contentInsetAdjustmentBehavior = .never
        }
        self.dismiss(animated: true, completion: nil)
    }
}

public protocol PropertyStoring {
    
    associatedtype T
    associatedtype AlbumT
    func getAssociatedObject(_ key: UnsafeRawPointer!, defaultValue: T) -> T
    func getAssociatedObject(_ key: UnsafeRawPointer!, defaultValue: AlbumT) -> AlbumT
}

public extension PropertyStoring {
    
    func getAssociatedObject(_ key: UnsafeRawPointer!, defaultValue: T) -> T {
        guard let value = objc_getAssociatedObject(self, key) as? T else {
            return defaultValue
        }
        return value
    }
    
    func getAssociatedObject(_ key: UnsafeRawPointer!, defaultValue: AlbumT) -> AlbumT {
        guard let value = objc_getAssociatedObject(self, key) as? AlbumT else {
            return defaultValue
        }
        return value
    }
}

