//
//  Homework.swift
//  HomeworkTracker
//
//  Created by 杨一鸣 on 2025/10/9.
//

import Foundation
import SwiftData

@Model
final class Homework {
    var id: UUID
    var name: String
    var dueDate: Date
    var progress: Double
    var difficulty: Int8? // lightweight migration
    @Attribute(.externalStorage) var mileStones: [Milestone]
    
    init(
        id: UUID = UUID(),
        name: String,
        dueDate: Date,
    progress: Double = 0.0,
    difficulty: Int8? = nil,
        mileStones: [Milestone]? = nil
    ) {
        self.id = id
        self.name = name
        self.dueDate = dueDate
    self.progress = progress
    self.difficulty = difficulty ?? 0
        self.mileStones = mileStones ?? [
            Milestone(progress: 0.7, title: "finished"),
            Milestone(progress: 0.9, title: "checked"),
            Milestone(progress: 1.0, title: "submitted")
        ]
    }
    
    var time_to_DueDate: TimeInterval {
        dueDate.timeIntervalSinceNow
    }
    
    var urgent_level: Double {
        let remaining = time_to_DueDate / 3600 / 24 // days left
        // Clamp difficulty to non-negative to avoid unexpected bit shifts and overflow
        let clampedDifficulty = max(0, Int(difficulty ?? 0))
        let difficultyMultiplier = pow(1.2, Double(clampedDifficulty))
        return difficultyMultiplier * (1.0 - progress) / (remaining + 0.01)
    }
}

struct Milestone: Codable, Hashable, Identifiable {
    var id: UUID
    var progress: Double
    var title: String
    
    init(id: UUID = UUID(), progress: Double, title: String) {
        self.id = id
        self.progress = progress
        self.title = title
    }
}
