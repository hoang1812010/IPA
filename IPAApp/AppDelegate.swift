import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        // Kiểm tra xem app đã được kích hoạt trước đó hay chưa
        let isActivated = UserDefaults.standard.bool(forKey: "App_Activated")
        
        if isActivated {
            // ĐÃ KÍCH HOẠT: Đi thẳng vào màn hình chính (ViewController)
            let mainVC = ViewController()
            // Bọc trong UINavigationController để có thanh điều hướng (NavigationBar) nếu cần
            let navController = UINavigationController(rootViewController: mainVC)
            window?.rootViewController = navController
        } else {
            // CHƯA KÍCH HOẠT: Hiện màn hình nhập Key (LoginViewController)
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
