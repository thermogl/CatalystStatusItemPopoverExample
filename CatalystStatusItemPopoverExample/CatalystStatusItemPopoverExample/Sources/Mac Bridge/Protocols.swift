import Foundation

@objc(MacBridge)
protocol MacBridge: NSObjectProtocol {
    init()
    func createStatusItem(image: CGImage?, delegate: MacBridgeStatusItemDelegate?)
    func getWindowProxy(forUIWindow window: NSObject) -> MacWindowProxy?
}

@objc(MacBridgeStatusItemDelegate)
protocol MacBridgeStatusItemDelegate: NSObjectProtocol {
    func statusItemWasClicked()
}

@objc(MacWindowProxy)
protocol MacWindowProxy: NSObjectProtocol {
    func configure()
    func moveToStatusItem()
}
