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
    
    // TCF String analysis section
    private let tcfAnalysisButton = UIButton(type: .system)
    private let tcfAnalysisResultLabel = UILabel()
    
    // Vendor lists
    private let consentedVendorsTextView = UITextView()
    private let refusedVendorsTextView = UITextView()
    private let allVendorsTextView = UITextView()
    
    private var refreshTimer: Timer?
    private var dataProcessingDelay: Timer?
    private var isProcessingConsent = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // Initial refresh with delay to ensure data is loaded
        refreshVendorDataWithDelay()
        
        // Auto-refresh every 3 seconds when consent changes
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            self?.refreshVendorDataWithDelay()
        }
    }
    
    deinit {
        refreshTimer?.invalidate()
        dataProcessingDelay?.invalidate()
    }
    
    private func setupUI() {
        title = "TCF Vendor API"
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
        setupTCFAnalysisSection()
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
    
    private func setupTCFAnalysisSection() {
        let sectionLabel = createSectionLabel("TCF String Analysis")
        stackView.addArrangedSubview(sectionLabel)
        
        let analysisContainer = UIView()
        analysisContainer.backgroundColor = .secondarySystemBackground
        analysisContainer.layer.cornerRadius = 8
        
        let analysisStackView = UIStackView()
        analysisStackView.axis = .vertical
        analysisStackView.spacing = 12
        analysisStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // TCF Analysis button
        tcfAnalysisButton.setTitle("Analyze TCF Strings", for: .normal)
        tcfAnalysisButton.backgroundColor = .systemOrange
        tcfAnalysisButton.setTitleColor(.white, for: .normal)
        tcfAnalysisButton.layer.cornerRadius = 8
        tcfAnalysisButton.addTarget(self, action: #selector(analyzeTCFStrings), for: .touchUpInside)
        tcfAnalysisButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        // Result label
        tcfAnalysisResultLabel.numberOfLines = 0
        tcfAnalysisResultLabel.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        tcfAnalysisResultLabel.textAlignment = .left
        tcfAnalysisResultLabel.text = "Tap 'Analyze TCF Strings' to compare raw consent data"
        tcfAnalysisResultLabel.textColor = .secondaryLabel
        
        analysisStackView.addArrangedSubview(tcfAnalysisButton)
        analysisStackView.addArrangedSubview(tcfAnalysisResultLabel)
        
        analysisContainer.addSubview(analysisStackView)
        
        NSLayoutConstraint.activate([
            analysisStackView.topAnchor.constraint(equalTo: analysisContainer.topAnchor, constant: 16),
            analysisStackView.leadingAnchor.constraint(equalTo: analysisContainer.leadingAnchor, constant: 16),
            analysisStackView.trailingAnchor.constraint(equalTo: analysisContainer.trailingAnchor, constant: -16),
            analysisStackView.bottomAnchor.constraint(equalTo: analysisContainer.bottomAnchor, constant: -16)
        ])
        
        stackView.addArrangedSubview(analysisContainer)
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
    
    @objc private func analyzeTCFStrings() {
        let userDefaults = UserDefaults.standard
        
        // Get TCF-related values from UserDefaults
        let tcfString = userDefaults.string(forKey: "IABTCF_TCString") ?? "Not found"
        let vendorConsents = userDefaults.string(forKey: "IABTCF_VendorConsents") ?? "Not found"
        let vendorLegitimateInterests = userDefaults.string(forKey: "IABTCF_VendorLegitimateInterests") ?? "Not found"
        let gdprApplies = userDefaults.object(forKey: "IABTCF_gdprApplies")
        let policyVersion = userDefaults.object(forKey: "IABTCF_PolicyVersion")
        
        // Analyze vendor consent string
        var analysis = "🔍 TCF String Analysis:\n\n"
        analysis += "📊 Basic Info:\n"
        analysis += "• GDPR Applies: \(gdprApplies ?? "Not set")\n"
        analysis += "• Policy Version: \(policyVersion ?? "Not set")\n"
        analysis += "• TC String Length: \(tcfString.count) chars\n\n"
        
        analysis += "🏪 Vendor Consents String:\n"
        if vendorConsents != "Not found" {
            analysis += "• Length: \(vendorConsents.count) chars\n"
            analysis += "• First 50 chars: \(String(vendorConsents.prefix(50)))...\n"
            
            // Try to decode basic vendor consent information
            let consentBits = vendorConsents
            analysis += "• Binary representation (first 100 bits): \(String(consentBits.prefix(100)))\n"
            
            // Count set bits (rough estimate of consented vendors)
            let setBits = consentBits.filter { $0 == "1" }.count
            analysis += "• Estimated consented vendors (set bits): \(setBits)\n"
        } else {
            analysis += "• ⚠️ IABTCF_VendorConsents not found!\n"
        }
        
        analysis += "\n🔐 Vendor Legitimate Interests:\n"
        if vendorLegitimateInterests != "Not found" {
            analysis += "• Length: \(vendorLegitimateInterests.count) chars\n"
            analysis += "• First 50 chars: \(String(vendorLegitimateInterests.prefix(50)))...\n"
        } else {
            analysis += "• ⚠️ IABTCF_VendorLegitimateInterests not found!\n"
        }
        
        // Compare with API results
        let allVendorConsents = Axeptio.shared.getVendorConsents()
        let consentedVendors = Axeptio.shared.getConsentedVendors()
        
        analysis += "\n🔗 API vs TCF String Comparison:\n"
        analysis += "• API Total Vendors: \(allVendorConsents.count)\n"
        analysis += "• API Consented Vendors: \(consentedVendors.count)\n"
        
        if vendorConsents != "Not found" {
            let setBits = vendorConsents.filter { $0 == "1" }.count
            analysis += "• TCF String Set Bits: \(setBits)\n"
            if setBits != consentedVendors.count {
                analysis += "• ⚠️ DISCREPANCY: API shows \(consentedVendors.count) consented, TCF string suggests \(setBits)\n"
            }
        }
        
        // Additional debugging info
        analysis += "\n🐛 Debug Info:\n"
        analysis += "• Timestamp: \(Date())\n"
        analysis += "• Vendor API refresh count: \(refreshTimer?.isValid == true ? "Active" : "Inactive")\n"
        
        tcfAnalysisResultLabel.text = analysis
        tcfAnalysisResultLabel.textColor = .label
        
        print("📋 [TCFAnalysis] Full Analysis:\n\(analysis)")
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    private func refreshVendorDataWithDelay() {
        // Cancel any existing delay timer
        dataProcessingDelay?.invalidate()
        
        // Mark as processing
        isProcessingConsent = true
        
        // Set a delay to allow consent processing to complete
        dataProcessingDelay = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                self?.isProcessingConsent = false
                self?.refreshVendorData()
            }
        }
    }
    
    private func refreshVendorData() {
        // Get all vendor consent data
        let allVendorConsents = Axeptio.shared.getVendorConsents()
        let consentedVendors = Axeptio.shared.getConsentedVendors()
        let refusedVendors = Axeptio.shared.getRefusedVendors()
        
        // Debug logging for vendor count investigation
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timestamp = formatter.string(from: Date())
        print("🔍 [VendorConsentDebug] Vendor Count Analysis [\(timestamp)]:")
        print("   Processing state: \(isProcessingConsent ? "PROCESSING" : "STABLE")")
        print("   Total vendors: \(allVendorConsents.count)")
        print("   Consented vendors: \(consentedVendors.count)")  
        print("   Refused vendors: \(refusedVendors.count)")
        print("   Sum (consented + refused): \(consentedVendors.count + refusedVendors.count)")
        
        // Detailed vendor ID analysis
        let allVendorIds = Set(allVendorConsents.keys)
        let consentedVendorIds = Set(consentedVendors)
        let refusedVendorIds = Set(refusedVendors)
        
        // Find discrepancies
        let inAllButNotInConsentedOrRefused = allVendorIds.subtracting(consentedVendorIds).subtracting(refusedVendorIds)
        let inConsentedButNotInAll = consentedVendorIds.subtracting(allVendorIds)
        let inRefusedButNotInAll = refusedVendorIds.subtracting(allVendorIds)
        
        if !inAllButNotInConsentedOrRefused.isEmpty {
            print("   ⚠️ Vendors in getVendorConsents() but missing from both consented/refused lists: \(Array(inAllButNotInConsentedOrRefused).sorted())")
        }
        if !inConsentedButNotInAll.isEmpty {
            print("   ⚠️ Vendors in getConsentedVendors() but missing from getVendorConsents(): \(Array(inConsentedButNotInAll).sorted())")
        }
        if !inRefusedButNotInAll.isEmpty {
            print("   ⚠️ Vendors in getRefusedVendors() but missing from getVendorConsents(): \(Array(inRefusedButNotInAll).sorted())")
        }
        
        // Log actual vendor IDs for analysis
        print("   All vendor IDs: \(Array(allVendorIds).sorted())")
        print("   Consented vendor IDs: \(consentedVendors.sorted())")
        print("   Refused vendor IDs: \(refusedVendors.sorted())")
        
        // Vendor ID range analysis
        if !allVendorIds.isEmpty {
            let sortedIds = Array(allVendorIds).sorted()
            let minId = sortedIds.first!
            let maxId = sortedIds.last!
            print("   📊 Vendor ID Range Analysis:")
            print("      Min ID: \(minId), Max ID: \(maxId)")
            print("      ID Range: \(minId)-\(maxId) (span: \(maxId - minId + 1))")
            print("      Actual vendor count: \(sortedIds.count)")
            
            // Check for gaps in vendor IDs
            let expectedRange = Set(minId...maxId)
            let missingIds = expectedRange.subtracting(allVendorIds)
            if !missingIds.isEmpty {
                print("      ⚠️ Missing vendor IDs in range: \(Array(missingIds).sorted())")
            }
            
            // Analyze vendor ID distribution
            let ranges = [
                (1, 100, "1-100"),
                (101, 500, "101-500"),
                (501, 1000, "501-1000"),
                (1001, 5000, "1001-5000"),
                (5001, Int.max, "5000+")
            ]
            
            print("      📈 Vendor ID Distribution:")
            for (min, max, label) in ranges {
                let count = sortedIds.filter { $0 >= min && $0 <= max }.count
                if count > 0 {
                    print("         \(label): \(count) vendors")
                }
            }
        }
        
        // Check for potential edge cases
        let vendorConsentStates = allVendorConsents.mapValues { $0 ? "✅" : "❌" }
        print("   Detailed consent states: \(vendorConsentStates.sorted { $0.key < $1.key })")
        
        // Special case analysis for 25 vs 24 vendor issue
        if allVendorConsents.count == 24 || consentedVendors.count == 24 || refusedVendors.count == 24 {
            print("   🚨 POTENTIAL 25vs24 ISSUE DETECTED:")
            print("      This might be the reported issue! Check for missing vendor ID.")
            
            // Check if we're missing exactly one vendor that should be there
            if let expectedTotalVendors = UserDefaults.standard.object(forKey: "expected_vendor_count") as? Int {
                print("      Expected vendors: \(expectedTotalVendors)")
            } else {
                print("      Expected vendors: 25 (based on configuration)")
            }
        }
        
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