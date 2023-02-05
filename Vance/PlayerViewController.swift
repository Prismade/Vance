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

class PlayerViewController: UIViewController {
    private var player: AVQueuePlayer?
    private lazy var playerViewController: AVPlayerViewController = {
        let viewController = AVPlayerViewController()
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        return viewController
    }()
    private lazy var videoContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        return view
    }()
    private lazy var hintLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.text = "Paste a link to a YouTube video here and hit the open button".localized
        return label
    }()
    private lazy var linkTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = .whileEditing
        textField.keyboardType = .URL
        textField.delegate = self
        textField.addTarget(self, action: #selector(handleLinkTextFieldEditingChanged(_:)), for: .editingChanged)
        return textField
    }()
    private lazy var pasteButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Use pasteboard".localized
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        button.addTarget(self, action: #selector(handlePasteButtonTap(_:)), for: .touchUpInside)
        return button
    }()
    private lazy var openButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Open".localized
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleOpenButtonTap(_:)), for: .touchUpInside)
        return button
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleViewTap(_:))))
        createViewsHierarchy()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        setLayoutConstraints()
        addObserversForNotifications()
        preparePlayer()
    }
    
    private func addObserversForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleUrlIsAvailableInPasteboardNotification(_:)), name: .urlIsAvailableFromPasteboard, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleUrlIsUnavailableInPasteboardNotification(_:)), name: .urlIsUnavailableFromPasteboard, object: nil)
    }
    
    private func preparePlayer() {
        player = AVQueuePlayer(items: [])
        player?.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
        player?.automaticallyWaitsToMinimizeStalling = true
        playerViewController.player = player
    }
    
    @objc
    private func handleUrlIsAvailableInPasteboardNotification(_ notification: Notification) {
        pasteButton.isEnabled = true
    }
    
    @objc
    private func handleUrlIsUnavailableInPasteboardNotification(_ notification: Notification) {
        pasteButton.isEnabled = false
    }
    
    @objc
    private func handleViewTap(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @objc
    private func handleLinkTextFieldEditingChanged(_ sender: UITextField) {
        openButton.isEnabled = sender.text != nil && sender.text != ""
    }
    
    @objc
    private func handleOpenButtonTap(_ sender: UIButton) {
        view.endEditing(true)
        guard
            let urlString = linkTextField.text,
            let url = URL(string: urlString)
        else {
            presentAlert(title: "Unable to load video".localized, message: "An error occurred".localized)
            return
        }
        handleYouTubeUrl(url)
    }
    
    @objc
    private func handlePasteButtonTap(_ sender: UIButton) {
        guard let urlFromPasteboard = UIPasteboard.general.url else { return }
        linkTextField.text = urlFromPasteboard.absoluteString
        openButton.isEnabled = true
        handleYouTubeUrl(urlFromPasteboard)
    }
    
    private func handleYouTubeUrl(_ url: URL) {
        Task {
            do {
                let mediaUrl = try await MediaSource.mediaUrl(for: url)
                playVideo(from: mediaUrl)
            } catch {
                print(error.localizedDescription)
                presentAlert(title: "Unable to load video".localized, message: "An error occurred".localized)
            }
        }
    }
    
    @MainActor
    private func playVideo(from url: URL) {
        guard let player = player else { return }
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setActive(true)
        } catch {
            print(error.localizedDescription)
        }
        
        let item = AVPlayerItem(url: url)
        if player.canInsert(item, after: nil) {
            player.insert(item, after: nil)
        }
        
        print("Playing \(url.absoluteString)")
        
        if player.items().count > 1 {
            player.advanceToNextItem()
        }
        
        player.play()
    }
    
    @MainActor
    private func presentAlert(title: String?, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK".localized, style: .default)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
}

// MARK: - Layout and views hierarchy

private extension PlayerViewController {
    func createViewsHierarchy() {
        view.addSubview(videoContainer)
        view.addSubview(hintLabel)
        view.addSubview(linkTextField)
        view.addSubview(pasteButton)
        view.addSubview(openButton)
        
        addChild(playerViewController)
        videoContainer.addSubview(playerViewController.view)
        playerViewController.didMove(toParent: self)
    }
    
    func setLayoutConstraints() {
        NSLayoutConstraint.activate([
            videoContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            videoContainer.topAnchor.constraint(equalTo: view.topAnchor),
            videoContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            

            
            hintLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0),
            hintLabel.topAnchor.constraint(equalTo: videoContainer.bottomAnchor, constant: 20.0),
            hintLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0),
            
            linkTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0),
            linkTextField.topAnchor.constraint(equalTo: hintLabel.bottomAnchor, constant: 16.0),
            linkTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0),
            
            pasteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0),
            pasteButton.topAnchor.constraint(equalTo: linkTextField.bottomAnchor, constant: 16.0),
            pasteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0),
            
            openButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0),
            openButton.topAnchor.constraint(equalTo: pasteButton.bottomAnchor, constant: 16.0),
            openButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0),
            
            playerViewController.view.leadingAnchor.constraint(equalTo: videoContainer.leadingAnchor),
            playerViewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            playerViewController.view.trailingAnchor.constraint(equalTo: videoContainer.trailingAnchor),
            playerViewController.view.bottomAnchor.constraint(equalTo: videoContainer.bottomAnchor),
            playerViewController.view.heightAnchor.constraint(equalTo: playerViewController.view.widthAnchor, multiplier: 9.0 / 16.0)
        ])
    }
}

// MARK: - Text Field Delegate

extension PlayerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        linkTextField.resignFirstResponder()
        return true
    }
}
