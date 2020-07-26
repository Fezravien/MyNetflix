//
//  HistoryViewController.swift
//  MyNetflix
//
//  Created by 윤재웅 on 2020/07/26.
//  Copyright © 2020 pazravien. All rights reserved.
//

import UIKit
import FirebaseDatabase

class HistoryViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let db = Database.database().reference().child("searchHistory")
    var searchTerms: [SearchTerm] = []
    
    // 메모리에 올라올때
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    // 안보이다가 보일때
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        db.observeSingleEvent(of: .value) { snapshot in
            guard let searchHistory = snapshot.value as? [String: Any] else { return }
            
            // 파싱했을때 코더블 쓰고 싶다.
            let data = try! JSONSerialization.data(withJSONObject: Array(searchHistory.values), options: [])
            let decoder = JSONDecoder()
            let searchTerms = try! decoder.decode([SearchTerm].self, from: data)
            self.searchTerms = searchTerms.sorted{$0.timestamp > $1.timestamp}
            self.tableView.reloadData()
            print("---> snapshot: \(data)")
            
        }
    }
}

extension HistoryViewController: UITableViewDataSource{
    // 몇개 가져올껀가
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchTerms.count
    }
    
    // 어떻게 보여줄껀가
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as? HistoryCell else {
            return UITableViewCell()
        }
        cell.searchTerm.text = searchTerms[indexPath.row].term
        return cell
    }
    
    
}


class HistoryCell: UITableViewCell {
    @IBOutlet weak var searchTerm: UILabel!
}


struct SearchTerm: Codable {
    let term: String
    let timestamp: TimeInterval
}
