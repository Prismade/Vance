//
//  PlayerModel.swift
//  Vance
//
//  Created by Egor Molchanov on 31.08.2023.
//  Copyright © 2023 Egor and the fucked up. All rights reserved.
//

import AVFoundation

final class PlayerModel {
  var player: AVPlayer

  init() {
    self.player = AVPlayer()
    self.player.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
    self.player.automaticallyWaitsToMinimizeStalling = true
  }

  func playVideo(from url: String) async {
    do {
      guard let video = try YoutubeDL()?.extractInfo(from: url) else { return }
      await MainActor.run {
        play(video: video)
      }
    } catch let error {
      print(#file, #line, error.localizedDescription)
    }
  }

  func play(video: Video) {
    guard let videoURL = video.url, let videoHeaders = video.headers else { return }

    let session = AVAudioSession.sharedInstance()
    do {
      try session.setActive(true)
    } catch {
      print(error.localizedDescription)
    }

    let asset = AVURLAsset(url: videoURL, options: ["AVURLAssetHTTPHeaderFieldsKey": videoHeaders])
    let item = AVPlayerItem(asset: asset)

    var meta: [AVMutableMetadataItem] = []

    let title = AVMutableMetadataItem()
    title.identifier = .commonIdentifierTitle
    title.value = (video.info.title ?? "YouTube video") as NSString
    meta.append(title)


    item.externalMetadata = meta
    
    player.replaceCurrentItem(with: item)
    player.play()

    NotificationCenter.default.post(name: Notification.Name("ShouldUpdateVideoDetails"), object: self, userInfo: ["Video": video])
  }
}
