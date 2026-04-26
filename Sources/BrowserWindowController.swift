import Cocoa

class BrowserWindowController: NSWindowController {

    var webViewController: WebViewController!
    var isPinned = false

    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 640, height: 420),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )

        self.init(window: window)
        window.delegate = self

        // 默认不置顶
        window.level = .normal

        // 在所有空间中显示
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        // 最小尺寸
        window.minSize = NSSize(width: 360, height: 280)

        window.title = "HoyoBrowser"

        // 关闭时隐藏而非销毁
        window.isReleasedWhenClosed = false

        // 设置 WebViewController
        webViewController = WebViewController()
        webViewController.browserWindowController = self
        window.contentViewController = webViewController
    }

    /// 将窗口调整为铺满屏幕
    func fillScreen() {
        guard let window = window,
              let screen = window.screen ?? NSScreen.main else { return }
        window.setFrame(screen.visibleFrame, display: true)
    }

    /// 切换置顶状态
    func togglePin() {
        guard let window = window else { return }
        isPinned.toggle()
        window.level = isPinned ? .popUpMenu : .normal
        webViewController.updatePinButtonState(isPinned)
    }

    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func toggleVisibility() {
        guard let window = window else { return }

        if window.isVisible {
            window.orderOut(nil)
        } else {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}

extension BrowserWindowController: NSWindowDelegate {
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        sender.orderOut(nil)
        return false
    }
}
