//
//  PlayerViewController.swift
//  Vance
//
//  Created by Egor Molchanov on 14.09.2022.
//  Copyright © 2022 Egor and the fucked up. All rights reserved.
//

import UIKit
import AVKit

final class PlayerViewController: UIViewController {
  private var model: PlayerModel
  private lazy var playerViewController: AVPlayerViewController = {
    let viewController = AVPlayerViewController()
    viewController.view.translatesAutoresizingMaskIntoConstraints = false
    viewController.exitsFullScreenWhenPlaybackEnds = true
    viewController.canStartPictureInPictureAutomaticallyFromInline = true
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
  private lazy var addButton: UIButton = {
    var configuration = UIButton.Configuration.gray()
    configuration.title = NSLocalizedString("Add", comment: "")
    let button = UIButton(configuration: configuration)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(handleAddButtonTap(_:)), for: .touchUpInside)
    return button
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

    view.addSubview(addButton)
    NSLayoutConstraint.activate([
      addButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16.0),
      addButton.topAnchor.constraint(equalTo: videoContainer.bottomAnchor, constant: 8.0),
      addButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16.0),
    ])

    addChild(videoDetailsViewController)
    view.addSubview(videoDetailsViewController.view)
    NSLayoutConstraint.activate([
      videoDetailsViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      videoDetailsViewController.view.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 8.0),
      videoDetailsViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setNeedsStatusBarAppearanceUpdate()
  }

  @objc
  private func handleAddButtonTap(_ sender: UIButton) {
    let alertController = UIAlertController(
      title: NSLocalizedString("Open video", comment: ""),
      message: NSLocalizedString("Paste a link to a YouTube video here and hit the open button", comment: ""),
      preferredStyle: .alert)
    alertController.addTextField { textField in
      textField.clearButtonMode = .whileEditing
      textField.keyboardType = .URL
      textField.placeholder = "https://youtu.be/..."
    }
    alertController.addAction(
      UIAlertAction(
        title: NSLocalizedString("Open", comment: ""),
        style: .default,
        handler: { [weak self] _ in
          guard 
            let self,
            let urlText = alertController.textFields?.first?.text,
            !urlText.isEmpty
          else {
            return
          }
          Task {
            await self.model.playVideo(from: urlText)
          }
        }))
    alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
    alertController.view.tintColor = UIColor(named: "AccentColor")
    present(alertController, animated: true)
  }
}
