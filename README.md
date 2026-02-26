# TodoList

一款 macOS 菜单栏 Todo App，基于 SwiftUI + MVVM 架构构建，轻量、无干扰，随时从状态栏快速记录任务。

## 功能特性

- **菜单栏常驻**：点击状态栏图标弹出任务面板，点击外部自动收起
- **快速添加**：在输入框输入任务后按回车即可添加
- **完成/恢复**：点击圆圈图标标记任务完成，在历史记录中可一键恢复
- **历史记录**：查看已完成任务，按完成日期分组展示（今天 / 昨天 / 具体日期）
- **数据持久化**：任务数据自动保存到本地，重启后不丢失
- **右键退出**：右键点击菜单栏图标，通过菜单退出应用

## 技术架构

```
TodoList/
├── TodoListApp.swift     # App 入口，菜单栏图标与 Popover 管理
├── Task.swift            # 数据模型（TodoItem、HistoryGroup）
├── TodoViewModel.swift   # ViewModel，业务逻辑与持久化
└── ContentView.swift     # UI 层（ContentView、HistoryListView、TaskRow）
```

### 技术栈

- **SwiftUI** — 声明式 UI 框架
- **MVVM** — 架构模式，View 只负责渲染，逻辑集中在 ViewModel
- **Combine** — 驱动 `@Published` 属性的响应式更新
- **UserDefaults + JSONEncoder** — 轻量级本地持久化

## 系统要求

- macOS 12.0+
- Xcode 14.0+

## 运行方式

1. 克隆仓库

   ```bash
   git clone https://github.com/HarlonWang/TodoList.git
   cd TodoList
   ```

2. 用 Xcode 打开项目

   ```bash
   open TodoList.xcodeproj
   ```

3. 选择 `My Mac` 作为运行目标，点击运行（`⌘R`）

## License

MIT
