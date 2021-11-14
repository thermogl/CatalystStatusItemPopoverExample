import Foundation

class MacBridgeBundleLoader: NSObject {
    
    private enum BridgeBundle {
        static let fileName = "MacBridge.bundle"
    }
    
    private var macBridge: MacBridge?
    
    required override init() {
        super.init()
        self.loadBundle()
    }
    
    private func loadBundle() {
        guard let bundleUrl = Bundle.main.builtInPlugInsURL?.appendingPathComponent(BridgeBundle.fileName) else { return }
        guard let bundle = Bundle(url: bundleUrl) else { return }
        guard let pluginClass = bundle.principalClass as? MacBridge.Type else { return }
        self.macBridge = pluginClass.init()
    }
}

extension MacBridgeBundleLoader: MacBridge {
    
    func createStatusItem(image: CGImage?, delegate: MacBridgeStatusItemDelegate?) {
        self.macBridge?.createStatusItem(image: image, delegate: delegate)
    }
    
    func getWindowProxy(forUIWindow window: NSObject) -> MacWindowProxy? {
        return self.macBridge?.getWindowProxy(forUIWindow: window)
    }
}
