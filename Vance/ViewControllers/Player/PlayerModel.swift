//
//  PlayerModel.swift
//  Vance
//
//  Created by Egor Molchanov on 31.08.2023.
//  Copyright © 2023 Egor and the fucked up. All rights reserved.
//

import AVFoundation

final class PlayerModel {
  let player: AVPlayer
  let queue: PlayerQueue?

  init() {
    self.player = if Settings.isQueueEnabled {
      AVQueuePlayer()
    } else {
      AVPlayer()
    }
    self.player.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
    self.player.automaticallyWaitsToMinimizeStalling = true

    self.queue = if let queuePlayer = player as? AVQueuePlayer  {
      PlayerQueue(player: queuePlayer)
    } else {
      nil
    }
  }

  func setQueueDelegate(_ delegate: PlayerQueueDelegate) {
    queue?.delegate = delegate
  }

  func queueViewControllerData() -> (videos: [Video], index: Int)? {
    queue?.createDataForViewController()
  }

  func extractInfo(from url: String) async -> Video? {
    do {
      return try YoutubeDL()?.extractInfo(from: url)
    } catch let error {
      print(#file, #line, error.localizedDescription)
      return nil
    }
  }

  func playVideo(from url: String) async {
    guard let video = await extractInfo(from: url) else { return }
    await MainActor.run {
      play(video: video)
    }
  }

  func addVideoToQueue(from url: String) async {
    guard let video = await extractInfo(from: url) else { return }
    await MainActor.run {
      queue?.append(video: video)
    }
  }

  @MainActor
  func addVideoToQueue(_ video: Video) async {
    queue?.append(video: video)
  }

  func play(video: Video) {
    guard let item = video.playerItem else { return }

    if Settings.isQueueEnabled {
      queue?.open(video: video)
    } else {
      let session = AVAudioSession.sharedInstance()
      do {
        try session.setActive(true)
      } catch {
        print(error.localizedDescription)
      }

      player.replaceCurrentItem(with: item)
      player.play()

      NotificationCenter.default.post(name: Notification.Name("ShouldUpdateVideoDetails"), object: self, userInfo: ["Video": video])
    }
  }

  func forward() {
    queue?.forward()
  }

  func backward() {
    queue?.backward()
  }

  func clear() {
    queue?.clear()
    NotificationCenter.default.post(name: Notification.Name("ShouldUpdateVideoDetails"), object: self, userInfo: nil)
  }
}
