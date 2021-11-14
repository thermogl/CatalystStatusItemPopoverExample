import AppKit

class DefaultMacBridge: NSObject {
    
    private lazy var statusItemCoordinator = StatusItemCoordinator()
    private lazy var windowCoordinator = WindowCoordinator(statusItem: self.statusItemCoordinator.statusItem)
    
    required override init() {
        super.init()
    }
}

extension DefaultMacBridge: MacBridge {
    
    func createStatusItem(image: CGImage?, delegate: MacBridgeStatusItemDelegate?) {
        self.statusItemCoordinator.delegate = delegate
        self.statusItemCoordinator.createStatusItem(image: image)
    }
    
    func getWindowProxy(forUIWindow window: NSObject) -> MacWindowProxy? {
        return self.windowCoordinator.getWindowProxy(forUIWindow: window)
    }
}

private class StatusItemCoordinator {
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    fileprivate weak var delegate: MacBridgeStatusItemDelegate?
    fileprivate func createStatusItem(image: CGImage?) {
        
        guard let button = self.statusItem.button else { return }
        if let image = image {
            let nsImage = NSImage(cgImage: image, size: NSSize(width: 17, height: 17))
            nsImage.isTemplate = true
            button.image = nsImage
        } else {
            button.title = "Example"
        }
        button.target = self
        button.action = #selector(statusItemWasClicked)
    }
    
    @objc private func statusItemWasClicked() {
        self.delegate?.statusItemWasClicked()
    }
}

extension NSStatusItem {
    func getFrame() -> CGRect? {
        return self.button?.window?.frame
    }
}

private class WindowCoordinator {
    
    private let statusItem: NSStatusItem
    init(statusItem: NSStatusItem) {
        self.statusItem = statusItem
    }
    
    private class WindowProxy: NSObject, MacWindowProxy {
        private let window: NSWindow
        private let statusItem: NSStatusItem
        init(window: NSWindow, statusItem: NSStatusItem) {
            self.window = window
            self.statusItem = statusItem
        }
        
        func configure() {
            self.window.standardWindowButton(.closeButton)?.isHidden = true
            self.window.standardWindowButton(.miniaturizeButton)?.isHidden = true
            self.window.standardWindowButton(.zoomButton)?.isHidden = true
            self.window.alphaValue = 0.0
        }
        
        func show() {
            self.window.makeKeyAndOrderFront(self)
            NSApp.activate(ignoringOtherApps: true)
        }
        
        func moveToStatusItem() {
            guard let frame = self.statusItem.getFrame() else { return }
            var nsFrame = NSRectFromCGRect(frame)
            nsFrame.origin.y += 100
            nsFrame.origin.x += nsFrame.width / 2
            self.window.setFrame(nsFrame, display: false)
            self.show()
        }
    }
    
    fileprivate func getWindowProxy(forUIWindow window: NSObject) -> MacWindowProxy? {
        guard let window = self.getWindow(for: window) else { return nil }
        return WindowProxy(window: window, statusItem: self.statusItem)
    }
    
    // Warning: Private API usage. Will need obfuscation if submitting to App Store.
    private func getWindow(for uiWindow: NSObject) -> NSWindow? {
        let delegate = NSApplication.shared.delegate
        let selector = NSSelectorFromString("_hostWindowForUIWindow:")
        guard let window = delegate?.perform(selector, with: uiWindow).takeUnretainedValue() as? NSObject else {
            return nil
        }
        let attachedWindowSelector = NSSelectorFromString("attachedWindow")
        if window.responds(to: attachedWindowSelector) {
            return window.value(forKey: NSStringFromSelector(attachedWindowSelector)) as? NSWindow
        }
        return window as? NSWindow
    }
}

