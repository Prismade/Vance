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
      await video.downloadThumbnail()
      await MainActor.run {
        play(video: video)
      }
    } catch let error {
      print(#file, #line, error.localizedDescription)
    }
  }

  func play(video: Video) {
    let session = AVAudioSession.sharedInstance()
    do {
      try session.setActive(true)
    } catch {
      print(error.localizedDescription)
    }

    let asset = AVURLAsset(url: video.url, options: ["AVURLAssetHTTPHeaderFieldsKey": video.headers])
    let item = AVPlayerItem(asset: asset)

    var meta: [AVMutableMetadataItem] = []

    let title = AVMutableMetadataItem()
    title.identifier = .commonIdentifierTitle
    title.value = (video.title ?? "YouTube video") as NSString
    meta.append(title)

    if let thumbnail = video.thumbnailData {
      let artwork = AVMutableMetadataItem()
      artwork.identifier = .commonIdentifierArtwork
      artwork.value = thumbnail as NSData
      artwork.dataType = kCMMetadataBaseDataType_JPEG as String
      meta.append(artwork)
    }

    item.externalMetadata = meta
    
    player.replaceCurrentItem(with: item)
    player.play()

    NotificationCenter.default.post(name: Notification.Name("ShouldUpdateVideoDetails"), object: self, userInfo: ["Video": video])
  }
}
