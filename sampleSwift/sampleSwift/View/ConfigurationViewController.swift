// swiftlint:disable file_length
//
//  ConfigurationViewController.swift
//  sampleSwift
//
//  Created by Claude on 28/08/2025.
//

import UIKit
import AxeptioSDK

// swiftlint:disable:next type_body_length
class ConfigurationViewController: UIViewController {

    weak var delegate: ConfigurationViewControllerDelegate?
    var remainingDays: Int? = 0

    // UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    private var axeptioPRContainer = UIView()
    private var cookiesDurationTextfieldContainer = UIView()
    private var cookiesDurationRemainingLabel = UILabel()

    // Input fields
    private let clientIdTextField = UITextField()
    private let cookiesVersionTextField = UITextField()
    private let tokenTextField = UITextField()
    private let cookiesDurationSwitch = UISwitch()
    private let cookiesDurationTextfield = UITextField()
    private let widgetPRTextField = UITextField()
    private let widgetTypeSegmentedControl = UISegmentedControl(
        items: [WidgetType.production.title, WidgetType.staging.title, WidgetType.pullRequest.title]
    )
    private let serviceSegmentedControl = UISegmentedControl(items: ["Brands", "Publisher TCF"])
    private let allowPopupSwitch = UISwitch()
    private let forceShowConsentSwitch = UISwitch()

    // Preset configurations
    private let presetTableView = UITableView()
    private let presetConfigurations = Array(ConfigurationManager.presetConfigurations.keys).sorted()

    private var hasUnsavedChanges = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadCurrentConfiguration()
    }

    private func setupUI() {
        title = "Configuration"
        view.backgroundColor = .systemBackground

        // Navigation buttons
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

        setupScrollView()
        setupCustomConfigurationSection()
        setupPresetConfigurationSection()

        // Add observers for text field changes
        [clientIdTextField, cookiesVersionTextField, tokenTextField, cookiesDurationTextfield, widgetPRTextField].forEach { textField in
            textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        }
        widgetTypeSegmentedControl.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
        serviceSegmentedControl.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
        allowPopupSwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        cookiesDurationSwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        forceShowConsentSwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)

        cookiesDurationTextfield.keyboardType = .numberPad
    }

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)

        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }

    private func setupPresetConfigurationSection() {
        // Section header
        let presetSectionLabel = UILabel()
        presetSectionLabel.text = "Quick Presets"
        presetSectionLabel.font = UIFont.boldSystemFont(ofSize: 18)
        stackView.addArrangedSubview(presetSectionLabel)

        // Preset table view
        presetTableView.translatesAutoresizingMaskIntoConstraints = false
        presetTableView.delegate = self
        presetTableView.dataSource = self
        presetTableView.register(UITableViewCell.self, forCellReuseIdentifier: "PresetCell")
        presetTableView.layer.cornerRadius = 8
        presetTableView.layer.borderWidth = 1
        presetTableView.layer.borderColor = UIColor.systemGray4.cgColor
        presetTableView.heightAnchor.constraint(equalToConstant: CGFloat(presetConfigurations.count * 44)).isActive = true

        stackView.addArrangedSubview(presetTableView)

        // Reset button
        let resetButton = UIButton(type: .system)
        resetButton.setTitle("Reset to Defaults", for: .normal)
        resetButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        resetButton.addTarget(self, action: #selector(resetToDefaultsTapped), for: .touchUpInside)
        stackView.addArrangedSubview(resetButton)
    }

    private func createInputContainer(label: String, textField: UITextField, placeholder: String) -> UIView {
        let container = UIView()

        let labelView = UILabel()
        labelView.text = label
        labelView.font = UIFont.systemFont(ofSize: 16, weight: .medium)

        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no

        labelView.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(labelView)
        container.addSubview(textField)

        NSLayoutConstraint.activate([
            labelView.topAnchor.constraint(equalTo: container.topAnchor),
            labelView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            labelView.trailingAnchor.constraint(equalTo: container.trailingAnchor),

            textField.topAnchor.constraint(equalTo: labelView.bottomAnchor, constant: 4),
            textField.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            textField.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        return container
    }

    private func createSegmentedControlContainer(label: String, segmentedControl: UISegmentedControl) -> UIView {
        let container = UIView()

        let labelView = UILabel()
        labelView.text = label
        labelView.font = UIFont.systemFont(ofSize: 16, weight: .medium)

        labelView.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(labelView)
        container.addSubview(segmentedControl)

        NSLayoutConstraint.activate([
            labelView.topAnchor.constraint(equalTo: container.topAnchor),
            labelView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            labelView.trailingAnchor.constraint(equalTo: container.trailingAnchor),

            segmentedControl.topAnchor.constraint(equalTo: labelView.bottomAnchor, constant: 4),
            segmentedControl.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            segmentedControl.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            segmentedControl.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        return container
    }

    private func createSwitchContainer(label: String, switch: UISwitch) -> UIView {
        let container = UIView()

        let labelView = UILabel()
        labelView.text = label
        labelView.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        labelView.numberOfLines = 0

        labelView.translatesAutoresizingMaskIntoConstraints = false
        `switch`.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(labelView)
        container.addSubview(`switch`)

        NSLayoutConstraint.activate([
            labelView.topAnchor.constraint(equalTo: container.topAnchor),
            labelView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            labelView.trailingAnchor.constraint(equalTo: `switch`.leadingAnchor, constant: -16),
            labelView.centerYAnchor.constraint(equalTo: `switch`.centerYAnchor),

            `switch`.topAnchor.constraint(equalTo: container.topAnchor),
            `switch`.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            `switch`.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        return container
    }

    private func loadCurrentConfiguration() {
        let config = ConfigurationManager.shared.currentConfiguration
        let days: Int = self.remainingDays ?? 0

        clientIdTextField.text = config.clientId
        cookiesVersionTextField.text = config.cookiesVersion
        tokenTextField.text = config.token ?? ""

            cookiesDurationSwitch.isOn = config.shouldUpdateCookiesDuration
        cookiesDurationTextfield.text = config.shouldUpdateCookiesDuration
            ? String(config.cookiesDuration) : ""
        cookiesDurationRemainingLabel.text = (days > 0)
            ? "Consent expires in \(days) days"
            : "Consent duration has expired"

        widgetPRTextField.text = config.widgetPR ?? ""
        serviceSegmentedControl.selectedSegmentIndex = config.targetService == .brands ? 0 : 1
        widgetTypeSegmentedControl.selectedSegmentIndex = config.widgetType.rawValue
        allowPopupSwitch.isOn = config.allowPopupWithRejectedATT
        forceShowConsentSwitch.isOn = config.forceShowConsent

        hasUnsavedChanges = false
        updateSaveButtonState()
        updateOptionalFieldsVisbility()
    }

    @objc private func textFieldDidChange() {
        hasUnsavedChanges = true
        updateSaveButtonState()

    }

    @objc private func segmentedControlChanged() {
        hasUnsavedChanges = true
        updateOptionalFieldsVisbility()
        updateSaveButtonState()
    }

    @objc private func switchChanged() {
        hasUnsavedChanges = true
        updateOptionalFieldsVisbility()
        updateSaveButtonState()
    }

    private func updateSaveButtonState() {
        navigationItem.rightBarButtonItem?.isEnabled = hasUnsavedChanges
    }

    private func updateOptionalFieldsVisbility() {
        axeptioPRContainer.isHidden = widgetTypeSegmentedControl.selectedSegmentIndex != 2
        cookiesDurationTextfieldContainer.isHidden = !cookiesDurationSwitch.isOn
        cookiesDurationRemainingLabel.isHidden = cookiesDurationSwitch.isOn
    }

    @objc private func cancelTapped() {
        if hasUnsavedChanges {
            let alert = UIAlertController(
                title: "Unsaved Changes",
                message: "You have unsaved changes. Are you sure you want to cancel?",
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Discard", style: .destructive) { _ in
                self.dismiss(animated: true)
            })

            present(alert, animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    @objc private func saveTapped() {
        let config = CustomerConfiguration(
            clientId: clientIdTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
            cookiesVersion: cookiesVersionTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "",
            token: {
                let token = tokenTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                return token.isEmpty ? nil : token
            }(),
            cookiesDuration: (Int(cookiesDurationTextfield.text ?? "") ?? 190),
            shouldUpdateCookiesDuration: cookiesDurationSwitch.isOn,
            widgetType: WidgetType.init(rawValue: widgetTypeSegmentedControl.selectedSegmentIndex) ?? .production,
            widgetPR: widgetPRTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            targetService: serviceSegmentedControl.selectedSegmentIndex == 0 ? .brands : .publisherTcf,
            allowPopupWithRejectedATT: allowPopupSwitch.isOn,
            forceShowConsent: forceShowConsentSwitch.isOn
        )

        // Basic validation
        guard !config.clientId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !config.cookiesVersion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showAlert(title: "Invalid Configuration", message: "Please fill in all required fields.")
            return
        }

        ConfigurationManager.shared.currentConfiguration = config

        showRestartAlert {
            self.delegate?.configurationDidChange()
            self.dismiss(animated: true)
        }
    }

    @objc private func resetToDefaultsTapped() {
        let alert = UIAlertController(
            title: "Reset Configuration",
            message: "This will reset all settings to default values. Are you sure?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive) { _ in
            // Reset to default configuration
            guard let defaultConfig = ConfigurationManager.presetConfigurations["Default Brands"] else {
                self.showAlert(title: "Error", message: "Default configuration not available")
                return
            }
            ConfigurationManager.shared.currentConfiguration = defaultConfig
            self.loadCurrentConfiguration()

            self.showRestartAlert {
                self.delegate?.configurationDidChange()
                self.dismiss(animated: true)
            }
        })

        present(alert, animated: true)
    }

    private func showValidationErrors(_ errors: [String]) {
        let alert = UIAlertController(
            title: "Configuration Error",
            message: errors.joined(separator: "\n"),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func showRestartAlert(completion: @escaping () -> Void) {
        let alert = UIAlertController(
            title: "Configuration Saved",
            message: "The app needs to restart to apply the new configuration. Please close and reopen the app.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion()
        })

        present(alert, animated: true)
    }
}

// MARK: - Custom Configuration Setup

private extension ConfigurationViewController {
    func setupCustomConfigurationSection() {
        let customSectionLabel = UILabel()
        customSectionLabel.text = "Custom Configuration"
        customSectionLabel.font = UIFont.boldSystemFont(ofSize: 18)
        stackView.addArrangedSubview(customSectionLabel)

        setupTextFieldInputs()
        setupCookiesDurationSection()
        setupWidgetAndServiceControls()
        setupToggleSwitches()

        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.heightAnchor.constraint(equalToConstant: 24).isActive = true
        stackView.addArrangedSubview(spacer)
    }

    func setupTextFieldInputs() {
        stackView.addArrangedSubview(createInputContainer(
            label: "Client ID",
            textField: clientIdTextField,
            placeholder: "Enter client ID (e.g., 5fbfa806a0787d3985c6ee5f)"
        ))

        stackView.addArrangedSubview(createInputContainer(
            label: "Cookies Version",
            textField: cookiesVersionTextField,
            placeholder: "Enter cookies version"
        ))

        tokenTextField.isSecureTextEntry = false
        stackView.addArrangedSubview(createInputContainer(
            label: "Token (Optional)",
            textField: tokenTextField,
            placeholder: "Enter token (optional)"
        ))
    }

    func setupCookiesDurationSection() {
        stackView.addArrangedSubview(createSwitchContainer(
            label: "Update Consent Expiration Date",
            switch: cookiesDurationSwitch
        ))

        let durationLabel = UILabel()
        let descriptor = UIFont.systemFont(ofSize: 17).fontDescriptor
        let boldItalic = descriptor.withSymbolicTraits([.traitBold, .traitItalic])
        durationLabel.font = boldItalic.map { UIFont(descriptor: $0, size: 14) }
            ?? UIFont.italicSystemFont(ofSize: 14)
        durationLabel.textColor = UIColor(named: "AxeptioYellow")
        stackView.addArrangedSubview(durationLabel)
        self.cookiesDurationRemainingLabel = durationLabel

        let container = createInputContainer(
            label: "Consent Expiration (# of Days)",
            textField: cookiesDurationTextfield,
            placeholder: "Default expiration will be set to 190 days."
        )
        stackView.addArrangedSubview(container)
        self.cookiesDurationTextfieldContainer = container
    }

    func setupWidgetAndServiceControls() {
        stackView.addArrangedSubview(createSegmentedControlContainer(
            label: "Widget Type",
            segmentedControl: widgetTypeSegmentedControl
        ))

        let widgetPRContainer = createInputContainer(
            label: "Widget Version (Optional)",
            textField: widgetPRTextField,
            placeholder: "Enter Widget PR #"
        )
        stackView.addArrangedSubview(widgetPRContainer)
        self.axeptioPRContainer = widgetPRContainer

        stackView.addArrangedSubview(createSegmentedControlContainer(
            label: "Service Type",
            segmentedControl: serviceSegmentedControl
        ))
    }

    func setupToggleSwitches() {
        stackView.addArrangedSubview(createSwitchContainer(
            label: "Allow Popup With Rejected ATT",
            switch: allowPopupSwitch
        ))

        stackView.addArrangedSubview(createSwitchContainer(
            label: "Force Show Consent (Debug)",
            switch: forceShowConsentSwitch
        ))
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension ConfigurationViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presetConfigurations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "PresetCell")
        let presetName = presetConfigurations[indexPath.row]

        if let config = ConfigurationManager.presetConfigurations[presetName] {
            cell.textLabel?.text = presetName
            cell.detailTextLabel?.text = config.displayName
            cell.accessoryType = .disclosureIndicator
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let presetName = presetConfigurations[indexPath.row]
        guard let config = ConfigurationManager.presetConfigurations[presetName] else { return }

        clientIdTextField.text = config.clientId
        cookiesVersionTextField.text = config.cookiesVersion
        tokenTextField.text = config.token ?? ""
        cookiesDurationSwitch.isOn = config.shouldUpdateCookiesDuration
        cookiesDurationTextfield.text = config.shouldUpdateCookiesDuration ? String(config.cookiesDuration) : ""
        widgetPRTextField.text = config.widgetPR ?? ""
        serviceSegmentedControl.selectedSegmentIndex = config.targetService == .brands ? 0 : 1
        allowPopupSwitch.isOn = config.allowPopupWithRejectedATT
        forceShowConsentSwitch.isOn = config.forceShowConsent

        hasUnsavedChanges = true
        updateSaveButtonState()
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
