//
//  Homework.swift
//  HomeworkTracker
//
//  Created by 杨一鸣 on 2025/10/9.
//

import Foundation

struct Homework: Identifiable {
    let id: UUID = UUID()
    var name: String
    var dueDate: Date
    
    var progress: Float // 0 - 1
    var mileStones: [(Float, String)] // Default [(70,"finished"),(90, "checked"),(100, "submitted")]
    
    init(
        name: String,
        dueDate: Date,
        mileStones: [(Float, String)]? = nil
    ){
        self.name = name
        self.dueDate = dueDate
        self.progress = 0.0
        self.mileStones = mileStones ?? [(0.7, "finished"),(0.9, "checked"),(1.0, "submitted")]
    }
    
    var time_to_DueDate: TimeInterval {
        return dueDate.timeIntervalSinceNow
    }
    
    var urgent_level: Float {
        let remaining = Float(time_to_DueDate)
        return (1.0 - progress) / (remaining + 0.01)
    }
    
}
