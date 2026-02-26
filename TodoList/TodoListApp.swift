//
//  TodoListApp.swift
//  TodoList
//
//  Created by 王海龙 on 2026/2/26.
//

import SwiftUI

@main
struct TodoListApp: App {
    // 连接 AppDelegate
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView() // 不需要标准设置窗口
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 1. 创建 Popover (悬浮窗)
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 320, height: 360)
        popover.behavior = .transient // 点击外部自动关闭
        popover.contentViewController = NSHostingController(rootView: ContentView())
        self.popover = popover
        
        // 2. 创建状态栏图标
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            // 使用系统图标 (SF Symbols)
            button.image = NSImage(systemSymbolName: "checklist", accessibilityDescription: "Todo List")
            button.action = #selector(togglePopover)
        }
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        guard let button = statusItem?.button, let popover = popover else { return }
        
        if popover.isShown {
            popover.performClose(sender)
        } else {
            // 在图标位置弹出
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            // 弹出时让应用置顶，激活输入框焦点
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
