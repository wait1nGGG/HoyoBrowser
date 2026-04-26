import Cocoa

class StatusBarController {

    private var statusItem: NSStatusItem!
    private weak var browserWindowController: BrowserWindowController?

    init(browserWindowController: BrowserWindowController) {
        self.browserWindowController = browserWindowController
        setupStatusBar()
    }

    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            // 使用 SF Symbol 图标（比 emoji 更可靠）
            if let globeImage = NSImage(systemSymbolName: "globe", accessibilityDescription: "HoyoBrowser") {
                globeImage.isTemplate = true
                button.image = globeImage
                button.imagePosition = .imageOnly
            } else {
                button.title = "MB"
                button.font = NSFont.boldSystemFont(ofSize: 13)
            }

            // 单击切换窗口显示/隐藏
            button.target = self
            button.action = #selector(statusBarClicked)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        // 构建菜单
        let menu = NSMenu()

        let toggleItem = NSMenuItem(
            title: "显示/隐藏浏览器",
            action: #selector(toggleBrowser),
            keyEquivalent: ""
        )
        toggleItem.target = self
        menu.addItem(toggleItem)

        let urlItem = NSMenuItem(
            title: "打开 URL...",
            action: #selector(promptURL),
            keyEquivalent: ""
        )
        urlItem.target = self
        menu.addItem(urlItem)

        menu.addItem(NSMenuItem.separator())

        let homeItem = NSMenuItem(
            title: "回到首页 (bilibili.com)",
            action: #selector(goHome),
            keyEquivalent: ""
        )
        homeItem.target = self
        menu.addItem(homeItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(
            title: "退出",
            action: #selector(quitApp),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    @objc private func statusBarClicked() {
        guard let event = NSApp.currentEvent else { return }
        if event.type == .rightMouseUp {
            return
        }
        browserWindowController?.toggleVisibility()
    }

    @objc private func toggleBrowser() {
        browserWindowController?.toggleVisibility()
    }

    @objc private func promptURL() {
        let alert = NSAlert()
        alert.messageText = "打开网页"
        alert.informativeText = "请输入网址（包含 https://）："
        alert.alertStyle = .informational

        let textField = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 24))
        textField.placeholderString = "https://www.bilibili.com"
        alert.accessoryView = textField
        alert.addButton(withTitle: "打开")
        alert.addButton(withTitle: "取消")

        alert.window.initialFirstResponder = textField

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            let urlString = textField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            if !urlString.isEmpty {
                browserWindowController?.showWindow(nil)
                browserWindowController?.webViewController?.loadURL(urlString)
            }
        }
    }

    @objc private func goHome() {
        browserWindowController?.showWindow(nil)
        browserWindowController?.webViewController?.loadURL("https://www.bilibili.com")
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}
