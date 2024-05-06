//
//  TCFFields.swift
//  sampleSwift
//
//  Created by Noeline PAGESY on 21/02/2024.
//

import Foundation

public enum TCFFields: String, CaseIterable {
    case cmpSdkId = "IABTCF_CmpSdkID"
    case cmpSdkVersion = "IABTCF_CmpSdkVersion"
    case gdprApplies = "IABTCF_gdprApplies"
    case policyVersion = "IABCTF_PolicyVersion"
    case publisherCC = "IABTCF_PublisherCC"
    case publisherConsent = "IABTCF_PublisherConsent"
    case publisherCustomPurposesConsents = "IABTCF_PublisherCustomPurposesConsents"
    // swiftlint:disable identifier_name
    case publisherCustomPurposesLegitimateInterests = "IABTCF_PublisherCustomPurposesLegitimateInterests"
    // swiftlint:enable identifier_name
    case publisherLegitimateInterests = "IABTCF_PublisherLegitimateInterests"
    case publisherRestrictions = "IABTCF_PublisherRestrictions"
    case purposeConsents = "IABTCF_PurposeConsents"
    case purposeLegitimateInterests = "IABTCF_PurposeLegitimateInterests"
    case purposeOneTreatment = "IABTCF_PurposeOneTreatment"
    case specialFeaturesOptIns = "IABTCF_SpecialFeaturesOptIns"
    case tcString = "IABTCF_TCString"
    case useNonStandardTexts = "IABTCF_UseNonStandardTexts"
    case vendorConsents = "IABTCF_VendorConsents"
    case vendorLegitimateInterests = "IABTCF_VendorLegitimateInterests"
    case addtlConsent = "IABTCF_AddtlConsent"
}
