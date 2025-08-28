//
//  ConsentDebugViewController.swift
//  sampleSwift
//
//  Created by Leonardo Carrillo on 05/08/25.
//
import SwiftUI
import AxeptioSDK

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
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Vendor APIs",
            style: .plain,
            target: self,
            action: #selector(showVendorConsent)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Close",
            style: .done,
            target: self,
            action: #selector(closeTapped)
        )
        
        setupTableView()
    }
    
    @objc private func showVendorConsent() {
        let vendorViewController = VendorConsentViewController()
        navigationController?.pushViewController(vendorViewController, animated: true)
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
        
        // Highlight vendor-related keys
        if isVendorRelatedKey(key) {
            titleLabel.textColor = .systemBlue
            titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        } else if isDateRelatedKey(key) {
            titleLabel.textColor = .systemOrange
            titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        } else {
            titleLabel.textColor = .label
            titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        }
        
        if let value = value {
            // Handle strings directly to avoid truncation
            if let stringValue = value as? String {
                valueLabel.text = stringValue
            }
            // Try to pretty print JSON
            else if let prettyJson = prettyPrint(value: value) {
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
            } 
            // Handle other types - explicitly convert to avoid truncation
            else {
                if let data = value as? Data {
                    valueLabel.text = String(data: data, encoding: .utf8) ?? "Binary data (\(data.count) bytes)"
                } else if let number = value as? NSNumber {
                    valueLabel.text = number.stringValue
                } else if let date = value as? Date {
                    let formatter = DateFormatter()
                    formatter.dateStyle = .medium
                    formatter.timeStyle = .medium
                    valueLabel.text = formatter.string(from: date)
                } else {
                    // Use explicit string interpolation to avoid truncation
                    valueLabel.text = "\(value)"
                }
            }
        } else {
            valueLabel.text = "nil"
        }
        
        // Add explanatory text for important keys
        if let explanation = getKeyExplanation(key) {
            valueLabel.text = (valueLabel.text ?? "") + "\n\n💡 " + explanation
        }
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
            return "TCF vendor consents string. Use Vendor APIs to parse this data."
        case "IABTCF_VendorLegitimateInterests":
            return "TCF vendor legitimate interests string."
        case "IABTCF_TCString":
            return "Full TCF consent string containing all consent information."
        case "IABTCF_AddtlConsent":
            return "Additional consent for Google Ad Technology Providers (ATP)."
        case let key where key.contains("Date") || key.contains("date"):
            return "Date values are now serialized as ISO8601 strings (MSK-84 fix)."
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

// MARK: - Configuration Management UI

class ConfigurationViewController: UIViewController {
    weak var delegate: ConfigurationViewControllerDelegate?
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private var currentConfiguration: CustomerConfiguration
    
    // Form fields for custom configuration
    private let clientIdField = UITextField()
    private let cookiesVersionField = UITextField()
    private let tokenField = UITextField()
    private let serviceSegmentedControl = UISegmentedControl(items: ["Brands", "TCF"])
    
    init() {
        self.currentConfiguration = ConfigurationManager.shared.currentConfiguration
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Configuration"
        view.backgroundColor = .systemGroupedBackground
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(cancelTapped)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Save",
            style: .done,
            target: self,
            action: #selector(saveTapped)
        )
        
        setupTableView()
        setupFormFields()
        updateFormFields()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(ConfigurationFieldCell.self, forCellReuseIdentifier: "FieldCell")
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupFormFields() {
        // Client ID field
        clientIdField.placeholder = "Enter Client ID"
        clientIdField.borderStyle = .roundedRect
        clientIdField.autocapitalizationType = .none
        clientIdField.autocorrectionType = .no
        
        // Cookies Version field
        cookiesVersionField.placeholder = "Enter Cookies Version"
        cookiesVersionField.borderStyle = .roundedRect
        cookiesVersionField.autocapitalizationType = .none
        cookiesVersionField.autocorrectionType = .no
        
        // Token field
        tokenField.placeholder = "Enter Token (optional)"
        tokenField.borderStyle = .roundedRect
        tokenField.autocapitalizationType = .none
        tokenField.autocorrectionType = .no
        tokenField.isSecureTextEntry = false
        
        // Service segmented control
        serviceSegmentedControl.selectedSegmentIndex = 0
    }
    
    private func updateFormFields() {
        clientIdField.text = currentConfiguration.clientId
        cookiesVersionField.text = currentConfiguration.cookiesVersion
        tokenField.text = currentConfiguration.token ?? ""
        serviceSegmentedControl.selectedSegmentIndex = currentConfiguration.targetService == .brands ? 0 : 1
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func saveTapped() {
        guard validateForm() else { return }
        
        let targetService: AxeptioService = serviceSegmentedControl.selectedSegmentIndex == 0 ? .brands : .publisherTcf
        let token = tokenField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let newConfiguration = CustomerConfiguration(
            clientId: clientIdField.text!.trimmingCharacters(in: .whitespacesAndNewlines),
            cookiesVersion: cookiesVersionField.text!.trimmingCharacters(in: .whitespacesAndNewlines),
            token: token?.isEmpty == false ? token : nil,
            targetService: targetService
        )
        
        ConfigurationManager.shared.currentConfiguration = newConfiguration
        delegate?.configurationDidChange()
        
        dismiss(animated: true)
    }
    
    private func validateForm() -> Bool {
        guard let clientId = clientIdField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !clientId.isEmpty,
              let cookiesVersion = cookiesVersionField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !cookiesVersion.isEmpty else {
            
            showAlert(title: "Invalid Configuration", message: "Please fill in all required fields.")
            return false
        }
        
        return true
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func loadPresetConfiguration(_ configuration: CustomerConfiguration) {
        currentConfiguration = configuration
        updateFormFields()
        tableView.reloadData()
    }
}

extension ConfigurationViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3 // Preset configurations, Custom configuration, Actions
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: // Preset configurations
            return ConfigurationManager.presetConfigurations.count
        case 1: // Custom configuration
            return 4 // Client ID, Cookies Version, Token, Service
        case 2: // Actions
            return 1 // Test configuration
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Quick Presets"
        case 1:
            return "Custom Configuration"
        case 2:
            return "Actions"
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Tap a preset to quickly load its configuration."
        case 1:
            return "Configure your own client settings. Changes require app restart to take full effect."
        case 2:
            return "Test your configuration before saving."
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0: // Preset configurations
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            let presetKeys = Array(ConfigurationManager.presetConfigurations.keys).sorted()
            let presetName = presetKeys[indexPath.row]
            let config = ConfigurationManager.presetConfigurations[presetName]!
            
            cell.textLabel?.text = presetName
            cell.detailTextLabel?.text = config.displayName
            cell.accessoryType = .disclosureIndicator
            
            // Highlight current selection
            if config.clientId == currentConfiguration.clientId &&
               config.cookiesVersion == currentConfiguration.cookiesVersion &&
               config.targetService == currentConfiguration.targetService {
                cell.accessoryType = .checkmark
            }
            
            return cell
            
        case 1: // Custom configuration
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "FieldCell", for: indexPath) as? ConfigurationFieldCell else {
                return UITableViewCell()
            }
            
            switch indexPath.row {
            case 0:
                cell.configure(title: "Client ID", textField: clientIdField, isRequired: true)
            case 1:
                cell.configure(title: "Cookies Version", textField: cookiesVersionField, isRequired: true)
            case 2:
                cell.configure(title: "Token", textField: tokenField, isRequired: false)
            case 3:
                cell.configureWithSegmentedControl(title: "Service", segmentedControl: serviceSegmentedControl)
            default:
                break
            }
            
            return cell
            
        case 2: // Actions
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = "Test Configuration"
            cell.textLabel?.textColor = .systemBlue
            cell.accessoryType = .none
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0: // Preset configurations
            let presetKeys = Array(ConfigurationManager.presetConfigurations.keys).sorted()
            let presetName = presetKeys[indexPath.row]
            let config = ConfigurationManager.presetConfigurations[presetName]!
            loadPresetConfiguration(config)
            
        case 2: // Actions
            if indexPath.row == 0 {
                testConfiguration()
            }
            
        default:
            break
        }
    }
    
    private func testConfiguration() {
        guard validateForm() else { return }
        
        let targetService: AxeptioService = serviceSegmentedControl.selectedSegmentIndex == 0 ? .brands : .publisherTcf
        
        showAlert(
            title: "Configuration Test",
            message: "Configuration appears valid!\n\nService: \(targetService == .brands ? "Brands" : "Publisher TCF")\nClient ID: \(clientIdField.text ?? "")\nCookies Version: \(cookiesVersionField.text ?? "")\nToken: \(tokenField.text?.isEmpty == false ? "Provided" : "None")"
        )
    }
}

class ConfigurationFieldCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let requiredIndicator = UILabel()
    private var textField: UITextField?
    private var segmentedControl: UISegmentedControl?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        selectionStyle = .none
        
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        requiredIndicator.text = "*"
        requiredIndicator.textColor = .systemRed
        requiredIndicator.font = UIFont.systemFont(ofSize: 16)
        requiredIndicator.isHidden = true
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(requiredIndicator)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        requiredIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.widthAnchor.constraint(equalToConstant: 120),
            
            requiredIndicator.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 2),
            requiredIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(title: String, textField: UITextField, isRequired: Bool) {
        titleLabel.text = title
        requiredIndicator.isHidden = !isRequired
        
        // Remove previous text field
        self.textField?.removeFromSuperview()
        
        self.textField = textField
        contentView.addSubview(textField)
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: requiredIndicator.trailingAnchor, constant: 8),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            textField.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    func configureWithSegmentedControl(title: String, segmentedControl: UISegmentedControl) {
        titleLabel.text = title
        requiredIndicator.isHidden = true
        
        // Remove previous segmented control
        self.segmentedControl?.removeFromSuperview()
        
        self.segmentedControl = segmentedControl
        contentView.addSubview(segmentedControl)
        
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            segmentedControl.leadingAnchor.constraint(equalTo: requiredIndicator.trailingAnchor, constant: 8),
            segmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            segmentedControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            segmentedControl.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
}

// MARK: - Vendor Consent Management UI

class VendorConsentViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // Header info
    private let summaryLabel = UILabel()
    
    // Action buttons
    private let refreshButton = UIButton(type: .system)
    private let testVendorButton = UIButton(type: .system)
    
    // Results display
    private let resultsTextView = UITextView()
    
    // Test vendor input
    private let vendorIdField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Vendor Consent APIs"
        view.backgroundColor = .systemBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Close",
            style: .done,
            target: self,
            action: #selector(closeTapped)
        )
        
        setupScrollView()
        setupUI()
        
        // Check if we're in TCF mode
        let config = ConfigurationManager.shared.currentConfiguration
        if config.targetService != .publisherTcf {
            showAlert(title: "⚠️ Not in TCF Mode", message: "Vendor consent APIs only work in Publisher TCF mode. Please go to Settings and switch to a TCF configuration first.")
        }
        
        loadVendorData()
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupUI() {
        // Summary label
        summaryLabel.font = UIFont.boldSystemFont(ofSize: 18)
        summaryLabel.numberOfLines = 0
        summaryLabel.textAlignment = .center
        
        // Refresh button
        refreshButton.setTitle("🔄 Refresh Vendor Data", for: .normal)
        refreshButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        refreshButton.backgroundColor = .systemBlue
        refreshButton.setTitleColor(.white, for: .normal)
        refreshButton.layer.cornerRadius = 8
        refreshButton.addTarget(self, action: #selector(refreshTapped), for: .touchUpInside)
        
        // Vendor ID test field
        vendorIdField.placeholder = "Enter Vendor ID (e.g., 123)"
        vendorIdField.borderStyle = .roundedRect
        vendorIdField.keyboardType = .numberPad
        
        // Test vendor button
        testVendorButton.setTitle("🔍 Test Specific Vendor", for: .normal)
        testVendorButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        testVendorButton.backgroundColor = .systemOrange
        testVendorButton.setTitleColor(.white, for: .normal)
        testVendorButton.layer.cornerRadius = 8
        testVendorButton.addTarget(self, action: #selector(testVendorTapped), for: .touchUpInside)
        
        // Results text view
        resultsTextView.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        resultsTextView.backgroundColor = .systemGray6
        resultsTextView.layer.cornerRadius = 8
        resultsTextView.isEditable = false
        resultsTextView.layer.borderWidth = 1
        resultsTextView.layer.borderColor = UIColor.systemGray4.cgColor
        
        // Add instructions label
        let instructionsLabel = UILabel()
        instructionsLabel.font = UIFont.systemFont(ofSize: 14)
        instructionsLabel.numberOfLines = 0
        instructionsLabel.textColor = .secondaryLabel
        instructionsLabel.text = """
        📝 Testing Steps:
        1. Go back and open the TCF consent dialog
        2. Accept/refuse specific vendors
        3. Return here and tap 'Refresh' to see updated data
        4. Try testing specific vendor IDs below
        
        Note: APIs only work after consent interaction in TCF mode
        """
        
        // Add all elements to content view
        let stackView = UIStackView(arrangedSubviews: [
            summaryLabel,
            refreshButton,
            instructionsLabel,
            vendorIdField,
            testVendorButton,
            resultsTextView
        ])
        
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fill
        
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            refreshButton.heightAnchor.constraint(equalToConstant: 44),
            vendorIdField.heightAnchor.constraint(equalToConstant: 40),
            testVendorButton.heightAnchor.constraint(equalToConstant: 44),
            resultsTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 300)
        ])
    }
    
    @objc private func closeTapped() {
        if navigationController?.viewControllers.count == 1 {
            dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc private func refreshTapped() {
        loadVendorData()
    }
    
    @objc private func testVendorTapped() {
        guard let vendorIdText = vendorIdField.text,
              let vendorId = Int(vendorIdText) else {
            showAlert(title: "Invalid Input", message: "Please enter a valid vendor ID number.")
            return
        }
        
        testSpecificVendor(vendorId: vendorId)
    }
    
    private func loadVendorData() {
        var results = "=== VENDOR CONSENT API RESULTS ===\n\n"
        
        // Add timestamp for debugging
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        results += "🕐 Last Updated: \(formatter.string(from: Date()))\n\n"
        
        // Get all vendor consents
        let allVendorConsents = Axeptio.shared.getVendorConsents()
        results += "📋 All Vendor Consents:\n"
        results += "Type: \(type(of: allVendorConsents))\n"
        results += "Content: \(String(describing: allVendorConsents))\n\n"
        
        // Get consented vendors
        let consentedVendors = Axeptio.shared.getConsentedVendors()
        results += "✅ Consented Vendors:\n"
        results += "Count: \(consentedVendors.count)\n"
        if !consentedVendors.isEmpty {
            results += "Vendors: \(consentedVendors.prefix(20).map(String.init).joined(separator: ", "))"
            if consentedVendors.count > 20 {
                results += "... (showing first 20 of \(consentedVendors.count))"
            }
        } else {
            results += "No consented vendors found"
        }
        results += "\n\n"
        
        // Get refused vendors
        let refusedVendors = Axeptio.shared.getRefusedVendors()
        results += "❌ Refused Vendors:\n"
        results += "Count: \(refusedVendors.count)\n"
        if !refusedVendors.isEmpty {
            results += "Vendors: \(refusedVendors.prefix(20).map(String.init).joined(separator: ", "))"
            if refusedVendors.count > 20 {
                results += "... (showing first 20 of \(refusedVendors.count))"
            }
        } else {
            results += "No refused vendors found"
        }
        results += "\n\n"
        
        // Summary
        let totalVendors = consentedVendors.count + refusedVendors.count
        results += "📊 SUMMARY:\n"
        results += "Total Processed Vendors: \(totalVendors)\n"
        results += "Consented: \(consentedVendors.count) (\(totalVendors > 0 ? Int(Double(consentedVendors.count) / Double(totalVendors) * 100) : 0)%)\n"
        results += "Refused: \(refusedVendors.count) (\(totalVendors > 0 ? Int(Double(refusedVendors.count) / Double(totalVendors) * 100) : 0)%)\n\n"
        
        // Debug: Check what getVendorConsents actually returns
        results += "🔍 DEBUG INFO:\n"
        if let vendorConsentsString = allVendorConsents as? String {
            results += "Raw vendor consents string: \(vendorConsentsString)\n"
            results += "String length: \(vendorConsentsString.count)\n"
        }
        results += "getConsentedVendors() type: \(type(of: consentedVendors))\n"
        results += "getRefusedVendors() type: \(type(of: refusedVendors))\n\n"
        
        // Check current consent state from main methods
        if let axeptioToken = Axeptio.shared.axeptioToken {
            results += "Current Axeptio Token: \(String(axeptioToken.prefix(10)))...\n"
        } else {
            results += "No Axeptio Token found\n"
        }
        
        // Update UI
        summaryLabel.text = "📊 \(totalVendors) vendors processed\n✅ \(consentedVendors.count) consented | ❌ \(refusedVendors.count) refused"
        resultsTextView.text = results
        
        // Scroll to top
        resultsTextView.setContentOffset(.zero, animated: true)
    }
    
    private func testSpecificVendor(vendorId: Int) {
        let consentedVendors = Axeptio.shared.getConsentedVendors()
        let refusedVendors = Axeptio.shared.getRefusedVendors()
        
        var result = "\n=== VENDOR \(vendorId) TEST RESULTS ===\n"
        
        if consentedVendors.contains(vendorId) {
            result += "✅ Vendor \(vendorId) has CONSENT\n"
        } else if refusedVendors.contains(vendorId) {
            result += "❌ Vendor \(vendorId) was REFUSED\n"
        } else {
            result += "❓ Vendor \(vendorId) status UNKNOWN (not in consent data)\n"
        }
        
        result += "This vendor appears in:\n"
        result += "- Consented list: \(consentedVendors.contains(vendorId) ? "YES" : "NO")\n"
        result += "- Refused list: \(refusedVendors.contains(vendorId) ? "YES" : "NO")\n"
        result += "=====================================\n\n"
        
        // Append to existing results
        resultsTextView.text += result
        
        // Scroll to show the new content
        let range = NSMakeRange(resultsTextView.text.count - 1, 0)
        resultsTextView.scrollRangeToVisible(range)
        
        // Clear the input field
        vendorIdField.text = ""
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
