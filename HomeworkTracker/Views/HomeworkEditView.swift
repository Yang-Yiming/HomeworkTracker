//
//  HomeworkEditView.swift
//  HomeworkTracker
//
//  Created by 杨一鸣 on 2025/10/16.
//

import SwiftUI

struct HomeworkEditView: View {
    @Binding var homework: Homework
    @Binding var isEditing: Bool
    var onSave: () -> Void = {}
    
    var body: some View {
        VStack(spacing: 0) {
            HomeworkEditHeaderView(
                homework: $homework,
                isEditing: $isEditing,
                onSave: onSave
            )
            
            HomeworkEditFormView(homework: $homework)
        }
    }
}

#Preview {
    @State var hw = Homework(
        name: "Math Assignment",
        dueDate: Date().addingTimeInterval(86400 * 2)
    )
    @State var isEditing = true
    
    return HomeworkEditView(homework: $hw, isEditing: $isEditing)
}
