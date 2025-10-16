//
//  HomeworkDetailPanel.swift
//  HomeworkTracker
//
//  Created by 杨一鸣 on 2025/10/16.
//

import SwiftUI

struct HomeworkDetailPanel: View {
    @Binding var selectedHomework: Homework?
    @Binding var homeworkList: [Homework]
    
    var body: some View {
        ZStack {
            if let index = homeworkList.firstIndex(where: { $0.id == selectedHomework?.id }) {
                // Editing State
                HomeworkEditView(
                    homework: $homeworkList[index],
                    isEditing: Binding(
                        get: { true },
                        set: { if !$0 { selectedHomework = nil } }
                    ),
                    onSave: {
                        selectedHomework = homeworkList[index]
                    }
                )
            } else {
                // Idle State: Show Stats
                HomeworkStatsView(homeworkList: homeworkList)
            }
        }
    }
}

#Preview {
    @State var selectedHW: Homework? = nil
    @State var hwList: [Homework] = [
        Homework(name: "Math Assignment", dueDate: Date().addingTimeInterval(86400 * 2)),
        Homework(name: "Physics Lab Report", dueDate: Date().addingTimeInterval(86400 * 1)),
        Homework(name: "English Essay", dueDate: Date().addingTimeInterval(86400 * 5)),
    ]
    
    return HomeworkDetailPanel(selectedHomework: $selectedHW, homeworkList: $hwList)
}
