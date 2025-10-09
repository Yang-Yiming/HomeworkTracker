//
//  Homework.swift
//  HomeworkTracker
//
//  Created by 杨一鸣 on 2025/10/9.
//

import Foundation

struct Homework {
    let id: UUID = UUID()
    var name: String
    var dueDate: Date
    
    var progress: Int // 0 - 100
    var mileStones: [(Int, String)] // Default [(70,"finished"),(90, "checked"),(100, "submitted")]
    
    init(
        name: String,
        dueDate: Date,
        mileStones: [(Int, String)]? = nil
    ){
        self.name = name
        self.dueDate = dueDate
        self.progress = 0
        self.mileStones = mileStones ?? [(70, "finished"),(90, "checked"),(100, "submitted")]
    }
    
    var time_to_DueDate: TimeInterval {
        return dueDate.timeIntervalSinceNow
    }
    
    var urgent_level: Float {
        let f_progress = Float(progress)
        let remaining = Float(time_to_DueDate)
        return (100 - f_progress) / (remaining + 0.01)
    }
    
}
