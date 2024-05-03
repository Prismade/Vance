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
  private lazy var debugButton: UIButton = {
    var configuration = UIButton.Configuration.gray()
    configuration.title = NSLocalizedString("Debug", comment: "")
    let button = UIButton(configuration: configuration)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(handleDebugButtonTap(_:)), for: .touchUpInside)
    return button
  }()
  private lazy var backwardButton: UIButton = {
    var configuration = UIButton.Configuration.gray()
    configuration.image = UIImage(systemName: "backward.end.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .small))
    let button = UIButton(configuration: configuration)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(handleBackwardButtonTap(_:)), for: .touchUpInside)
    NSLayoutConstraint.activate([
      button.widthAnchor.constraint(equalToConstant: 40.0)
    ])
    return button
  }()
  private lazy var forwardButton: UIButton = {
    var configuration = UIButton.Configuration.gray()
    configuration.image = UIImage(systemName: "forward.end.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .small))
    let button = UIButton(configuration: configuration)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(handleForwardButtonTap(_:)), for: .touchUpInside)
    NSLayoutConstraint.activate([
      button.widthAnchor.constraint(equalToConstant: 40.0)
    ])
    return button
  }()
  private lazy var queueButton: UIButton = {
    var configuration = UIButton.Configuration.gray()
    configuration.title = NSLocalizedString("Queue", comment: "")
    let button = UIButton(configuration: configuration)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(handleQueueButtonTap(_:)), for: .touchUpInside)
    return button
  }()
  private lazy var openButton: UIButton = {
    var configuration = UIButton.Configuration.gray()
    if Settings.isQueueEnabled {
      configuration.image = UIImage(systemName: "plus.app")
    } else {
      configuration.title = NSLocalizedString("Open", comment: "")
    }
    let button = UIButton(configuration: configuration)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(handleOpenButtonTap(_:)), for: .touchUpInside)
    if Settings.isQueueEnabled {
      NSLayoutConstraint.activate([
        button.widthAnchor.constraint(equalToConstant: 40.0)
      ])
    }
    return button
  }()
  private lazy var controlsStack: UIStackView = {
    let view = UIStackView(arrangedSubviews: [backwardButton, forwardButton, queueButton, openButton])
    view.translatesAutoresizingMaskIntoConstraints = false
    view.spacing = 8.0
    return view
  }()
  private lazy var buttonsStack: UIStackView = {
    var arrangedSubviews: [UIView] = []
    if CommandLine.arguments.contains("-DDEBUG") {
      arrangedSubviews.append(debugButton)
    }
    if Settings.isQueueEnabled {
      arrangedSubviews.append(controlsStack)
    } else {
      arrangedSubviews.append(openButton)
    }

    let view = UIStackView(arrangedSubviews: arrangedSubviews)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.axis = .vertical
    view.spacing = 8.0
    return view
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

    addChild(videoDetailsViewController)
    view.addSubview(videoDetailsViewController.view)
    NSLayoutConstraint.activate([
      videoDetailsViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      videoDetailsViewController.view.topAnchor.constraint(equalTo: videoContainer.bottomAnchor),
      videoDetailsViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      videoDetailsViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])

    view.addSubview(buttonsStack)
    NSLayoutConstraint.activate([
      buttonsStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16.0),
      buttonsStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8.0),
      buttonsStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16.0),
    ])
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setNeedsStatusBarAppearanceUpdate()
  }

  @objc
  private func handleDebugButtonTap(_ sender: UIButton) {
    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    alertController.addAction(
      UIAlertAction(
        title: NSLocalizedString("Open test video", comment: ""),
        style: .default,
        handler: { [weak self] _ in
          guard let self else { return }
          let testVideo = Video.sample
          self.model.play(video: testVideo)
        }))
    alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
    alertController.view.tintColor = UIColor(named: "AccentColor")
    present(alertController, animated: true)
  }

  @objc
  private func handleBackwardButtonTap(_ seder: UIButton) {

  }

  @objc
  private func handleForwardButtonTap(_ sender: UIButton) {

  }

  @objc
  private func handleQueueButtonTap(_ sender: UIButton) {
    let viewController = UINavigationController(rootViewController: QueueTableViewController(style: .plain))
    viewController.modalPresentationStyle = .pageSheet
    if let sheet = viewController.sheetPresentationController {
      sheet.detents = [.medium(), .large()]
      sheet.largestUndimmedDetentIdentifier = .medium
      sheet.prefersGrabberVisible = true
    }
    present(viewController, animated: true)
  }

  @objc
  private func handleOpenButtonTap(_ sender: UIButton) {
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
