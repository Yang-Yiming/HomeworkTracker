//
//  Item.swift
//  HomeworkTracker
//
//  Created by 杨一鸣 on 2025/10/9.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
