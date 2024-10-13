//
//  SceneDelegate.swift
//  MusicPlay
//
//  Created by ZverikRS on 22.03.2024.
//

import UIKit

// MARK: - class

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    // MARK: - public properties
    
    var window: UIWindow?
    
    // MARK: - life cycle
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = .init(windowScene: windowScene)
        window?.rootViewController = UINavigationController(rootViewController: MainBuilder().build())
        window?.makeKeyAndVisible()
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
}
