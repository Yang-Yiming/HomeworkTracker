//
//  HomeworkEditFormView.swift
//  HomeworkTracker
//
//  Created by 杨一鸣 on 2025/10/16.
//

import SwiftUI
import SwiftData

struct HomeworkEditFormView: View {
    @Bindable var homework: Homework
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Basic Info Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("基本信息")
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.horizontal, 4)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Label("作业名称", systemImage: "pencil.line")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        
                        TextField("输入作业名称", text: $homework.name)
                            .padding(8)
                            .cornerRadius(20)
                            .glassEffect(in: .rect(cornerRadius: 10))
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Label("截止日期", systemImage: "calendar")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        
                        DatePicker(
                            "select",
                            selection: $homework.dueDate,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(.field)
                        .padding(8)
                        .glassEffect(in: .rect(cornerRadius: 10))
                    }
                }
                .padding(16)
                .glassEffect(in : .rect(
                    cornerRadius: 20
                ))
                
                
                // Progress Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("进度")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Text("\(Int(homework.progress * 100))%")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.accentColor)
                    }
                    .padding(.horizontal, 4)
                    
                    VStack(spacing: 12) {
                        // Progress Slider
                        Slider(
                            value: $homework.progress,
                            in: 0...1,
                            step: 0.01
                        )
                        .tint(.accentColor)
                        .padding(.vertical, 4)
                        
                    }
                }
                .padding(16)
                .glassEffect(in: .rect(
                    cornerRadius: 20
                ))
                
                // Milestones Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("里程碑")
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.horizontal, 4)
                    
                    VStack(spacing: 10) {
                        ForEach(homework.mileStones) { milestone in
                            MilestoneRow(
                                milestone: binding(for: milestone),
                                onDelete: {
                                    removeMilestone(withId: milestone.id)
                                }
                            )
                        }
                        
                        Button(action: {
                            homework.mileStones.append(Milestone(progress: 0.5, title: "新里程碑"))
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundStyle(Color.accentColor)
                                Text("添加里程碑")
                                    .foregroundStyle(Color.accentColor)
                                Spacer()
                            }
                            .padding(8)
                            .cornerRadius(10)
                        }
                    }
                }
                .padding(16)
                .cornerRadius(19)
                .glassEffect(in: .rect(
                    cornerRadius: 20
                ))
                
                // Info Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("信息")
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.horizontal, 4)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        InfoRow(label: "紧急程度", value: urgencyLabel)
                        InfoRow(label: "距截止", value: timeRemainingLabel)
                        InfoRow(label: "状态", value: statusLabel)
                    }
                }
                .padding(16)
                .glassEffect(in: .rect(cornerRadius: 20))
                
                Spacer(minLength: 20)
            }
            .padding(16)
        }
    }
    
    private func binding(for milestone: Milestone) -> Binding<Milestone> {
        Binding(
            get: {
                homework.mileStones.first(where: { $0.id == milestone.id }) ?? milestone
            },
            set: { updated in
                guard let index = homework.mileStones.firstIndex(where: { $0.id == milestone.id }) else { return }
                homework.mileStones[index] = updated
            }
        )
    }
    
    private func removeMilestone(withId id: Milestone.ID) {
        guard let index = homework.mileStones.firstIndex(where: { $0.id == id }) else { return }
        homework.mileStones.remove(at: index)
    }
    
    private var urgencyLabel: String {
        let level = homework.urgent_level
        if homework.progress >= 1 { return "已完成" }
        if homework.dueDate < Date() { return "已逾期" }
        if level > 0.9 { return "紧急" }
        if level > 0.5 { return "高" }
        if level > 0.3 { return "中" }
        return "低"
    }
    
    private var timeRemainingLabel: String {
        let fmt = DateComponentsFormatter()
        fmt.allowedUnits = [.day, .hour]
        fmt.maximumUnitCount = 2
        fmt.unitsStyle = .abbreviated
        let secs = abs(homework.time_to_DueDate)
        let unit = fmt.string(from: secs) ?? ""
        return homework.dueDate < Date() ? "已逾期 \(unit)" : "还剩 \(unit)"
    }
    
    private var statusLabel: String {
        if homework.progress >= 1 { return "✅ 已完成" }
        if homework.progress >= 0.9 { return "📋 已检查" }
        if homework.progress >= 0.7 { return "⚡ 已完成" }
        if homework.progress > 0 { return "🔄 进行中" }
        return "📕 未开始"
    }
}

// MARK: - Progress Button
private struct ProgressButton: View {
    var label: String
    var value: Double
    @Binding var progress: Double
    
    var body: some View {
        Button(action: {
            progress = value
        }) {
            Text(label)
                .frame(maxWidth: .infinity)
                .padding(8)
                .background(progress == value ? Color.accentColor : Color.gray.opacity(0.2))
                .foregroundStyle(progress == value ? .white : .primary)
                .cornerRadius(6)
        }
    }
}

// MARK: - Milestone Row
private struct MilestoneRow: View {
    @Binding var milestone: Milestone
    var onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            HStack(alignment: .center, spacing: 10) {
                Text("进度:")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                
                TextField("0-100%", value: $milestone.progress, format: .percent)
                    .textFieldStyle(.plain)
                    .padding(5)
                    .glassEffect(in: .rect(cornerRadius: 8))
                    .frame(width: 80)
                    
                TextField("里程碑名称", text: $milestone.title)
                    .font(.body)
                    .textFieldStyle(.plain)
                    .padding(5)
                    .glassEffect(in: .rect(cornerRadius: 8))
            }
            
            Button(action: onDelete) {
                Image(systemName: "trash.fill")
                    .foregroundStyle(.red)
            }
        }
        .padding(6)
        .glassEffect(in: .rect(cornerRadius: 8))
    }
}

// MARK: - Info Row
private struct InfoRow: View {
    var label: String
    var value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
    }
}

#Preview {
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
    
    return HomeworkEditFormView(homework: hw)
        .modelContainer(container)
}
