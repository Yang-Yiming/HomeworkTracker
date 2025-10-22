//
//  HomeworkListView.swift
//  HomeworkTracker
//
//  Created by 杨一鸣 on 2025/10/16.
//

import SwiftUI
import SwiftData

struct HomeworkListView: View {
    var homeworkList: [Homework]
    @Binding var selectedHomework: Homework?
    @Environment(\.modelContext) private var modelContext
    
    // Search and Filter State
    @State private var searchText: String = ""
    @State private var selectedStatus: FilterStatus = .all
    @State private var sortOption: SortOption = .dueDate
    @State private var sortAscending: Bool = true
    
    // Filtered and sorted list
    private var filteredAndSortedHomework: [Homework] {
        var result = homeworkList
        
        // Search filter
        if !searchText.isEmpty {
            result = result.filter { hw in
                hw.name.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Status filter
        result = result.filter { hw in
            switch selectedStatus {
            case .all:
                return true
            case .notStarted:
                return hw.progress == 0
            case .inProgress:
                return hw.progress > 0 && hw.progress < 1
            case .completed:
                return hw.progress >= 1
            case .overdue:
                return hw.dueDate < Date() && hw.progress < 1
            }
        }
        
        // Sort
        result.sort { hw1, hw2 in
            let shouldSwap: Bool
            switch sortOption {
            case .dueDate:
                shouldSwap = hw1.dueDate < hw2.dueDate
            case .urgency:
                shouldSwap = hw1.urgent_level > hw2.urgent_level
            case .progress:
                shouldSwap = hw1.progress < hw2.progress
            case .name:
                shouldSwap = hw1.name.localizedCaseInsensitiveCompare(hw2.name) == .orderedAscending
            }
            return sortAscending ? shouldSwap : !shouldSwap
        }
        
        return result
    }
    
    // Use explicit IDs for better performance and stability
    private var homeworkIDs: Set<UUID> {
        Set(filteredAndSortedHomework.map { $0.id })
    }
    
    var body: some View {
        VStack(spacing: 0) {
                // Search Bar
                SearchBar(text: $searchText)
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                
                // Filter and Sort Controls
                VStack(spacing: 12) {
                    HStack(spacing: 8) {
                        // Status Filter
                        Menu {
                            ForEach(FilterStatus.allCases, id: \.self) { status in
                                Button(action: { selectedStatus = status }) {
                                    HStack {
                                        Text(status.label)
                                        if status == selectedStatus {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "line.3.horizontal.decrease.circle")
                                Text("Filter")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(.ultraThinMaterial))
                            .foregroundStyle(.primary)
                        }
                        
                        // Sort Option
                        Menu {
                            ForEach(SortOption.allCases, id: \.self) { option in
                                Button(action: { sortOption = option }) {
                                    HStack {
                                        Text(option.label)
                                        if option == sortOption {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                            Divider()
                            Button(action: { sortAscending.toggle() }) {
                                HStack {
                                    Image(systemName: sortAscending ? "arrow.up" : "arrow.down")
                                    Text(sortAscending ? "Ascending" : "Descending")
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: sortAscending ? "arrow.up" : "arrow.down")
                                Text("Sort")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            //.background(Capsule().fill(.ultraThinMaterial))
                            .foregroundStyle(.primary)
                        }

                        Button(action: addHomework) {
                            HStack(spacing: 4) {
                                Image(systemName: "plus")
                                Text("Add Homework")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5.5)
                            .background(Capsule().fill(.gray.opacity(0.2)))
                            .foregroundStyle(.primary)
                        }.buttonStyle(.plain)
                        
                        Spacer()
                        
                        // Results count
                        Text("\(filteredAndSortedHomework.count)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                    
                    // Active filters display
                    if selectedStatus != .all || !searchText.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                if !searchText.isEmpty {
                                    FilterTag(
                                        icon: "magnifyingglass",
                                        text: searchText,
                                        onRemove: { searchText = "" }
                                    )
                                }
                                if selectedStatus != .all {
                                    FilterTag(
                                        icon: "line.3.horizontal.decrease.circle",
                                        text: selectedStatus.label,
                                        onRemove: { selectedStatus = .all }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
                
                // Homework List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        if filteredAndSortedHomework.isEmpty {
                            EmptyStateView(
                                searchText: searchText,
                                hasFilters: selectedStatus != .all
                            )
                            .frame(maxHeight: .infinity)
                        } else {
                            ForEach(filteredAndSortedHomework, id: \.id) { homework in
                                HomeworkItemView(homework: homework)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedHomework = homework
                                    }
                            }
                        }
                    }
                    .padding()
                }
            }
    }
}

private extension HomeworkListView {
    func addHomework() {
        let newHomework = Homework(name: "New Homework", dueDate: Date())
        modelContext.insert(newHomework)
        selectedHomework = newHomework
        try? modelContext.save()
    }
}

// MARK: - Filter Status
enum FilterStatus: CaseIterable {
    case all
    case notStarted
    case inProgress
    case completed
    case overdue
    
    var label: String {
        switch self {
        case .all:
            return "All"
        case .notStarted:
            return "Not Started"
        case .inProgress:
            return "In Progress"
        case .completed:
            return "Completed"
        case .overdue:
            return "Overdue"
        }
    }
}

// MARK: - Sort Option
enum SortOption: CaseIterable {
    case dueDate
    case urgency
    case progress
    case name
    
    var label: String {
        switch self {
        case .dueDate:
            return "Due Date"
        case .urgency:
            return "Urgency"
        case .progress:
            return "Progress"
        case .name:
            return "Name"
        }
    }
}

// MARK: - Search Bar
private struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            
            TextField("Search homework...", text: $text)
                .textFieldStyle(.roundedBorder)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Filter Tag
private struct FilterTag: View {
    var icon: String
    var text: String
    var onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .imageScale(.small)
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .imageScale(.small)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Capsule().fill(.blue.opacity(0.12)))
        .foregroundStyle(.blue)
    }
}

// MARK: - Empty State View
private struct EmptyStateView: View {
    var searchText: String
    var hasFilters: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
            
            Text(emptyStateTitle)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(emptyStateMessage)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
    
    private var emptyStateTitle: String {
        if !searchText.isEmpty {
            return "No Results Found"
        } else if hasFilters {
            return "No Homework Items"
        } else {
            return "No Homework Yet"
        }
    }
    
    private var emptyStateMessage: String {
        if !searchText.isEmpty {
            return "Try adjusting your search or filters"
        } else if hasFilters {
            return "Try changing your filters to see more items"
        } else {
            return "Add homework to get started"
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Homework.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let context = container.mainContext
    let homeworkSamples: [Homework] = [
        Homework(name: "Math Assignment", dueDate: Date().addingTimeInterval(86400 * 2)),
        Homework(name: "Physics Lab Report", dueDate: Date().addingTimeInterval(86400 * 1)),
        Homework(name: "English Essay", dueDate: Date().addingTimeInterval(86400 * 5)),
        Homework(name: "History Project", dueDate: Date().addingTimeInterval(-86400 * 1)),
        Homework(name: "Chemistry Quiz Prep", dueDate: Date().addingTimeInterval(86400 * 3))
    ]
    homeworkSamples.forEach { context.insert($0) }
    
    struct ListPreview: View {
        @State var selection: Homework?
        let container: ModelContainer
        let items: [Homework]
        
        var body: some View {
            HomeworkListView(homeworkList: items, selectedHomework: $selection)
                .modelContainer(container)
        }
    }
    
    return ListPreview(selection: homeworkSamples.first, container: container, items: homeworkSamples)
}
