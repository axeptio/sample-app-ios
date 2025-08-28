//
//  VendorConsentViewController.swift
//  sampleSwift
//
//  Created by Claude on 28/08/2025.
//

import UIKit
import AxeptioSDK

class VendorConsentViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    
    // Summary views
    private let summaryView = UIView()
    private let consentedCountLabel = UILabel()
    private let refusedCountLabel = UILabel()
    private let totalCountLabel = UILabel()
    
    // Test specific vendor section
    private let vendorIdTextField = UITextField()
    private let vendorTestButton = UIButton(type: .system)
    private let vendorResultLabel = UILabel()
    
    // Vendor lists
    private let consentedVendorsTextView = UITextView()
    private let refusedVendorsTextView = UITextView()
    private let allVendorsTextView = UITextView()
    
    private var refreshTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        refreshVendorData()
        
        // Auto-refresh every 3 seconds when consent changes
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            self.refreshVendorData()
        }
    }
    
    deinit {
        refreshTimer?.invalidate()
    }
    
    private func setupUI() {
        title = "Vendor Consent APIs"
        view.backgroundColor = .systemBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Close",
            style: .done,
            target: self,
            action: #selector(closeTapped)
        )
        
        setupScrollView()
        setupSummarySection()
        setupTestSection()
        setupVendorListsSections()
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        
        stackView.axis = .vertical
        stackView.spacing = 24
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
    
    private func setupSummarySection() {
        let sectionLabel = createSectionLabel("Summary")
        stackView.addArrangedSubview(sectionLabel)
        
        summaryView.backgroundColor = .secondarySystemBackground
        summaryView.layer.cornerRadius = 8
        summaryView.translatesAutoresizingMaskIntoConstraints = false
        
        let summaryStackView = UIStackView()
        summaryStackView.axis = .horizontal
        summaryStackView.distribution = .fillEqually
        summaryStackView.spacing = 16
        summaryStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Consented count
        let consentedContainer = createSummaryContainer(
            title: "Consented",
            label: consentedCountLabel,
            color: .systemGreen
        )
        
        // Refused count  
        let refusedContainer = createSummaryContainer(
            title: "Refused", 
            label: refusedCountLabel,
            color: .systemRed
        )
        
        // Total count
        let totalContainer = createSummaryContainer(
            title: "Total",
            label: totalCountLabel,
            color: .systemBlue
        )
        
        summaryStackView.addArrangedSubview(consentedContainer)
        summaryStackView.addArrangedSubview(refusedContainer)
        summaryStackView.addArrangedSubview(totalContainer)
        
        summaryView.addSubview(summaryStackView)
        
        NSLayoutConstraint.activate([
            summaryStackView.topAnchor.constraint(equalTo: summaryView.topAnchor, constant: 16),
            summaryStackView.leadingAnchor.constraint(equalTo: summaryView.leadingAnchor, constant: 16),
            summaryStackView.trailingAnchor.constraint(equalTo: summaryView.trailingAnchor, constant: -16),
            summaryStackView.bottomAnchor.constraint(equalTo: summaryView.bottomAnchor, constant: -16)
        ])
        
        stackView.addArrangedSubview(summaryView)
    }
    
    private func setupTestSection() {
        let sectionLabel = createSectionLabel("Test Specific Vendor")
        stackView.addArrangedSubview(sectionLabel)
        
        let testContainer = UIView()
        testContainer.backgroundColor = .secondarySystemBackground
        testContainer.layer.cornerRadius = 8
        
        let testStackView = UIStackView()
        testStackView.axis = .vertical
        testStackView.spacing = 12
        testStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Input section
        let inputStackView = UIStackView()
        inputStackView.axis = .horizontal
        inputStackView.spacing = 12
        
        vendorIdTextField.placeholder = "Enter Vendor ID (e.g., 123)"
        vendorIdTextField.borderStyle = .roundedRect
        vendorIdTextField.keyboardType = .numberPad
        
        vendorTestButton.setTitle("Test Vendor", for: .normal)
        vendorTestButton.backgroundColor = .systemBlue
        vendorTestButton.setTitleColor(.white, for: .normal)
        vendorTestButton.layer.cornerRadius = 8
        vendorTestButton.addTarget(self, action: #selector(testVendorTapped), for: .touchUpInside)
        
        vendorTestButton.translatesAutoresizingMaskIntoConstraints = false
        vendorTestButton.widthAnchor.constraint(equalToConstant: 120).isActive = true
        
        inputStackView.addArrangedSubview(vendorIdTextField)
        inputStackView.addArrangedSubview(vendorTestButton)
        
        // Result label
        vendorResultLabel.numberOfLines = 0
        vendorResultLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        vendorResultLabel.textAlignment = .center
        vendorResultLabel.text = "Enter a vendor ID to test"
        vendorResultLabel.textColor = .secondaryLabel
        
        testStackView.addArrangedSubview(inputStackView)
        testStackView.addArrangedSubview(vendorResultLabel)
        
        testContainer.addSubview(testStackView)
        
        NSLayoutConstraint.activate([
            testStackView.topAnchor.constraint(equalTo: testContainer.topAnchor, constant: 16),
            testStackView.leadingAnchor.constraint(equalTo: testContainer.leadingAnchor, constant: 16),
            testStackView.trailingAnchor.constraint(equalTo: testContainer.trailingAnchor, constant: -16),
            testStackView.bottomAnchor.constraint(equalTo: testContainer.bottomAnchor, constant: -16)
        ])
        
        stackView.addArrangedSubview(testContainer)
    }
    
    private func setupVendorListsSections() {
        // Consented Vendors
        let consentedLabel = createSectionLabel("Consented Vendors (getConsentedVendors)")
        stackView.addArrangedSubview(consentedLabel)
        
        consentedVendorsTextView.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        consentedVendorsTextView.backgroundColor = .secondarySystemBackground
        consentedVendorsTextView.layer.cornerRadius = 8
        consentedVendorsTextView.isEditable = false
        consentedVendorsTextView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        stackView.addArrangedSubview(consentedVendorsTextView)
        
        // Refused Vendors
        let refusedLabel = createSectionLabel("Refused Vendors (getRefusedVendors)")
        stackView.addArrangedSubview(refusedLabel)
        
        refusedVendorsTextView.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        refusedVendorsTextView.backgroundColor = .secondarySystemBackground
        refusedVendorsTextView.layer.cornerRadius = 8
        refusedVendorsTextView.isEditable = false
        refusedVendorsTextView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        stackView.addArrangedSubview(refusedVendorsTextView)
        
        // All Vendors  
        let allLabel = createSectionLabel("All Vendor Consents (getVendorConsents)")
        stackView.addArrangedSubview(allLabel)
        
        allVendorsTextView.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        allVendorsTextView.backgroundColor = .secondarySystemBackground
        allVendorsTextView.layer.cornerRadius = 8
        allVendorsTextView.isEditable = false
        allVendorsTextView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        stackView.addArrangedSubview(allVendorsTextView)
    }
    
    private func createSectionLabel(_ title: String) -> UILabel {
        let label = UILabel()
        label.text = title
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }
    
    private func createSummaryContainer(title: String, label: UILabel, color: UIColor) -> UIView {
        let container = UIView()
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center
        
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = color
        label.textAlignment = .center
        label.text = "0"
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(titleLabel)
        container.addSubview(label)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            
            label.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
    
    @objc private func testVendorTapped() {
        guard let vendorIdText = vendorIdTextField.text,
              let vendorId = Int(vendorIdText) else {
            vendorResultLabel.text = "Invalid vendor ID. Please enter a number."
            vendorResultLabel.textColor = .systemRed
            return
        }
        
        let isConsented = Axeptio.shared.isVendorConsented(vendorId)
        
        vendorResultLabel.text = "Vendor \(vendorId): \(isConsented ? "✅ CONSENTED" : "❌ REFUSED")"
        vendorResultLabel.textColor = isConsented ? .systemGreen : .systemRed
        
        // Clear the text field
        vendorIdTextField.text = ""
        vendorIdTextField.resignFirstResponder()
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    private func refreshVendorData() {
        // Get all vendor consent data
        let allVendorConsents = Axeptio.shared.getVendorConsents()
        let consentedVendors = Axeptio.shared.getConsentedVendors()
        let refusedVendors = Axeptio.shared.getRefusedVendors()
        
        // Update summary
        consentedCountLabel.text = "\(consentedVendors.count)"
        refusedCountLabel.text = "\(refusedVendors.count)" 
        totalCountLabel.text = "\(allVendorConsents.count)"
        
        // Update vendor lists
        if consentedVendors.isEmpty {
            consentedVendorsTextView.text = "No vendors consented"
            consentedVendorsTextView.textColor = .secondaryLabel
        } else {
            consentedVendorsTextView.text = formatVendorList(consentedVendors.sorted())
            consentedVendorsTextView.textColor = .label
        }
        
        if refusedVendors.isEmpty {
            refusedVendorsTextView.text = "No vendors refused"
            refusedVendorsTextView.textColor = .secondaryLabel
        } else {
            refusedVendorsTextView.text = formatVendorList(refusedVendors.sorted())
            refusedVendorsTextView.textColor = .label
        }
        
        if allVendorConsents.isEmpty {
            allVendorsTextView.text = "No vendor consent data available"
            allVendorsTextView.textColor = .secondaryLabel
        } else {
            allVendorsTextView.text = formatAllVendorsData(allVendorConsents)
            allVendorsTextView.textColor = .label
        }
    }
    
    private func formatVendorList(_ vendors: [Int]) -> String {
        let maxVendorsToShow = 50 // Avoid making the list too long
        
        if vendors.count <= maxVendorsToShow {
            return vendors.map { String($0) }.joined(separator: ", ")
        } else {
            let visibleVendors = Array(vendors.prefix(maxVendorsToShow))
            let remaining = vendors.count - maxVendorsToShow
            return visibleVendors.map { String($0) }.joined(separator: ", ") + "\n\n... and \(remaining) more"
        }
    }
    
    private func formatAllVendorsData(_ vendorConsents: [Int: Bool]) -> String {
        let sortedVendors = vendorConsents.sorted { $0.key < $1.key }
        let maxVendorsToShow = 30 // Show fewer for detailed view
        
        var result = ""
        
        for (index, (vendorId, isConsented)) in sortedVendors.prefix(maxVendorsToShow).enumerated() {
            let status = isConsented ? "✅" : "❌"
            result += "\(vendorId): \(status)\n"
        }
        
        if vendorConsents.count > maxVendorsToShow {
            let remaining = vendorConsents.count - maxVendorsToShow
            result += "\n... and \(remaining) more vendors"
        }
        
        return result
    }
}