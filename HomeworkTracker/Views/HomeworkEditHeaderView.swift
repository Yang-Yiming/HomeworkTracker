//
//  HomeworkEditHeaderView.swift
//  HomeworkTracker
//
//  Created by 杨一鸣 on 2025/10/16.
//

import SwiftUI

struct HomeworkEditHeaderView: View {
    @Binding var isEditing: Bool
    var onSave: () -> Void
    var onDelete: () -> Void
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: {
                isEditing = false
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .fontWeight(.semibold)
                    Text("返回")
                }
                .foregroundStyle(Color.accentColor)
                .padding(.vertical, 4)
                .padding(.horizontal, 16)
                .glassEffect()
            }.buttonStyle(.plain)
            
            Spacer()
            
            Button(role: .destructive, action: {
                showDeleteConfirmation = true
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "trash")
                        .fontWeight(.semibold)
                    Text("删除")
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
                .foregroundStyle(Color.red)
                .glassEffect()
            }.buttonStyle(.plain)

            Button(action: {
                onSave()
                isEditing = false
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark")
                        .fontWeight(.semibold)
                    Text("保存")
                }
                .foregroundStyle(Color.accentColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
                .glassEffect()
            }.buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .border(width: 1, edges: [.bottom], color: .gray.opacity(0.2))
        .alert("确认删除？", isPresented: $showDeleteConfirmation) {
            Button("删除", role: .destructive) {
                onDelete()
            }
            Button("取消", role: .cancel) { }
        } message: {
            Text("删除后无法恢复该作业")
        }
    }
}

// Helper for border
extension View {
    func border(width: CGFloat, edges: [Edge], color: Color) -> some View {
        overlay(
            VStack {
                ForEach(edges, id: \.self) { edge in
                    if edge == .bottom {
                        VStack {
                            Spacer()
                            color
                                .frame(height: width)
                        }
                    }
                }
            }
        )
    }
}

#Preview {
    @State var isEditing = true
    
    return HomeworkEditHeaderView(
        isEditing: $isEditing,
        onSave: {},
        onDelete: {}
    )
}
