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
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ConsentDebugCell.self, forCellReuseIdentifier: "ConsentDebugCell")

        view.addSubview(tableView)

        // Use Auto Layout instead of autoresizingMask
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
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
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ConsentDebugCell",
            for: indexPath
        ) as? ConsentDebugCell else {
            return UITableViewCell()
        }

        let key = sortedKeys[indexPath.row]
        let value = data[key]

        cell.configure(key: key, value: value as Any?)

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
        styleTitleLabel(for: key)
        valueLabel.text = formatValue(value)

        if let explanation = getKeyExplanation(key) {
            valueLabel.text = (valueLabel.text ?? "") + "\n\n💡 " + explanation
        }
    }

    private func styleTitleLabel(for key: String) {
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        if isVendorRelatedKey(key) {
            titleLabel.textColor = .systemBlue
        } else if isDateRelatedKey(key) {
            titleLabel.textColor = .systemOrange
        } else {
            titleLabel.textColor = .label
        }
    }

    private func formatValue(_ value: Any?) -> String {
        guard let value else { return "nil" }

        if let stringValue = value as? String {
            return stringValue
        }
        if let prettyJson = prettyPrint(value: value) {
            return prettyJson
        }
        if let array = value as? [Any] {
            return prettyPrint(value: array)
                ?? "Array (\(array.count) items): \(String(describing: array))"
        }
        if let dict = value as? [String: Any] {
            return prettyPrint(value: dict)
                ?? "Dictionary (\(dict.count) items): \(String(describing: dict))"
        }
        return formatPrimitiveValue(value)
    }

    private func formatPrimitiveValue(_ value: Any) -> String {
        if let data = value as? Data {
            return String(data: data, encoding: .utf8) ?? "Binary data (\(data.count) bytes)"
        }
        if let number = value as? NSNumber {
            return number.stringValue
        }
        if let date = value as? Date {
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(identifier: "UTC")
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            return formatter.string(from: date)
        }
        return "\(value)"
    }

    private func isVendorRelatedKey(_ key: String) -> Bool {
        let vendorKeys = [
            "IABTCF_VendorConsents",
            "IABTCF_VendorLegitimateInterests",
            "IABTCF_AddtlConsent"
        ]
        return vendorKeys.contains(key) || key.lowercased().contains("vendor")
    }

    private func isDateRelatedKey(_ key: String) -> Bool {
        return key.lowercased().contains("date") || key.lowercased().contains("time")
    }

    private func getKeyExplanation(_ key: String) -> String? {
        switch key {
        case "IABTCF_VendorConsents":
            return "TCF vendor consents string. Use TCF Vendor API to parse this data."
        case "IABTCF_VendorLegitimateInterests":
            return "TCF vendor legitimate interests string."
        case "IABTCF_TCString":
            return "Full TCF consent string containing all consent information."
        case "IABTCF_AddtlConsent":
            return "Additional consent for Google Ad Technology Providers (ATP)."
        case let key where key.contains("Date") || key.contains("date"):
            return "Date values are displayed in ISO 8601 format (UTC)."
        default:
            return nil
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
