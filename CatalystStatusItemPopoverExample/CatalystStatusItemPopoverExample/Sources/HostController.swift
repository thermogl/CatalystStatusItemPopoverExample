import UIKit

class HostController: UIViewController {
    
    private let macBridge = MacBridgeBundleLoader()
    
    private let statusItemImage: UIImage?
    private let contentViewController: UIViewController
    init(statusItemImage: UIImage?, contentViewController: UIViewController) {
        self.statusItemImage = statusItemImage
        self.contentViewController = contentViewController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.macBridge.createStatusItem(image: self.statusItemImage?.cgImage, delegate: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.prepareForAppearance()
        self.forceContentViewLayout()
    }
    
    private var windowProxy: MacWindowProxy?
    private func prepareForAppearance() {
        guard let window = self.view.window else { return }
        self.windowProxy = self.macBridge.getWindowProxy(forUIWindow: window)
        self.windowProxy?.configure()
    }
    
    private func forceContentViewLayout() {
        self.view.addSubview(self.contentViewController.view)
        self.contentViewController.view.frame = CGRect(x: 0, y: 0, width: 1000, height: 1000)
        self.view.layoutIfNeeded()
        self.contentViewController.view.removeFromSuperview()
    }
    
    private func toggleVisible() {
        self.windowProxy?.moveToStatusItem()
        
        let viewController = self.contentViewController
        
        if viewController.presentingViewController != nil {
            viewController.dismiss(animated: true, completion: nil)
        } else {
            viewController.modalPresentationStyle = .popover
            viewController.popoverPresentationController?.sourceView = self.view
            viewController.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: 1, height: 1)
            viewController.popoverPresentationController?.permittedArrowDirections = .up
            self.present(viewController, animated: true, completion: nil)
        }
    }
}

extension HostController: MacBridgeStatusItemDelegate {
    func statusItemWasClicked() {
        self.toggleVisible()
    }
}

extension HostController {
    
    func display(window: UIWindow) {
#if targetEnvironment(macCatalyst)
        window.rootViewController = self
        window.windowScene?.titlebar?.titleVisibility = .hidden
        window.windowScene?.sizeRestrictions?.minimumSize = CGSize(width: 1, height: 1)
        window.windowScene?.sizeRestrictions?.maximumSize = CGSize(width: 1, height: 1)
#else
        window.rootViewController = self.contentViewController
#endif
        window.makeKeyAndVisible()
    }
}
