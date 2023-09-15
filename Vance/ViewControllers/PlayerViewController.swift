//
//  PlayerViewController.swift
//  Vance
//
//  Created by Egor Molchanov on 14.09.2022.
//  Copyright © 2022 Egor and the fucked up. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Python
import PythonKit

final class PlayerViewController: UIViewController {
  private var model: PlayerModel
  private lazy var playerViewController: AVPlayerViewController = {
    let viewController = AVPlayerViewController()
    viewController.view.translatesAutoresizingMaskIntoConstraints = false
    viewController.exitsFullScreenWhenPlaybackEnds = true
    viewController.canStartPictureInPictureAutomaticallyFromInline = true
    return viewController
  }()
  private lazy var playerControlsViewController: VideoPlayerControlsViewController = {
    let viewController = VideoPlayerControlsViewController()
    viewController.view.translatesAutoresizingMaskIntoConstraints = false
    return viewController
  }()
  private lazy var videoContainer: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .black
    return view
  }()
  private lazy var videoDetailsViewController: VideoDetailsViewController = {
    let viewController = VideoDetailsViewController()
    viewController.view.translatesAutoresizingMaskIntoConstraints = false
    return viewController
  }()

  override var preferredStatusBarStyle: UIStatusBarStyle {
    .lightContent
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("Not implemented")
  }

  init(model: PlayerModel) {
    self.model = model
    super.init(nibName: nil, bundle: nil)
    self.playerViewController.player = model.player
    self.playerControlsViewController.model = model
    self.videoDetailsViewController.model = model
  }

  override func loadView() {
    view = UIView()
    view.backgroundColor = .systemBackground
    view.addSubview(videoContainer)
    NSLayoutConstraint.activate([
      videoContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      videoContainer.topAnchor.constraint(equalTo: view.topAnchor),
      videoContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])

    addChild(playerViewController)
    videoContainer.addSubview(playerViewController.view)
    NSLayoutConstraint.activate([
      playerViewController.view.leadingAnchor.constraint(equalTo: videoContainer.leadingAnchor),
      playerViewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      playerViewController.view.trailingAnchor.constraint(equalTo: videoContainer.trailingAnchor),
      playerViewController.view.bottomAnchor.constraint(equalTo: videoContainer.bottomAnchor),
      playerViewController.view.heightAnchor.constraint(equalTo: playerViewController.view.widthAnchor, multiplier: 9.0 / 16.0),
    ])
    playerViewController.didMove(toParent: self)

    addChild(playerControlsViewController)
    view.addSubview(playerControlsViewController.view)
    NSLayoutConstraint.activate([
      playerControlsViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      playerControlsViewController.view.topAnchor.constraint(equalTo: videoContainer.bottomAnchor, constant: 8.0),
      playerControlsViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])
    playerControlsViewController.didMove(toParent: self)

    addChild(videoDetailsViewController)
    view.addSubview(videoDetailsViewController.view)
    NSLayoutConstraint.activate([
      videoDetailsViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      videoDetailsViewController.view.topAnchor.constraint(equalTo: playerControlsViewController.view.bottomAnchor),
      videoDetailsViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setNeedsStatusBarAppearanceUpdate()
  }
}
