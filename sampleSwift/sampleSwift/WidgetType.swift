//
//  WidgetType.swift
//  sampleSwift
//
//  Created by Ramiro Diaz on 24/10/2025.
//

enum WidgetType: Int {
    case production = 0
    case staging
    case pr
    
    var title: String {
        switch self {
        case .production:
            return "Production"
        case .staging:
            return "Staging"
        case .pr:
            return "PR"
        }
    }
}
