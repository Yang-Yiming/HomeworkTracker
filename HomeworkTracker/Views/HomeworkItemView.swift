//
//  HomeworkItemView.swift
//  HomeworkTracker
//
//  Created by 杨一鸣 on 2025/10/10.
//

import SwiftUI

struct HomeworkItemView: View {
    @Binding var homework: Homework
    @Environment(\.colorScheme) private var colorScheme
    
    private var progressPercent: Int { Int((homework.progress * 100).rounded()) }
    private var isOverdue: Bool { homework.dueDate < Date() }
    private var urgencyTint: Color {
        let urgent_level = homework.urgent_level
        if homework.progress >= 1 { return .green }
        if isOverdue { return .red }
        if urgent_level > 0.9 { return .red }
        if urgent_level > 0.5 { return .orange }
        if urgent_level > 0.3 { return .yellow }
        return .blue
    }
    private var progressIcon: String {
        homework.progress >= 1 ? "checkmark.seal.fill" : (homework.progress >= 0.7 ? "bolt.fill" : "book.fill")
    }
    private var dueRelative: String {
        let fmt = DateComponentsFormatter()
        fmt.allowedUnits = [.day, .hour, .minute]
        fmt.maximumUnitCount = 1
        fmt.unitsStyle = .abbreviated
        let secs = abs(homework.time_to_DueDate)
        let unit = fmt.string(from: secs) ?? ""
        return isOverdue ? "Overdue \(unit)" : "Due in \(unit)"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Label(homework.name, systemImage: progressIcon)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                Spacer(minLength: 8)
                HStack(spacing: 6) {
                    Image(systemName: "calendar.badge.clock")
                    Text(homework.dueDate, style: .date)
                    Text(homework.dueDate, style: .time)
                        .foregroundStyle(.secondary)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            HStack(spacing: 8) {
                Chip(icon: "clock.fill", text: dueRelative, tint: isOverdue ? .red : Color.secondary)
                Chip(icon: "checkmark.circle.fill", text: "\(progressPercent)%", tint: .accentColor)
            }
            
            HomeworkItemDragBarView(homework: $homework)
                .padding(.top, 2)
        }
        .padding(14)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [urgencyTint.opacity(colorScheme == .dark ? 0.22 : 0.16), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(.white.opacity(colorScheme == .dark ? 0.06 : 0.12))
        )
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.25 : 0.08), radius: 12, x: 0, y: 6)
    }
}

private struct Chip: View {
    var icon: String
    var text: String
    var tint: Color
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon).imageScale(.small)
            Text(text).font(.caption).fontWeight(.semibold)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Capsule().fill(tint.opacity(0.12)))
        .foregroundStyle(tint)
    }
}

struct HomeworkItemView_Previews: PreviewProvider {
    @State static var hw = Homework(
            name: "Math Assignment",
            dueDate: Date().addingTimeInterval(3600)
        )
    static var previews: some View {
        VStack(spacing: 16) {
            HomeworkItemView(homework: $hw)
                .padding()
                .previewLayout(.sizeThatFits)
        }
        .padding()
        .background(.background)
    }
}
