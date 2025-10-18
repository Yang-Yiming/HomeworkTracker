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
                            .padding(12)
                            .background(.ultraThinMaterial)
                            .cornerRadius(10)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Label("截止日期", systemImage: "calendar")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        
                        DatePicker(
                            "选择日期",
                            selection: $homework.dueDate,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(.compact)
                        .padding(12)
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                    }
                }
                .padding(16)
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                
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
                        
                        // Progress Bar Visual
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(.gray.opacity(0.2))
                                .frame(height: 12)
                            
                            Capsule()
                                .fill(Color.accentColor)
                                .frame(width: CGFloat(homework.progress) * 280, height: 12)
                        }
                        
                        // Quick Progress Buttons
                        HStack(spacing: 8) {
                            ProgressButton(label: "0%", value: 0, progress: $homework.progress)
                            ProgressButton(label: "25%", value: 0.25, progress: $homework.progress)
                            ProgressButton(label: "50%", value: 0.5, progress: $homework.progress)
                            ProgressButton(label: "75%", value: 0.75, progress: $homework.progress)
                            ProgressButton(label: "100%", value: 1.0, progress: $homework.progress)
                        }
                        .font(.caption)
                        .fontWeight(.semibold)
                    }
                }
                .padding(16)
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                
                // Milestones Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("里程碑")
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.horizontal, 4)
                    
                    VStack(spacing: 10) {
                        ForEach(Array(homework.mileStones.enumerated()), id: \.element.id) { index, _ in
                            MilestoneRow(
                                milestone: Binding(
                                    get: { homework.mileStones[index] },
                                    set: { homework.mileStones[index] = $0 }
                                ),
                                onDelete: {
                                    homework.mileStones.remove(at: index)
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
                            .padding(12)
                            .background(Color.accentColor.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }
                }
                .padding(16)
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                
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
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                
                Spacer(minLength: 20)
            }
            .padding(16)
        }
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
            VStack(alignment: .leading, spacing: 6) {
                Text("进度: \(Int(milestone.progress * 100))%")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                
                TextField("里程碑名称", text: $milestone.title)
                    .font(.body)
                    .textFieldStyle(.roundedBorder)
            }
            
            Button(action: onDelete) {
                Image(systemName: "trash.fill")
                    .foregroundStyle(.red)
            }
        }
        .padding(12)
        .background(.gray.opacity(0.1))
        .cornerRadius(8)
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
