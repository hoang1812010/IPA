import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        // Kiểm tra trạng thái đã kích hoạt chưa
        let isActivated = UserDefaults.standard.bool(forKey: "App_Activated")
        
        if isActivated {
            // ĐÃ ACTIVE: Đi thẳng vào màn hình chính (ViewController)
            let mainVC = ViewController()
            let nav = UINavigationController(rootViewController: mainVC)
            window?.rootViewController = nav
        } else {
            // CHƯA ACTIVE: Hiện màn hình nhập Key (LoginViewController)
            let loginVC = LoginViewController()
            window?.rootViewController = loginVC
        }
        
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
