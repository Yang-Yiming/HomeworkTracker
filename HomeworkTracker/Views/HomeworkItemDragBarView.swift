//
//  HomeworkItemView.swift
//  HomeworkTracker
//
//  Created by 杨一鸣 on 2025/10/9.
//

import SwiftUI

struct HomeworkItemDragBarView: View {
    @Binding var homework: Homework
    
    // Drag state
    @State private var isDragging: Bool = false
    @State private var dragLocationX: CGFloat = 0.0
    
    var body: some View {
            GeometryReader { geometry in
                let width = geometry.size.width
                let height = geometry.size.height
                ZStack(alignment: .leading) {
                    // track
                    Capsule()
                        .fill(LinearGradient(gradient: Gradient(colors: [.gray.opacity(0.25), .gray.opacity(0.40)]), startPoint: .leading, endPoint: .trailing))
                        .frame(height:8)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged({value in
                                    isDragging = true
                                    let clamped = min(width, max(0, value.location.x))
                                    dragLocationX = clamped
                                })
                                .onEnded {
                                    _ in isDragging = false
                                    homework.progress = Float(dragLocationX / width)
                                }
                        )
                    
                    // completed
                    Capsule()
                        .fill(Color.accentColor)
                        .frame(width: max(0, CGFloat(homework.progress) * width), height: 8)
                        .animation(.interactiveSpring(response: 0.18, dampingFraction: 0.7), value: homework.progress)
                    
                    // Milestones
                    ForEach(homework.mileStones.indices, id: \.self) { idx in
                        let milestone = homework.mileStones[idx]
                        let fraction = CGFloat(min(max(milestone.0, 0), 1))
                        let x = fraction * width
                        VStack(spacing: 2) {
                            Rectangle()
                                .fill(Color.red)
                                .frame(width: 2, height: 12)
                                .cornerRadius(1)
                                .foregroundColor(.secondary)
                        }
                        .position(x: x, y: geometry.size.height / 2)
                    }
                    
                    // Thumb
                    
                    Capsule()
                        .fill(Color.secondary)  //
                        .frame(width: 20, height: 14)  // thumb 大小，可以调整
                        .position(x: dragLocationX, y: height / 2)
                        .opacity(isDragging ? 0.0 : 1.0)
                        .overlay {
                            if isDragging {
                                Capsule()
                                    .fill(Color.clear)
                                    .glassEffect(.clear)
                                    .frame(width: 30, height: 20)
                                    .transition(.opacity)
                                    .position(x: dragLocationX, y:height / 2)
                                    .animation(.easeInOut(duration: 0.1), value: isDragging)
                            }
                        }
                        .animation(.easeInOut(duration: 0.1), value: isDragging)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    // 切换到拖动状态（带动画）
                                    withAnimation {
                                        isDragging = true
                                    }
                                    let clamped = min(width, max(0, value.location.x))
                                    dragLocationX = clamped
                                }
                                .onEnded { _ in
                                    withAnimation {
                                        isDragging = false
                                    }
                                    homework.progress = Float(dragLocationX / width)
                                }
                        )
                    
                }.frame(height: 20)
            }
            .frame(height: 20)
            .padding()
        }
}


struct HomeworkItemDragBarView_Previews: PreviewProvider {
    @State static var hw = Homework(
            name: "Math Assignment",
            dueDate: Date().addingTimeInterval(3600)
        )
    static var previews: some View {
        HomeworkItemDragBarView(homework: $hw)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
