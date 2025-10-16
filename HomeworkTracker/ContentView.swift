//
//  ContentView.swift
//  HomeworkTracker
//
//  Created by 杨一鸣 on 2025/10/9.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var homeworkList: [Homework]
    @State private var selectedHomework: Homework? = nil
    
    var body: some View {
        NavigationSplitView {
            // 左侧：空菜单栏（预留给未来功能）
            VStack {
                VStack(alignment: .leading, spacing: 16) {
                    Text("功能菜单")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    
                    Text("敬请期待...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 16)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
            }
            .background(.ultraThinMaterial)
        } detail: {
            // 右侧：作业列表 + 编辑/统计面板
            HStack(spacing: 0) {
                let homeworkListBinding = Binding(
                    get: { homeworkList },
                    set: { _ in }
                )
                
                HomeworkListView(homeworkList: homeworkListBinding, selectedHomework: $selectedHomework)
                    .frame(minWidth: 400, idealWidth: 520)
                
                Divider()
                
                HomeworkDetailPanel(selectedHomework: $selectedHomework, homeworkList: homeworkListBinding)
                    .frame(minWidth: 280, idealWidth: 350)
            }
        }
#if os(macOS)
        .navigationSplitViewColumnWidth(min: 180, ideal: 220)
#endif
    }
}

#Preview {
    ContentView(
        homeworkList: [
            Homework(name: "Math Assignment", dueDate: Date().addingTimeInterval(86400 * 2)),
            Homework(name: "Physics Lab Report", dueDate: Date().addingTimeInterval(86400 * 1)),
            Homework(name: "English Essay", dueDate: Date().addingTimeInterval(86400 * 5)),
            Homework(name: "History Project", dueDate: Date().addingTimeInterval(-86400 * 1)),
            Homework(name: "Chemistry Quiz Prep", dueDate: Date().addingTimeInterval(86400 * 3)),
        ]
    )
}
