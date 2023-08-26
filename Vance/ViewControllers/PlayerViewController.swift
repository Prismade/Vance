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

class PlayerViewController: UIViewController {
    private var player: AVQueuePlayer?
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
        viewController.delegate = self
        return viewController
    }()
    private lazy var videoContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        return view
    }()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
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
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        preparePlayer()
    }

    private func preparePlayer() {
        player = AVQueuePlayer(items: [])
        player?.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
        player?.automaticallyWaitsToMinimizeStalling = true
        playerViewController.player = player
        playerControlsViewController.player = player
    }

    private func handleYouTubeUrl(_ url: String) {
        Task {
            guard let ytdl = YoutubeDL() else { return }

            do {
                guard let details = try ytdl.extractInfo(from: url) else { return }
                var thumbnail: Data?
                if let thumbnailURLString = details.thumbnail, let thumbnailURL = URL(string: thumbnailURLString) {
                    thumbnail = await downloadThumbnail(from: thumbnailURL)
                }
                playVideo(from: details, with: thumbnail)
            } catch let error {
                print(#file, #line, error.localizedDescription)
            }
        }
    }

    private func downloadThumbnail(from url: URL) async -> Data? {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        } catch {
            return nil
        }
    }

    @MainActor
    private func playVideo(from details: VideoDetails, with thumbnail: Data?) {
        guard let player = player else { return }

        let session = AVAudioSession.sharedInstance()
        do {
            try session.setActive(true)
        } catch {
            print(error.localizedDescription)
        }

        let asset = AVURLAsset(url: details.url, options: ["AVURLAssetHTTPHeaderFieldsKey": details.headers])
        let item = AVPlayerItem(asset: asset)

        var meta: [AVMutableMetadataItem] = []

        let title = AVMutableMetadataItem()
        title.identifier = .commonIdentifierTitle
        title.value = (details.title ?? "YouTube video") as NSString
        meta.append(title)

        if let thumbnail {
            let artwork = AVMutableMetadataItem()
            artwork.identifier = .commonIdentifierArtwork
            artwork.value = thumbnail as NSData
            artwork.dataType = kCMMetadataBaseDataType_JPEG as String
            meta.append(artwork)
        }

        item.externalMetadata = meta

        if player.canInsert(item, after: nil) {
            player.insert(item, after: nil)
        }

        player.play()
    }
}

extension PlayerViewController: VideoPlayerControlsDelegate {
    func addTapped(urlString: String?) {
        guard let urlString else { return }
        handleYouTubeUrl(urlString)
    }

    func playlistTapped() {
        
    }
}
