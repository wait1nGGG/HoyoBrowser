import Cocoa
import WebKit

class WebViewController: NSViewController {

    weak var browserWindowController: BrowserWindowController?

    private var webView: WKWebView!
    private var urlTextField: NSTextField!
    private var backButton: NSButton!
    private var forwardButton: NSButton!
    private var goButton: NSButton!
    private var pinButton: NSButton!
    private var toolbar: NSView!

    // 默认首页
    private let defaultURL = "https://www.bilibili.com"

    override func loadView() {
        self.view = NSView(frame: NSRect(x: 0, y: 0, width: 640, height: 420))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupToolbar()
        setupWebView()
        loadURL(defaultURL)
    }

    // MARK: - 工具栏

    private func setupToolbar() {
        let toolbarHeight: CGFloat = 36
        toolbar = NSView(frame: NSRect(x: 0, y: view.bounds.height - toolbarHeight, width: view.bounds.width, height: toolbarHeight))
        toolbar.autoresizingMask = [.width, .minYMargin]
        toolbar.wantsLayer = true
        toolbar.layer?.backgroundColor = NSColor.controlBackgroundColor.withAlphaComponent(0.95).cgColor

        // 后退按钮
        backButton = NSButton(
            image: NSImage(systemSymbolName: "chevron.left", accessibilityDescription: "后退")!,
            target: self,
            action: #selector(goBack)
        )
        backButton.isBordered = false
        backButton.frame = NSRect(x: 8, y: 6, width: 24, height: 24)
        toolbar.addSubview(backButton)

        // 前进按钮
        forwardButton = NSButton(
            image: NSImage(systemSymbolName: "chevron.right", accessibilityDescription: "前进")!,
            target: self,
            action: #selector(goForward)
        )
        forwardButton.isBordered = false
        forwardButton.frame = NSRect(x: 36, y: 6, width: 24, height: 24)
        toolbar.addSubview(forwardButton)

        // 置顶按钮 — 图钉
        pinButton = NSButton(
            image: NSImage(systemSymbolName: "pin", accessibilityDescription: "置顶")!,
            target: self,
            action: #selector(togglePin)
        )
        pinButton.isBordered = false
        pinButton.toolTip = "固定窗口于顶层"
        pinButton.frame = NSRect(x: 64, y: 6, width: 24, height: 24)
        toolbar.addSubview(pinButton)

        // 地址栏
        let urlX: CGFloat = 96
        let goWidth: CGFloat = 40
        let urlWidth = view.bounds.width - urlX - goWidth - 12

        urlTextField = NSTextField(frame: NSRect(x: urlX, y: 7, width: urlWidth, height: 22))
        urlTextField.placeholderString = "输入网址..."
        urlTextField.target = self
        urlTextField.action = #selector(loadFromAddressBar)
        urlTextField.autoresizingMask = .width
        urlTextField.cell?.usesSingleLineMode = true
        urlTextField.cell?.lineBreakMode = .byTruncatingHead
        toolbar.addSubview(urlTextField)

        // 前往按钮
        goButton = NSButton(title: "Go", target: self, action: #selector(loadFromAddressBar))
        goButton.isBordered = true
        goButton.bezelStyle = .rounded
        goButton.frame = NSRect(x: view.bounds.width - goWidth - 8, y: 4, width: goWidth, height: 24)
        goButton.autoresizingMask = .minXMargin
        toolbar.addSubview(goButton)

        view.addSubview(toolbar)
    }

    func updatePinButtonState(_ pinned: Bool) {
        let symbolName = pinned ? "pin.fill" : "pin"
        pinButton.image = NSImage(systemSymbolName: symbolName, accessibilityDescription: pinned ? "取消置顶" : "置顶")
        pinButton.toolTip = pinned ? "取消固定" : "固定窗口于顶层"
        pinButton.contentTintColor = pinned ? NSColor.systemBlue : nil
    }

    @objc private func togglePin() {
        browserWindowController?.togglePin()
    }

    // MARK: - WebView

    private func setupWebView() {
        let config = WKWebViewConfiguration()

        // 使用持久化数据存储，Cookie 自动保存在磁盘
        config.websiteDataStore = .default()

        // 允许内联媒体播放
        config.preferences.setValue(true, forKey: "fullScreenEnabled")
        config.mediaTypesRequiringUserActionForPlayback = []

        let toolbarHeight: CGFloat = 36
        let webFrame = NSRect(
            x: 0, y: 0,
            width: view.bounds.width,
            height: view.bounds.height - toolbarHeight
        )

        webView = WKWebView(frame: webFrame, configuration: config)
        webView.autoresizingMask = [.width, .height]
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true

        // 伪装成 Chrome 避免"浏览器版本过低"提示
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"

        view.addSubview(webView)
    }

    // MARK: - 导航操作

    @objc private func goBack() {
        if webView.canGoBack {
            webView.goBack()
        }
    }

    @objc private func goForward() {
        if webView.canGoForward {
            webView.goForward()
        }
    }

    @objc private func loadFromAddressBar() {
        let text = urlTextField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        loadURL(text)
    }

    func loadURL(_ urlString: String) {
        var finalURL = urlString
        if !finalURL.lowercased().hasPrefix("http://") && !finalURL.lowercased().hasPrefix("https://") {
            finalURL = "https://" + finalURL
        }

        guard let url = URL(string: finalURL) else { return }

        urlTextField.stringValue = finalURL
        let request = URLRequest(url: url)
        webView.load(request)
    }

    func focusAddressBar() {
        view.window?.makeFirstResponder(urlTextField)
        urlTextField.selectText(nil)
    }

    // MARK: - 视频控制（JavaScript 注入）

    func togglePlayPause() {
        let js = """
        (function() {
            var videos = document.querySelectorAll('video');
            if (videos.length === 0) return 'no_video';
            var v = videos[0];
            if (v.paused) { v.play(); return 'play'; }
            else { v.pause(); return 'pause'; }
        })();
        """

        webView.evaluateJavaScript(js) { result, error in
            if let error = error {
                print("togglePlayPause error: \(error.localizedDescription)")
            } else if let state = result as? String {
                print("Video: \(state)")
            }
        }
    }

    func seekForward(by seconds: Int) {
        let js = """
        (function() {
            var videos = document.querySelectorAll('video');
            if (videos.length === 0) return;
            var v = videos[0];
            v.currentTime = Math.min(v.currentTime + \(seconds), v.duration);
            return v.currentTime;
        })();
        """

        webView.evaluateJavaScript(js) { result, error in
            if let error = error {
                print("seekForward error: \(error.localizedDescription)")
            }
        }
    }

    func seekBackward(by seconds: Int) {
        let js = """
        (function() {
            var videos = document.querySelectorAll('video');
            if (videos.length === 0) return;
            var v = videos[0];
            v.currentTime = Math.max(v.currentTime - \(seconds), 0);
            return v.currentTime;
        })();
        """

        webView.evaluateJavaScript(js) { result, error in
            if let error = error {
                print("seekBackward error: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - WKNavigationDelegate

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let url = webView.url?.absoluteString {
            urlTextField.stringValue = url
        }
        updateNavigationButtons()
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        if let url = webView.url?.absoluteString {
            urlTextField.stringValue = url
        }
    }

    private func updateNavigationButtons() {
        backButton.isEnabled = webView.canGoBack
        forwardButton.isEnabled = webView.canGoForward
    }
}

// MARK: - WKUIDelegate

extension WebViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.request.url != nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
}
