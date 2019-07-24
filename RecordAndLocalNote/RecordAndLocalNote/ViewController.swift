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
        let statusVC = StatusViewController()
        
        self.present(UINavigationController.init(rootViewController: statusVC), animated: false, completion: nil)
        
    }

}

