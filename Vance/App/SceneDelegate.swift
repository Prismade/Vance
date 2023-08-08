//
//  SceneDelegate.swift
//  Vance
//
//  Created by Egor Molchanov on 14.09.2022.
//  Copyright © 2022 Egor and the fucked up. All rights reserved.
//

import UIKit
import AVFoundation

class SceneDelegate: UIResponder {
    var window: UIWindow?
    
    func checkPasteboardForUrlAndPostNotification() {
        if UIPasteboard.general.hasURLs {
            NotificationCenter.default.post(name: .urlIsAvailableFromPasteboard, object: self)
        } else {
            NotificationCenter.default.post(name: .urlIsUnavailableFromPasteboard, object: self)
        }
    }
    
    func setupAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func openPlayerViewController() {
        let viewController = PlayerViewController()
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
    }
}

extension SceneDelegate: UIWindowSceneDelegate {
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.windowScene = windowScene
        setupAudioSession()
        openPlayerViewController()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        checkPasteboardForUrlAndPostNotification()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        checkPasteboardForUrlAndPostNotification()
    }
}

