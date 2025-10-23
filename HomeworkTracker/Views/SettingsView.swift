//
//  SettingsView.swift
//  HomeworkTracker
//
//  Created by GitHub Copilot on 2025/10/23.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage(AutomationSettings.autoDeleteEnabledKey) private var autoDeleteEnabled: Bool = true
    @AppStorage(AutomationSettings.autoDeleteRetentionDaysKey) private var retentionDays: Int = 7
    
    var body: some View {
        NavigationStack {
            List {
                Section("通用") {
                    Text("Nothing here now...")
                }
                
                Section("自动化"){
                    Toggle(isOn: $autoDeleteEnabled) { Text("自动删除完成项目") }
                    if autoDeleteEnabled {
                        HStack {
                            Text("保留")
                            TextField("天数", value: $retentionDays, format: .number)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 40)
                                .multilineTextAlignment(.center)
                            Text("Day")
                        }
                        .onChange(of: retentionDays) { oldValue, newValue in
                            // Clamp to at least 1 day
                            if newValue < 1 { retentionDays = 1 }
                        }
                    }
                }

                Section("关于") {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("设置")
        }
        .frame(minWidth: 420, idealWidth: 480, maxWidth: 640,
               minHeight: 440, idealHeight: 560, maxHeight: 800)
    }
}

#Preview {
    SettingsView()
}
