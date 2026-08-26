import Foundation

// Deliberate SwiftLint violations, to prove the required check fails a bad PR.
struct LintCanary {   
    static func canary(_ value: Any) -> String {
        return value as! String
    }
}
