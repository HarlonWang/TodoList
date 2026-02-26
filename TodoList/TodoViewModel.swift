//
//  TodoViewModel.swift
//  TodoList
//
//  Created by 王海龙 on 2026/2/26.
//

import Foundation

private let storageKey = "savedTodos"

final class TodoViewModel: ObservableObject {
    @Published var todos: [TodoItem] = []
    @Published var showHistory: Bool = false

    // 过滤后的任务列表：历史模式显示已完成，普通模式显示未完成
    var filteredTodos: [TodoItem] {
        todos.filter { showHistory ? $0.isCompleted : !$0.isCompleted }
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
