//
//  TodoViewModel.swift
//  TodoList
//
//  Created by 王海龙 on 2026/2/26.
//

import Foundation
import Combine

private let storageKey = "savedTodos"

final class TodoViewModel: ObservableObject {
    @Published var todos: [TodoItem] = []
    @Published var showHistory: Bool = false

    // 过滤后的任务列表：历史模式显示已完成，普通模式显示未完成
    var filteredTodos: [TodoItem] {
        todos.filter { showHistory ? $0.isCompleted : !$0.isCompleted }
    }

    // 历史记录按完成日期分组，最近的日期排在最前
    var groupedHistory: [HistoryGroup] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: todos.filter { $0.isCompleted }) { item -> Date in
            let date = item.completedAt ?? item.createdAt
            return calendar.startOfDay(for: date)
        }
        return grouped
            .sorted { $0.key > $1.key }
            .map { date, items in
                HistoryGroup(
                    day: date,
                    label: Self.dayLabel(for: date, calendar: calendar),
                    items: items.sorted { ($0.completedAt ?? .distantPast) > ($1.completedAt ?? .distantPast) }
                )
            }
    }

    private static func dayLabel(for date: Date, calendar: Calendar) -> String {
        if calendar.isDateInToday(date) { return "今天" }
        if calendar.isDateInYesterday(date) { return "昨天" }
        let formatter = DateFormatter()
        formatter.dateFormat = "M 月 d 日"
        return formatter.string(from: date)
    }

    init() {
        load()
    }

    // MARK: - Actions

    func addTask(title: String) {
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let item = TodoItem(title: trimmed)
        todos.insert(item, at: 0)
        save()
    }

    func toggleTask(_ item: TodoItem) {
        guard let index = todos.firstIndex(where: { $0.id == item.id }) else { return }
        todos[index].isCompleted.toggle()
        todos[index].completedAt = todos[index].isCompleted ? Date() : nil
        save()
    }

    func deleteTask(_ item: TodoItem) {
        todos.removeAll { $0.id == item.id }
        save()
    }

    // MARK: - Persistence

    private func save() {
        do {
            let data = try JSONEncoder().encode(todos)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("[TodoViewModel] 保存失败: \(error)")
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        do {
            todos = try JSONDecoder().decode([TodoItem].self, from: data)
        } catch {
            print("[TodoViewModel] 读取失败: \(error)")
        }
    }
}
