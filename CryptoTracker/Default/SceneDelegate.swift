//
//  SceneDelegate.swift
//  CryptoTracker
//
//  Created by Artyom Gurbovich on 3/4/20.
//  Copyright © 2020 Artyom Gurbovich. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        window?.overrideUserInterfaceStyle = .light
    }
}
