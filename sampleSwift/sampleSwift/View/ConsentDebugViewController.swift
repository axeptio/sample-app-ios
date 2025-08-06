//
//  ConsentDebugViewController.swift
//  sampleSwift
//
//  Created by Leonardo Carrillo on 05/08/25.
//
import SwiftUI

class ConsentDebugViewController: UIViewController {
    private let data: [String: Any?]
    private var tableView: UITableView!
    private var sortedKeys: [String] = []
    
    init(data: [String: Any?]) {
        self.data = data
        super.init(nibName: nil, bundle: nil)
        self.sortedKeys = data.keys.sorted()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Consent Debug Info"
        view.backgroundColor = .systemBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Close",
            style: .done,
            target: self,
            action: #selector(closeTapped)
        )
        
        setupTableView()
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ConsentDebugCell.self, forCellReuseIdentifier: "ConsentDebugCell")
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(tableView)
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}

extension ConsentDebugViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedKeys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ConsentDebugCell", for: indexPath) as? ConsentDebugCell else {
            return UITableViewCell()
        }
        
        let key = sortedKeys[indexPath.row]
        let value = data[key]
        
        cell.configure(key: key, value: value)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

class ConsentDebugCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.numberOfLines = 0
        
        valueLabel.font = UIFont.systemFont(ofSize: 14)
        valueLabel.numberOfLines = 0
        valueLabel.textColor = .systemGray
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(valueLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            valueLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            valueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            valueLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(key: String, value: Any?) {
        titleLabel.text = key
        
        if let value = value {
            // Try to pretty print JSON first
            if let prettyJson = prettyPrint(value: value) {
                valueLabel.text = prettyJson
            } else if let array = value as? [Any] {
                // Try to pretty print array as JSON
                if let prettyJson = prettyPrint(value: array) {
                    valueLabel.text = prettyJson
                } else {
                    valueLabel.text = "Array (\(array.count) items): \(String(describing: array))"
                }
            } else if let dict = value as? [String: Any] {
                // Try to pretty print dictionary as JSON
                if let prettyJson = prettyPrint(value: dict) {
                    valueLabel.text = prettyJson
                } else {
                    valueLabel.text = "Dictionary (\(dict.count) items): \(String(describing: dict))"
                }
            } else {
                valueLabel.text = String(describing: value)
            }
        } else {
            valueLabel.text = "nil"
        }
    }

    private func prettyPrint(value: Any) -> String? {
        if let data = value as? Data,
           let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
           let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted) {
            return String(data: prettyData, encoding: .utf8)
        }

        if let stringValue = value as? String {
            // First try URL decoding
            let decodedString = stringValue.removingPercentEncoding ?? stringValue
            
            // Try to parse the decoded string as JSON
            if let data = decodedString.data(using: .utf8),
               let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
               let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted) {
                return String(data: prettyData, encoding: .utf8)
            }
            
            // If it's not JSON but was URL encoded, return the decoded version
            if decodedString != stringValue {
                return decodedString
            }
        }

        if JSONSerialization.isValidJSONObject(value),
           let prettyData = try? JSONSerialization.data(withJSONObject: value, options: .prettyPrinted) {
            return String(data: prettyData, encoding: .utf8)
        }

        return nil
    }
}
