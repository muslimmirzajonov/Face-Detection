//
//  SceneDelegate.swift
//  FaceDetectApp
//
//  Created by Muslim Mirzajonov on 20/03/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        let firstViewController = TabBarController()
        window.rootViewController = firstViewController
        window.makeKeyAndVisible()
        self.window = window
    }
}
