import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }

        /// Build our own window so we can decide what to show first.
        let window = UIWindow(windowScene: windowScene)
        self.window = window

        /// Always start at the Splash screen. When its progress bar
        /// finishes, it tells us — and *then* we route to Login or TaskList.
        window.rootViewController = makeSplash()
        window.makeKeyAndVisible()
    }

    // MARK: - Building screens

    /// The branded splash. When it's done, we decide where to go next.
    private func makeSplash() -> UIViewController {
        let splashVC = SplashViewController()
        splashVC.onFinish = { [weak self] in
            self?.routeAfterSplash()
        }
        return splashVC
    }

    /// Picks the next screen based on whether the user is already logged in.
    private func routeAfterSplash() {
        if TokenStore.shared.isLoggedIn {
            switchToTaskList()
        } else {
            switchToLogin()
        }
    }

    /// The Login screen wrapped in a navigation controller so it can push to Register.
    private func makeLogin() -> UIViewController {
        let loginVC = LoginViewController()
        loginVC.onLoginSuccess = { [weak self] in
            self?.switchToTaskList()
        }
        return UINavigationController(rootViewController: loginVC)
    }

    /// The existing task list from the storyboard.
    /// The storyboard already wraps it in a navigation controller, so we
    /// just hand it back as-is.
    private func makeTaskList() -> UIViewController {
        let storyboard = UIStoryboard(name: "TaskList", bundle: nil)
        return storyboard.instantiateInitialViewController()
            ?? UINavigationController(rootViewController: TaskListViewController())
    }

    /// Swap the root window from Login to the task list (used after a successful login).
    private func switchToTaskList() {
        guard let window = window else { return }
        window.rootViewController = makeTaskList()

        /// A small fade looks nicer than a hard cut.
        UIView.transition(with: window,
                          duration: 0.25,
                          options: .transitionCrossDissolve,
                          animations: nil)
    }

    /// Swap the root window back to the Login screen (used after logout).
    /// Marked `internal` (the default) so the Profile screen can call it.
    func switchToLogin() {
        guard let window = window else { return }
        window.rootViewController = makeLogin()

        UIView.transition(with: window,
                          duration: 0.25,
                          options: .transitionCrossDissolve,
                          animations: nil)
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
