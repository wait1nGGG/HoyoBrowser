import Cocoa
import Carbon

class HotkeyManager {

    private weak var browserWindowController: BrowserWindowController?
    private var eventHandlerRef: EventHandlerRef?
    private var hotkeyRefs: [EventHotKeyRef?] = []

    // 快捷键定义: (id, keyCode, modifiers)
    private let hotkeyDefs: [(Int, Int, UInt32)] = [
        (1, 35,  UInt32(cmdKey | shiftKey)),  // Cmd+Shift+P -> 播放/暂停
        (2, 124, UInt32(cmdKey | shiftKey)),  // Cmd+Shift+Right -> 快进
        (3, 123, UInt32(cmdKey | shiftKey)),  // Cmd+Shift+Left -> 快退
        (4, 4,   UInt32(cmdKey | shiftKey)),  // Cmd+Shift+H -> 隐藏/显示
        (5, 31,  UInt32(cmdKey | shiftKey)),  // Cmd+Shift+O -> 聚焦地址栏
    ]

    init(browserWindowController: BrowserWindowController) {
        self.browserWindowController = browserWindowController
    }

    func registerHotkeys() {
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: OSType(kEventHotKeyPressed))

        let selfPtr = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())

        let status = InstallEventHandler(
            GetApplicationEventTarget(),
            { (_, event, userData) -> OSStatus in
                guard let userData = userData, let event = event else { return OSStatus(eventNotHandledErr) }
                let manager = Unmanaged<HotkeyManager>.fromOpaque(userData).takeUnretainedValue()
                return manager.handleHotkeyEvent(event)
            },
            1,
            &eventType,
            selfPtr,
            &eventHandlerRef
        )

        guard status == noErr else {
            print("HotkeyManager: InstallEventHandler failed with \(status)")
            return
        }

        for (id, keyCode, modifiers) in hotkeyDefs {
            var hotkeyRef: EventHotKeyRef?
            var hotkeyID = EventHotKeyID()
            hotkeyID.signature = OSType(0x4D494E49) // "MINI"
            hotkeyID.id = UInt32(id)

            let regStatus = RegisterEventHotKey(
                UInt32(keyCode),
                modifiers,
                hotkeyID,
                GetApplicationEventTarget(),
                0,
                &hotkeyRef
            )

            if regStatus == noErr, let ref = hotkeyRef {
                hotkeyRefs.append(ref)
                print("HotkeyManager: registered hotkey id=\(id)")
            } else {
                hotkeyRefs.append(nil)
                print("HotkeyManager: failed to register hotkey id=\(id), status=\(regStatus)")
            }
        }
    }

    func unregisterHotkeys() {
        for ref in hotkeyRefs {
            if let ref = ref {
                UnregisterEventHotKey(ref)
            }
        }
        hotkeyRefs.removeAll()

        if let handler = eventHandlerRef {
            RemoveEventHandler(handler)
            eventHandlerRef = nil
        }
    }

    private func handleHotkeyEvent(_ event: EventRef) -> OSStatus {
        var hotkeyID = EventHotKeyID()
        let status = GetEventParameter(
            event,
            EventParamName(kEventParamDirectObject),
            EventParamType(typeEventHotKeyID),
            nil,
            MemoryLayout<EventHotKeyID>.size,
            nil,
            &hotkeyID
        )

        guard status == noErr else { return OSStatus(eventNotHandledErr) }

        DispatchQueue.main.async { [weak self] in
            self?.dispatchHotkey(Int(hotkeyID.id))
        }

        return noErr
    }

    private func dispatchHotkey(_ id: Int) {
        guard let wc = browserWindowController else { return }
        guard let webVC = wc.webViewController else { return }

        switch id {
        case 1: // Cmd+Shift+P - 播放/暂停
            webVC.togglePlayPause()
        case 2: // Cmd+Shift+Right - 快进 5s
            webVC.seekForward(by: 5)
        case 3: // Cmd+Shift+Left - 快退 5s
            webVC.seekBackward(by: 5)
        case 4: // Cmd+Shift+H - 隐藏/显示
            wc.toggleVisibility()
        case 5: // Cmd+Shift+O - 聚焦地址栏
            wc.showWindow(nil)
            NSApp.activate(ignoringOtherApps: true)
            webVC.focusAddressBar()
        default:
            break
        }
    }
}
