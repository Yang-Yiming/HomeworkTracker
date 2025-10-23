//
//  AutomationManager.swift
//  HomeworkTracker
//
//  Created by GitHub Copilot on 2025/10/23.
//

import Foundation
import Combine
import SwiftData

@MainActor
final class AutomationManager: ObservableObject {
    // Needed for strict concurrency conformance to ObservableObject
    nonisolated let objectWillChange = ObservableObjectPublisher()
    private weak var modelContext: ModelContext?

    func start(context: ModelContext) {
        self.modelContext = context
        // Run once at app open per requirement
        Task { [weak self] in await self?.runCleanup() }
    }

    func stop() {
        modelContext = nil
    }

    /// Delete completed homework older than the retention window if automation is enabled.
    private func runCleanup() async {
        guard AutomationSettings.isAutoDeleteEnabled else { return }
        let days = AutomationSettings.retentionDays
        let cutoff = Date().addingTimeInterval(TimeInterval(-days * 24 * 3600))

        guard let context = modelContext else { return }
        do {
            // Delete items that are completed and due date is older than retention window
            let descriptor = FetchDescriptor<Homework>(predicate: #Predicate { hw in
                hw.progress >= 1.0 && hw.dueDate < cutoff
            })
            let toDelete = try context.fetch(descriptor)
            guard !toDelete.isEmpty else { return }
            toDelete.forEach { context.delete($0) }
            try context.save()
        } catch {
            // Silently ignore in production; consider logging
            #if DEBUG
            print("Automation cleanup failed: \(error)")
            #endif
        }
    }
}
