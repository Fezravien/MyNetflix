//
//  PlayerViewController.swift
//  MyNetflix
//
//  Created by 윤재웅 on 2020/07/23.
//  Copyright © 2020 pazravien. All rights reserved.
//

import UIKit

class PlayerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
}

//extension AVPlayer {
//    var isPlaying: Bool {
//        guard self.currentItem != nil else { return false }
//        return self.rate != 0
//    }
//}
