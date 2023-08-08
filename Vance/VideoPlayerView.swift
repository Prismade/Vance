//
//  VideoPlayerView.swift
//  Vance
//
//  Created by Egor Molchanov on 23.06.2023.
//  Copyright © 2023 Egor and the fucked up. All rights reserved.
//

import UIKit
import AVFoundation

protocol VideoPlayerViewDelegate: AnyObject {
    func handlePlayButtonTap(_ sender: UIButton)
    func handlePrevButtonTap(_ sender: UIButton)
    func handleNextButtonTap(_ sender: UIButton)
    func handleFullscreenButtonTap(_ sender: UIButton)
    func handlePiPButtonTap(_ sender: UIButton)
    func handleSettingsButtonTap(_ sender: UIButton)
    func handleSliderValeChanged(_ sender: UISlider)
}

final class VideoPlayerView: UIView {
    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    weak var delegate: VideoPlayerViewDelegate?
    var player: AVQueuePlayer? {
        get {
            return playerLayer.player as? AVQueuePlayer
        }
        set {
            playerLayer.player = newValue
        }
    }
    private var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }

    // MARK: - Controls

    lazy var playButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.buttonSize = .large
        config.cornerStyle = .capsule
        let button = UIButton(configuration: config)
        let normalConfig = UIImage.SymbolConfiguration(pointSize: 42.0)
        button.setImage(UIImage(systemName: "play.fill", withConfiguration: normalConfig), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    lazy var prevButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.buttonSize = .medium
        config.cornerStyle = .capsule
        config.image = UIImage(systemName: "backward.end.fill")
        let button = UIButton(configuration: config)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    lazy var nextButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.buttonSize = .medium
        config.cornerStyle = .capsule
        config.image = UIImage(systemName: "forward.end.fill")
        let button = UIButton(configuration: config)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    lazy var fullscreenButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.buttonSize = .small
        config.cornerStyle = .capsule
        config.image = UIImage(systemName: "arrow.up.left.and.arrow.down.right")
        let button = UIButton(configuration: config)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    lazy var pipButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.buttonSize = .small
        config.cornerStyle = .capsule
        config.image = UIImage(systemName: "pip.enter")
        let button = UIButton(configuration: config)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    lazy var settingsButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.buttonSize = .small
        config.cornerStyle = .capsule
        config.image = UIImage(systemName: "ellipsis.circle")
        let button = UIButton(configuration: config)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    lazy var slider: UISlider = {
        let slider = UISlider()
        slider.minimumTrackTintColor = .white
        slider.maximumTrackTintColor = .white.withAlphaComponent(0.5)
        slider.setThumbImage(UIImage.circle(diameter: 16.0, color: .white), for: .normal)
        slider.setThumbImage(UIImage.circle(diameter: 20.0, color: .white), for: .highlighted)
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    lazy var currentTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "--:--"
        label.textAlignment = .left
        label.textColor = .white
        label.font = .systemFont(ofSize: 13.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var totalTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "--:--"
        label.textAlignment = .right
        label.textColor = .white
        label.font = .systemFont(ofSize: 13.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Methods

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black

        addSubview(playButton)
        NSLayoutConstraint.activate([
            playButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        addSubview(prevButton)
        NSLayoutConstraint.activate([
            prevButton.centerYAnchor.constraint(equalTo: playButton.centerYAnchor),
            prevButton.trailingAnchor.constraint(equalTo: playButton.leadingAnchor, constant: -40.0)
        ])

        addSubview(nextButton)
        NSLayoutConstraint.activate([
            nextButton.centerYAnchor.constraint(equalTo: playButton.centerYAnchor),
            nextButton.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 40.0)
        ])

        addSubview(fullscreenButton)
        NSLayoutConstraint.activate([
            fullscreenButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
            fullscreenButton.topAnchor.constraint(equalTo: topAnchor, constant: 16.0)
        ])

        addSubview(pipButton)
        NSLayoutConstraint.activate([
            pipButton.leadingAnchor.constraint(equalTo: fullscreenButton.trailingAnchor, constant: 20.0),
            pipButton.centerYAnchor.constraint(equalTo: fullscreenButton.centerYAnchor)
        ])

        addSubview(settingsButton)
        NSLayoutConstraint.activate([
            settingsButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0),
            settingsButton.topAnchor.constraint(equalTo: topAnchor, constant: 16.0)
        ])

        addSubview(slider)
        NSLayoutConstraint.activate([
            slider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
            slider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0),
            slider.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16.0),
        ])

        addSubview(currentTimeLabel)
        NSLayoutConstraint.activate([
            currentTimeLabel.leadingAnchor.constraint(equalTo: slider.leadingAnchor),
            currentTimeLabel.bottomAnchor.constraint(equalTo: slider.topAnchor, constant: -8.0)
        ])

        addSubview(totalTimeLabel)
        NSLayoutConstraint.activate([
            totalTimeLabel.trailingAnchor.constraint(equalTo: slider.trailingAnchor),
            totalTimeLabel.bottomAnchor.constraint(equalTo: slider.topAnchor, constant: -8.0)
        ])

        addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(handlePlayerViewTap(_:))))
        playButton.addTarget(self, action: #selector(handlePlayButtonTap(_:)), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(handleNextButtonTap(_:)), for: .touchUpInside)
        prevButton.addTarget(self, action: #selector(handlePrevButtonTap(_:)), for: .touchUpInside)
        fullscreenButton.addTarget(self, action: #selector(handleFullscreenButtonTap(_:)), for: .touchUpInside)
        pipButton.addTarget(self, action: #selector(handlePiPButtonTap(_:)), for: .touchUpInside)
        settingsButton.addTarget(self, action: #selector(handleSettingsButtonTap(_:)), for: .touchUpInside)
        slider.addTarget(self, action: #selector(handleSliderValeChanged(_:)), for: .valueChanged)
    }

    func toggleControlsTransparencyLevel() {
        fullscreenButton.alpha = fullscreenButton.alpha == 1.0 ? 0.0 : 1.0
        pipButton.alpha = pipButton.alpha == 1.0 ? 0.0 : 1.0
        settingsButton.alpha = settingsButton.alpha == 1.0 ? 0.0 : 1.0
        prevButton.alpha = prevButton.alpha == 1.0 ? 0.0 : 1.0
        playButton.alpha = playButton.alpha == 1.0 ? 0.0 : 1.0
        nextButton.alpha = nextButton.alpha == 1.0 ? 0.0 : 1.0
        currentTimeLabel.alpha = currentTimeLabel.alpha == 1.0 ? 0.0 : 1.0
        totalTimeLabel.alpha = totalTimeLabel.alpha == 1.0 ? 0.0 : 1.0
        slider.alpha = slider.alpha == 1.0 ? 0.0 : 1.0
    }

    // MARK: - Gesture handlers

    @objc
    private func handlePlayerViewTap(_ sender: UITapGestureRecognizer) {
        guard sender.state == .recognized else { return }
        UIView.animate(withDuration: 0.3) {
            self.toggleControlsTransparencyLevel()
        }
    }

    @objc
    private func handlePlayButtonTap(_ sender: UIButton) {
        defer { delegate?.handlePlayButtonTap(sender) }
        guard let player, player.currentItem != nil else { return }
        let normalConfig = UIImage.SymbolConfiguration(pointSize: 42.0)
        switch player.timeControlStatus {
        case .playing:
            playButton.setImage(
                UIImage(systemName: "play.fill", withConfiguration: normalConfig),
                for: .normal)
        case .paused:
            playButton.setImage(
                UIImage(systemName: "pause.fill", withConfiguration: normalConfig),
                for: .normal)
        default:
            break
        }
    }

    @objc
    private func handlePrevButtonTap(_ sender: UIButton) {
        delegate?.handlePrevButtonTap(sender)
    }

    @objc
    private func handleNextButtonTap(_ sender: UIButton) {
        delegate?.handleNextButtonTap(sender)
    }

    @objc
    private func handleFullscreenButtonTap(_ sender: UIButton) {
        delegate?.handleFullscreenButtonTap(sender)
    }

    @objc
    private func handlePiPButtonTap(_ sender: UIButton) {
        delegate?.handlePiPButtonTap(sender)
    }

    @objc
    private func handleSettingsButtonTap(_ sender: UIButton) {
        delegate?.handleSettingsButtonTap(sender)
    }

    @objc
    private func handleSliderValeChanged(_ sender: UISlider) {
        delegate?.handleSliderValeChanged(sender)
    }
}

#Preview {
    let playerView = VideoPlayerView()
    playerView.translatesAutoresizingMaskIntoConstraints = false

    let view = UIView()
    view.backgroundColor = .systemGroupedBackground
    view.addSubview(playerView)
    NSLayoutConstraint.activate([
        playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        playerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        playerView.widthAnchor.constraint(equalTo: playerView.heightAnchor, multiplier: 16.0 / 9.0)
    ])
    return view
}
