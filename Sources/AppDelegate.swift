import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {

    var statusBarController: StatusBarController!
    var browserWindowController: BrowserWindowController!
    var hotkeyManager: HotkeyManager!

    func applicationDidFinishLaunching(_ notification: Notification) {
        // 创建浏览器窗口
        browserWindowController = BrowserWindowController()
        browserWindowController.showWindow(nil)
        browserWindowController.fillScreen()

        // 创建状态栏
        statusBarController = StatusBarController(browserWindowController: browserWindowController)

        // 注册全局快捷键
        hotkeyManager = HotkeyManager(browserWindowController: browserWindowController)
        hotkeyManager.registerHotkeys()

        // LSUIElement + .accessory 确保 Dock 无图标、菜单栏有图标
    }

    // 点击 Dock 图标或重新激活 App 时恢复窗口
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            browserWindowController.showWindow(nil)
        }
        return true
    }

    func applicationWillTerminate(_ notification: Notification) {
        hotkeyManager.unregisterHotkeys()
    }
}
