//
//  Task.swift
//  TodoList
//
//  Created by 王海龙 on 2026/2/26.
//

import Foundation

struct TodoItem: Identifiable, Codable {
    var id = UUID()
    var title: String
    var isCompleted: Bool = false
    var createdAt: Date = Date()
    var completedAt: Date? = nil
}
