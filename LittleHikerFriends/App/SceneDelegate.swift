//
//  SceneDelegate.swift
//  LittleHikerFriends
//
//  Created by Kyuhee hong on 4/19/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)

        do {
            // Kakao Provider
            let provider = KakaoLoginProvider()

            // Firestore Repository
            let userRepo = UserRepository()

            // Firebase AuthService (Kakao → Functions kakaoLogin → CustomToken → signIn)
            let authService = FirebaseAuthService(provider: provider, userRepo: userRepo)

            // ViewModel / Root VC
            let vm = LoginViewModel(auth: authService)
            let root = LoginViewController(vm: vm)

            window.rootViewController = UINavigationController(rootViewController: root)
            self.window = window
            window.makeKeyAndVisible()
            
            print("✅ LoginViewController 초기화 성공")
            
        } catch {
            print("❌ LoginViewController 초기화 실패: \(error)")
            
            // 실패 시 폴백 화면
            let fallbackVC = UIViewController()
            fallbackVC.view.backgroundColor = .systemRed
            
            let label = UILabel()
            label.text = "초기화 오류\n\(error.localizedDescription)"
            label.textColor = .white
            label.font = .systemFont(ofSize: 16)
            label.textAlignment = .center
            label.numberOfLines = 0
            
            fallbackVC.view.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: fallbackVC.view.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: fallbackVC.view.centerYAnchor),
                label.leadingAnchor.constraint(greaterThanOrEqualTo: fallbackVC.view.leadingAnchor, constant: 20),
                label.trailingAnchor.constraint(lessThanOrEqualTo: fallbackVC.view.trailingAnchor, constant: -20)
            ])
            
            window.rootViewController = fallbackVC
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

