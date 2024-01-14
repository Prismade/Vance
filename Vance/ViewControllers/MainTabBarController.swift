//
//  MainTabBarController.swift
//  Vance
//
//  Created by Egor Molchanov on 31.12.2023.
//  Copyright © 2023 Egor and the fucked up. All rights reserved.
//

import UIKit

final class MainTabBarController: UITabBarController {
  override func viewDidLoad() {
    super.viewDidLoad()
    let playerViewController = PlayerViewController(model: PlayerModel())
    playerViewController.tabBarItem = UITabBarItem(title: NSLocalizedString("Video", comment: ""), image: UIImage(systemName: "film"), tag: 0)
    let settingsViewController = SettingsViewController(style: .insetGrouped)
    settingsViewController.tabBarItem = UITabBarItem(title: NSLocalizedString("Settings", comment: ""), image: UIImage(systemName: "gearshape"), tag: 1)
    viewControllers = [playerViewController, UINavigationController(rootViewController: settingsViewController)]
  }
}
