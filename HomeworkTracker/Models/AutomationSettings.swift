//
//  AutomationSettings.swift
//  HomeworkTracker
//
//  Created by GitHub Copilot on 2025/10/23.
//

import Foundation

enum AutomationSettings {
    static let autoDeleteEnabledKey = "automation.autoDeleteEnabled"
    static let autoDeleteRetentionDaysKey = "automation.autoDeleteRetentionDays"

    static var isAutoDeleteEnabled: Bool {
        get { UserDefaults.standard.object(forKey: autoDeleteEnabledKey) as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: autoDeleteEnabledKey) }
    }

    static var retentionDays: Int {
        get {
            let raw = UserDefaults.standard.object(forKey: autoDeleteRetentionDaysKey) as? Int ?? 7
            return max(1, raw)
        }
        set {
            let clamped = max(1, newValue)
            UserDefaults.standard.set(clamped, forKey: autoDeleteRetentionDaysKey)
        }
    }
}
