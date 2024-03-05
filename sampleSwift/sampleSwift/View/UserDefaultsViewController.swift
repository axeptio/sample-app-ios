//
//  ViewController.swift
//  sampleSwift
//
//  Created by Noeline PAGESY on 08/02/2024.
//

import UIKit

class UserDefaultsViewController: UIViewController {
    private var fields: [String: Any] = [:]
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        TCFFields.allCases.forEach { field in
            let value = UserDefaults.standard.value(forKey: field.rawValue) ?? ""
            fields.updateValue(value, forKey: field.rawValue)
        }
    }
}

extension UserDefaultsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        TCFFields.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TCFCell", for: indexPath) as! TCFCell
        cell.title?.text = Array(fields.keys)[indexPath.row]
        cell.value?.text = "\(Array(fields.values)[indexPath.row])"

        return cell
    }
}

class TCFCell: UITableViewCell {
    @IBOutlet var title : UILabel?
    @IBOutlet var value : UILabel?
}
