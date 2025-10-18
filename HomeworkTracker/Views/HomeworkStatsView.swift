//
//  HomeworkStatsView.swift
//  HomeworkTracker
//
//  Created by 杨一鸣 on 2025/10/16.
//

import SwiftUI
import SwiftData

struct HomeworkStatsView: View {
    var homeworkList: [Homework]
    
    private var totalCount: Int {
        homeworkList.count
    }
    
    private var completedCount: Int {
        homeworkList.filter { $0.progress >= 1.0 }.count
    }
    
    private var inProgressCount: Int {
        homeworkList.filter { $0.progress > 0 && $0.progress < 1.0 }.count
    }
    
    private var notStartedCount: Int {
        homeworkList.filter { $0.progress == 0 }.count
    }
    
    private var overdueCount: Int {
        homeworkList.filter { $0.dueDate < Date() && $0.progress < 1.0 }.count
    }
    
    private var avgProgress: Double {
        guard !homeworkList.isEmpty else { return 0 }
        let totalProgress = homeworkList.reduce(0.0) { $0 + $1.progress }
        return totalProgress / Double(homeworkList.count)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("统计概览")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("共 \(totalCount) 项作业")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(.ultraThinMaterial)
                
                VStack(spacing: 12) {
                    // Overall Progress
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("整体进度")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Spacer()
                            Text("\(Int(avgProgress * 100))%")
                                .font(.headline)
                                .foregroundStyle(Color.accentColor
                                )
                        }
                        
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(.gray.opacity(0.2))
                                .frame(height: 8)
                            
                            Capsule()
                                .fill(Color.accentColor)
                                .frame(width: CGFloat(avgProgress) * 220, height: 8)
                        }
                    }
                    .padding(16)
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    
                    // Stats Grid
                    VStack(spacing: 10) {
                        HStack(spacing: 10) {
                            StatCard(
                                icon: "checkmark.circle.fill",
                                iconColor: .green,
                                title: "已完成",
                                value: "\(completedCount)",
                                subtitle: "已提交"
                            )
                            
                            StatCard(
                                icon: "bolt.fill",
                                iconColor: .orange,
                                title: "进行中",
                                value: "\(inProgressCount)",
                                subtitle: "处理中"
                            )
                        }
                        
                        HStack(spacing: 10) {
                            StatCard(
                                icon: "book.fill",
                                iconColor: .blue,
                                title: "未开始",
                                value: "\(notStartedCount)",
                                subtitle: "待进行"
                            )
                            
                            StatCard(
                                icon: "exclamationmark.triangle.fill",
                                iconColor: .red,
                                title: "已逾期",
                                value: "\(overdueCount)",
                                subtitle: "需要处理"
                            )
                        }
                    }
                    .padding(12)
                    
                    // Next Due
                    if let nextDue = homeworkList
                        .filter({ $0.progress < 1.0 })
                        .min(by: { $0.dueDate < $1.dueDate }) {
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Label("最近截止", systemImage: "calendar.badge.clock")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(nextDue.name)
                                        .font(.body)
                                        .fontWeight(.semibold)
                                        .lineLimit(2)
                                    
                                    Text(nextDue.dueDate, style: .date)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                if nextDue.dueDate < Date() {
                                    Label("已逾期", systemImage: "exclamationmark.circle.fill")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.red)
                                } else {
                                    Text(nextDue.dueDate, style: .relative)
                                        .font(.caption)
                                        .foregroundStyle(.orange)
                                }
                            }
                        }
                        .padding(16)
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                    }
                }
                .padding(12)
                
                Spacer()
            }
        }
    }
}

// MARK: - Stat Card Component
private struct StatCard: View {
    var icon: String
    var iconColor: Color
    var title: String
    var value: String
    var subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(iconColor)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(value)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                }
                
                Spacer()
            }
            
            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .cornerRadius(10)
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Homework.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let context = container.mainContext
    let previewList: [Homework] = [
        Homework(name: "Math Assignment", dueDate: Date().addingTimeInterval(86400 * 2)),
        Homework(name: "Physics Lab Report", dueDate: Date().addingTimeInterval(86400 * 1)),
        Homework(name: "English Essay", dueDate: Date().addingTimeInterval(86400 * 5)),
        Homework(name: "History Project", dueDate: Date().addingTimeInterval(-86400 * 1)),
        Homework(name: "Chemistry Quiz Prep", dueDate: Date().addingTimeInterval(86400 * 3))
    ]
    previewList.forEach { context.insert($0) }
    
    return HomeworkStatsView(homeworkList: previewList)
        .padding()
        .modelContainer(container)
}
