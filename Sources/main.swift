import Cocoa

autoreleasepool {
    let app = NSApplication.shared
    // regular 保证窗口正常显示，LSUIElement 隐藏 Dock 图标
    app.setActivationPolicy(.regular)

    let delegate = AppDelegate()
    app.delegate = delegate

    app.run()
}
