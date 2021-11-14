import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let window = UIWindow()
        let hostController = HostController(
            statusItemImage: UIImage(systemName: "cursorarrow.click.2"),
            contentViewController: ViewController()
        )
        hostController.display(window: window)
        self.window = window
        
        return true
    }

    override func buildMenu(with builder: UIMenuBuilder) {
        builder.remove(menu: .file)
        builder.remove(menu: .format)
        builder.remove(menu: .view)
        builder.remove(menu: .window)
        builder.remove(menu: .help)
    }
}

