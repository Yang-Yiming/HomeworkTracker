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
            }
            
            Spacer()
            
            Button(action: {
                onSave()
                isEditing = false
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark")
                        .fontWeight(.semibold)
                    Text("保存")
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.accentColor)
                .cornerRadius(8)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .border(width: 1, edges: [.bottom], color: .gray.opacity(0.2))
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
        onSave: {}
    )
}
