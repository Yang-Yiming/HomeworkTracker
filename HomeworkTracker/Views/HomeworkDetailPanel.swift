//
//  HomeworkDetailPanel.swift
//  HomeworkTracker
//
//  Created by 杨一鸣 on 2025/10/16.
//

import SwiftUI
import SwiftData

struct HomeworkDetailPanel: View {
    @Binding var selectedHomework: Homework?
    var homeworkList: [Homework]
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        ZStack {
            if let homework = selectedHomework,
               homeworkList.contains(where: { $0.id == homework.id }) {
                HomeworkEditView(
                    homework: homework,
                    isEditing: Binding(
                        get: { true },
                        set: { if !$0 { selectedHomework = nil } }
                    ),
                    onSave: {
                        selectedHomework = homework
                    },
                    onDelete: {
                        modelContext.delete(homework)
                        try? modelContext.save()
                        selectedHomework = nil
                    }
                )
            } else {
                HomeworkStatsView(homeworkList: homeworkList)
            }
        }
    }
}

#Preview {
    struct DetailPreview: View {
        @State var selection: Homework?
        let container: ModelContainer
        let items: [Homework]
        
        var body: some View {
            HomeworkDetailPanel(selectedHomework: $selection, homeworkList: items)
                .modelContainer(container)
        }
    }
    
    let container = try! ModelContainer(
        for: Homework.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let context = container.mainContext
    let hwList: [Homework] = [
        Homework(name: "Math Assignment", dueDate: Date().addingTimeInterval(86400 * 2)),
        Homework(name: "Physics Lab Report", dueDate: Date().addingTimeInterval(86400 * 1)),
        Homework(name: "English Essay", dueDate: Date().addingTimeInterval(86400 * 5))
    ]
    hwList.forEach { context.insert($0) }
    
    return DetailPreview(selection: hwList.first, container: container, items: hwList)
}
