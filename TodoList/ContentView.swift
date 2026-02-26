import SwiftUI

struct ContentView: View {
    // 使用 AppStorage 自动持久化到 UserDefaults
    @AppStorage("savedTodos") private var todosData: Data = Data()
    @State private var todos: [TodoItem] = []
    @State private var newTask: String = ""
    @State private var showHistory: Bool = false // 切换历史模式
    
    var body: some View {
        VStack(spacing: 0) {
            // --- 顶部输入栏 ---
            HStack {
                TextField("Add a task...", text: $newTask)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 14))
                    .onSubmit { addTask() }
                
                // 1. 切换历史记录按钮
                Button(action: { showHistory.toggle() }) {
                    Image(systemName: showHistory ? "clock.fill" : "clock")
                        .foregroundColor(showHistory ? .blue : .gray)
                }
                .buttonStyle(PlainButtonStyle())
                .help("查看历史记录") // 鼠标悬停提示
                
                // 2. [新增] 退出 App 按钮
                Button(action: {
                    NSApplication.shared.terminate(nil) // 彻底退出程序
                }) {
                    Image(systemName: "power")
                        .foregroundColor(.red.opacity(0.8))
                }
                .buttonStyle(PlainButtonStyle())
                .help("退出应用")
                .padding(.leading, 8)
            }
            .padding(12)
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // --- 任务列表 ---
            ScrollView {
                // 过滤显示：如果是在历史模式，显示已完成；否则显示未完成
                let filteredTodos = todos.filter { showHistory ? $0.isCompleted : !$0.isCompleted }
                
                if filteredTodos.isEmpty {
                    Text(showHistory ? "No history" : "No active tasks")
                        .foregroundColor(.gray)
                        .padding(.top, 20)
                } else {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(filteredTodos) { item in
                            HStack {
                                // 点击圆圈完成/恢复任务
                                Button(action: { toggleTask(item) }) {
                                    Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(item.isCompleted ? .gray : .primary)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Text(item.title)
                                    .strikethrough(item.isCompleted, color: .gray)
                                    .foregroundColor(item.isCompleted ? .gray : .primary)
                                
                                Spacer()
                                
                                // 删除按钮
                                Button(action: { deleteTask(item) }) {
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
                    .padding(.vertical, 8)
                }
            }
            .frame(height: 300) // 限制高度
        }
        .frame(width: 320) // 固定宽度
        .onAppear(perform: loadData)
    }
    
    // --- 逻辑处理 ---
    
    func addTask() {
        guard !newTask.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let item = TodoItem(title: newTask)
        todos.insert(item, at: 0)
        newTask = ""
        saveData()
    }
    
    func toggleTask(_ item: TodoItem) {
        if let index = todos.firstIndex(where: { $0.id == item.id }) {
            todos[index].isCompleted.toggle()
            saveData()
        }
    }
    
    func deleteTask(_ item: TodoItem) {
        todos.removeAll { $0.id == item.id }
        saveData()
    }
    
    func saveData() {
        if let data = try? JSONEncoder().encode(todos) {
            todosData = data
        }
    }
    
    func loadData() {
        if let decoded = try? JSONDecoder().decode([TodoItem].self, from: todosData) {
            todos = decoded
        }
    }
}
