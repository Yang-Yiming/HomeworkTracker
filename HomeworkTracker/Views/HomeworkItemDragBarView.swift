//
//  HomeworkItemView.swift
//  HomeworkTracker
//
//  Created by 杨一鸣 on 2025/10/9.
//

import SwiftUI
import SwiftData

struct HomeworkItemDragBarView: View {
    @Bindable var homework: Homework
    @Environment(\.modelContext) private var modelContext
    
    // Drag state
    @State private var isDragging: Bool = false
    @State private var dragLocationX: CGFloat = 0.0
    @State private var dragAxisLocked: Bool = false
    @State private var isHorizontalDrag: Bool = false
    
    var body: some View {
            GeometryReader { geometry in
                let width = geometry.size.width
                let height = geometry.size.height
                let thumbPosition = isDragging ? dragLocationX : CGFloat(homework.progress) * width
                ZStack(alignment: .leading) {
                    // track
                    Capsule()
                        .fill(LinearGradient(gradient: Gradient(colors: [.gray.opacity(0.25), .gray.opacity(0.40)]), startPoint: .leading, endPoint: .trailing))
                        .frame(height:8)
                        .gesture(
                            DragGesture(minimumDistance: 6)
                                .onChanged({ value in
                                    // Axis lock: only react to horizontal drags so vertical scroll stays responsive
                                    if !dragAxisLocked {
                                        let dx = abs(value.translation.width)
                                        let dy = abs(value.translation.height)
                                        if dx > 6 || dy > 6 {
                                            dragAxisLocked = true
                                            isHorizontalDrag = dx > dy
                                        } else {
                                            return
                                        }
                                    }
                                    guard isHorizontalDrag else { return }

                                    isDragging = true
                                    let clamped = min(width, max(0, value.location.x))
                                    dragLocationX = clamped
                                    // Defer model updates until .onEnded to avoid frequent @Model change notifications
                                })
                                .onEnded { _ in
                                    isDragging = false
                                    if isHorizontalDrag {
                                        homework.progress = Double(dragLocationX / width)
                                        try? modelContext.save()
                                    }
                                    // reset axis lock
                                    dragAxisLocked = false
                                    isHorizontalDrag = false
                                }
                        )
                    
                    // completed
                    Capsule()
                        .fill(Color.accentColor)
                        .frame(width: max(0, isDragging ? dragLocationX : CGFloat(homework.progress) * width), height: 8)
                        .animation(.interactiveSpring(response: 0.18, dampingFraction: 0.7), value: homework.progress)
                    
                    // Milestones
                    ForEach(homework.mileStones, id: \.id) { milestone in
                        let fraction = CGFloat(min(max(milestone.progress, 0), 1))
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
                        .position(x: thumbPosition, y: height / 2)
                        .opacity(isDragging ? 0.0 : 1.0)
                        .overlay {
                            if isDragging {
                                Capsule()
                                    .fill(Color.clear)
                                    .glassEffect(.clear)
                                    .frame(width: 30, height: 20)
                                    .transition(.opacity)
                                    .position(x: thumbPosition, y: height / 2)
                                    .animation(.easeInOut(duration: 0.1), value: isDragging)
                            }
                        }
                        .animation(.easeInOut(duration: 0.1), value: isDragging)
                        .gesture(
                            DragGesture(minimumDistance: 6)
                                .onChanged { value in
                                    // Axis lock: only react to horizontal drags so vertical scroll stays responsive
                                    if !dragAxisLocked {
                                        let dx = abs(value.translation.width)
                                        let dy = abs(value.translation.height)
                                        if dx > 6 || dy > 6 {
                                            dragAxisLocked = true
                                            isHorizontalDrag = dx > dy
                                        } else {
                                            return
                                        }
                                    }
                                    guard isHorizontalDrag else { return }

                                    // 切换到拖动状态（带动画）
                                    withAnimation {
                                        isDragging = true
                                    }
                                    let clamped = min(width, max(0, value.location.x))
                                    dragLocationX = clamped
                                    // Defer model updates until .onEnded to avoid frequent @Model change notifications
                                }
                                .onEnded { _ in
                                    withAnimation {
                                        isDragging = false
                                    }
                                    if isHorizontalDrag {
                                        homework.progress = Double(dragLocationX / width)
                                        try? modelContext.save()
                                    }
                                    // reset axis lock
                                    dragAxisLocked = false
                                    isHorizontalDrag = false
                                }
                        )
                    
                }.frame(height: 20)
            }
            .frame(height: 20)
        }
}


struct HomeworkItemDragBarView_Previews: PreviewProvider {
    static var previews: some View {
        let container = try! ModelContainer(
            for: Homework.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext
        let hw = Homework(
            name: "Math Assignment",
            dueDate: Date().addingTimeInterval(3600)
        )
        context.insert(hw)

        return HomeworkItemDragBarView(homework: hw)
            .padding()
            .previewLayout(.sizeThatFits)
            .modelContainer(container)
    }
}
