//
//  TodoListApp.swift
//  TodoList
//
//  Created by 王海龙 on 2026/2/26.
//

import SwiftUI

@main
struct TodoListApp: App {
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

        // 2. 创建状态栏图标（squareLength 最小化占位，减少被系统截断的概率）
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem?.button {
            let image = NSImage(systemSymbolName: "checklist", accessibilityDescription: "Todo List")
            image?.isTemplate = true // 自动适配深色/浅色模式
            button.image = image
            button.action = #selector(handleClick)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }

    @objc func handleClick(_ sender: AnyObject?) {
        guard let event = NSApp.currentEvent else { return }
        if event.type == .rightMouseUp {
            showContextMenu()
        } else {
            togglePopover(sender)
        }
    }

    func togglePopover(_ sender: AnyObject?) {
        guard let button = statusItem?.button, let popover = popover else { return }

        if popover.isShown {
            popover.performClose(sender)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    // 右键菜单，提供退出选项
    func showContextMenu() {
        let menu = NSMenu()
        menu.addItem(
            withTitle: "退出",
            action: #selector(quitApp),
            keyEquivalent: "q"
        )
        statusItem?.menu = menu
        statusItem?.button?.performClick(nil)
        statusItem?.menu = nil // 显示后清除，保持左键单击行为
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
