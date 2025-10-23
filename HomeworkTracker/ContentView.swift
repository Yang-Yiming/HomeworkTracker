//
//  ContentView.swift
//  HomeworkTracker
//
//  Created by 杨一鸣 on 2025/10/9.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Homework.dueDate, order: .forward)]) private var homeworkList: [Homework]
    @State private var selectedHomework: Homework? = nil
    @StateObject private var automationManager = AutomationManager()
    
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
                HomeworkListView(homeworkList: homeworkList, selectedHomework: $selectedHomework)
                    .frame(minWidth: 400, idealWidth: 520)
                
                Divider()
                
                HomeworkDetailPanel(selectedHomework: $selectedHomework, homeworkList: homeworkList)
                    .frame(minWidth: 280, idealWidth: 350)
            }
        }
#if os(macOS)
        .navigationSplitViewColumnWidth(min: 180, ideal: 220)
#endif
        .task {
            if homeworkList.isEmpty {
                seedSampleHomework()
            }
            // Start automation after initial seeding
            automationManager.start(context: modelContext)
        }
        .onDisappear { automationManager.stop() }
    }

    private func seedSampleHomework() {
        let samples: [Homework] = [
            Homework(name: "Math Assignment", dueDate: Date().addingTimeInterval(86400 * 2)),
            Homework(name: "Physics Lab Report", dueDate: Date().addingTimeInterval(86400 * 1)),
            Homework(name: "English Essay", dueDate: Date().addingTimeInterval(86400 * 5)),
            Homework(name: "History Project", dueDate: Date().addingTimeInterval(-86400 * 1)),
            Homework(name: "Chemistry Quiz Prep", dueDate: Date().addingTimeInterval(86400 * 3))
        ]
        samples.forEach { modelContext.insert($0) }
        try? modelContext.save()
    }
}

#Preview {
    ContentView()
        .modelContainer(previewModelContainer)
}

private let previewModelContainer: ModelContainer = {
    let container = try! ModelContainer(
        for: Homework.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let context = container.mainContext
    let fetch = (try? context.fetch(FetchDescriptor<Homework>())) ?? []
    if fetch.isEmpty {
        let samples: [Homework] = [
            Homework(name: "Math Assignment", dueDate: Date().addingTimeInterval(86400 * 2)),
            Homework(name: "Physics Lab Report", dueDate: Date().addingTimeInterval(86400 * 1)),
            Homework(name: "English Essay", dueDate: Date().addingTimeInterval(86400 * 5)),
            Homework(name: "History Project", dueDate: Date().addingTimeInterval(-86400 * 1)),
            Homework(name: "Chemistry Quiz Prep", dueDate: Date().addingTimeInterval(86400 * 3))
        ]
        samples.forEach { context.insert($0) }
    }
    return container
}()
