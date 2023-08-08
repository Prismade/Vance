//
//  VideoPlayerViewController.swift
//  Vance
//
//  Created by Egor Molchanov on 28.06.2023.
//  Copyright © 2023 Egor and the fucked up. All rights reserved.
//

import AVFoundation
import UIKit

final class VideoPlayerViewController: UIViewController, VideoPlayerViewDelegate {
    var playerView: VideoPlayerView {
        return view as! VideoPlayerView
    }
    var player: AVQueuePlayer? {
        get {
            return playerView.player
        }
        set {
            playerView.player = newValue
        }
    }
    private var controlsHideTimer: Timer?

    override func loadView() {
        view = VideoPlayerView()
        playerView.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - VideoPlayerViewDelegate

    func handlePlayButtonTap(_ sender: UIButton) {
        guard let player, player.currentItem != nil else { return }
        switch player.timeControlStatus {
        case .paused:
            player.play()
        case .playing:
            player.pause()
        default:
            break
        }
    }

    func handlePrevButtonTap(_ sender: UIButton) {

    }

    func handleNextButtonTap(_ sender: UIButton) {

    }

    func handleFullscreenButtonTap(_ sender: UIButton) {

    }

    func handlePiPButtonTap(_ sender: UIButton) {

    }

    func handleSettingsButtonTap(_ sender: UIButton) {

    }

    func handleSliderValeChanged(_ sender: UISlider) {
        
    }
}
