//
//  AppTabbarController.swift
//  MyNetflix
//
//  Created by 윤재웅 on 2020/07/23.
//  Copyright © 2020 pazravien. All rights reserved.
//

import UIKit

class AppTabbarController: UITabBarController {
    
   override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}
