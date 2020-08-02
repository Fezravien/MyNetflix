//
//  SeeMoreViewController.swift
//
//
//  Created by 윤재웅 on 2020/08/03.
//

import UIKit

class SeeMoreViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    let setupTerms:[String] = ["내가 찜한 콘텐츠", "앱 설정", "고객 센터"]

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
}

extension SeeMoreViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return setupTerms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "setupCell", for: indexPath) as? setupCell else {
            return UITableViewCell()
        }
        
        cell.setupTerm.text = setupTerms[indexPath.row]
       
        return cell
    }
    
}

class setupCell: UITableViewCell {
    
    @IBOutlet weak var setupTerm: UILabel!
}
