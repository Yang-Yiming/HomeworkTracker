//
//  HomeworkEditView.swift
//  HomeworkTracker
//
//  Created by 杨一鸣 on 2025/10/16.
//

import SwiftUI
import SwiftData

struct HomeworkEditView: View {
    @Bindable var homework: Homework
    @Binding var isEditing: Bool
    var onSave: () -> Void = {}
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        VStack(spacing: 0) {
            HomeworkEditHeaderView(
                isEditing: $isEditing,
                onSave: {
                    onSave()
                    try? modelContext.save()
                }
            )
            
            HomeworkEditFormView(homework: homework)
        }
    }
}

#Preview {
    @State var isEditing = true
    let container = try! ModelContainer(
        for: Homework.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let context = container.mainContext
    let hw = Homework(
        name: "Math Assignment",
        dueDate: Date().addingTimeInterval(86400 * 2)
    )
    context.insert(hw)
    
    return HomeworkEditView(homework: hw, isEditing: $isEditing)
        .modelContainer(container)
}
