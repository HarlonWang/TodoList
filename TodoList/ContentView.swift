import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TodoViewModel()
    @State private var newTask: String = ""

    var body: some View {
        VStack(spacing: 0) {
            // --- 顶部输入栏 ---
            HStack {
                TextField("Add a task...", text: $newTask)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 14))
                    .onSubmit {
                        viewModel.addTask(title: newTask)
                        newTask = ""
                    }

                // 切换历史记录按钮
                Button(action: { viewModel.showHistory.toggle() }) {
                    Image(systemName: viewModel.showHistory ? "clock.fill" : "clock")
                        .foregroundColor(viewModel.showHistory ? .blue : .gray)
                }
                .buttonStyle(PlainButtonStyle())
                .help(viewModel.showHistory ? "返回待办列表" : "查看历史记录")
            }
            .padding(12)
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

            // --- 任务列表 ---
            ScrollView {
                if viewModel.showHistory {
                    HistoryListView(viewModel: viewModel)
                } else if viewModel.filteredTodos.isEmpty {
                    Text("No active tasks")
                        .foregroundColor(.gray)
                        .padding(.top, 20)
                } else {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(viewModel.filteredTodos) { item in
                            TaskRow(item: item, viewModel: viewModel)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .frame(maxHeight: 300)
        }
        .frame(width: 320)
    }
}

// MARK: - HistoryListView

private struct HistoryListView: View {
    @ObservedObject var viewModel: TodoViewModel

    var body: some View {
        if viewModel.groupedHistory.isEmpty {
            Text("No history")
                .foregroundColor(.gray)
                .padding(.top, 20)
        } else {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(viewModel.groupedHistory) { group in
                    // 日期分组标题
                    Text(group.label)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.top, 12)
                        .padding(.bottom, 4)

                    ForEach(group.items) { item in
                        TaskRow(item: item, viewModel: viewModel)
                    }
                }
            }
            .padding(.bottom, 8)
        }
    }
}

// MARK: - TaskRow

private struct TaskRow: View {
    let item: TodoItem
    @ObservedObject var viewModel: TodoViewModel

    var body: some View {
        HStack {
            // 点击圆圈完成/恢复任务
            Button(action: { viewModel.toggleTask(item) }) {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.isCompleted ? .gray : .primary)
            }
            .buttonStyle(PlainButtonStyle())

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .strikethrough(item.isCompleted, color: .gray)
                    .foregroundColor(item.isCompleted ? .gray : .primary)

                // 已完成时显示完成时间
                if let completedAt = item.completedAt {
                    Text("完成于 \(completedAt.formatted(date: .omitted, time: .shortened))")
                        .font(.caption2)
                        .foregroundColor(.gray.opacity(0.7))
                }
            }

            Spacer()

            // 删除按钮
            Button(action: { viewModel.deleteTask(item) }) {
                Image(systemName: "xmark")
                    .font(.caption)
                    .foregroundColor(.gray.opacity(0.5))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
    }
}
