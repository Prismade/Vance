//
//  PlayerModel.swift
//  Vance
//
//  Created by Egor Molchanov on 31.08.2023.
//  Copyright © 2023 Egor and the fucked up. All rights reserved.
//

import AVFoundation
import Combine

final class PlayerModel {
  var player: AVPlayer
  var queue: [VideoDetails] = []
  var currentItemIndex: Int = -1
  var didFinishPlayingQueue: Bool = true

  private var subscriptions: Set<AnyCancellable> = []
  
  init() {
    self.player = AVPlayer()
    self.player.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
    self.player.automaticallyWaitsToMinimizeStalling = true
    NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime).sink { _ in
      guard self.queue.count > 1, self.currentItemIndex != self.queue.count - 1 else {
        self.didFinishPlayingQueue = true
        return
      }
      self.advanceToNextItem()
    }.store(in: &subscriptions)
  }
  
  func addVideoToQueue(fromURL url: String) {
    guard let ytdl = YoutubeDL() else { return }

    Task {
      do {
        guard let info = try ytdl.extractInfo(from: url) else { return }
        await MainActor.run {
          queue.append(info)
          guard didFinishPlayingQueue else { return }
          didFinishPlayingQueue = false
          advanceToNextItem()
        }
      } catch let error {
        print(#file, #line, error.localizedDescription)
      }
    }
  }
  
  func removeVideoFromQueue(atIndex index: Int) {
    guard index >= 0 && index < queue.count else { return }
    if currentItemIndex == index {
      queue.remove(at: index)
      playCurrentItem()
    } else {
      let currentItem = queue[currentItemIndex]
      queue.remove(at: index)
      currentItemIndex = queue.firstIndex { $0 == currentItem } ?? -1
    }
  }
  
  func clearQueue() {
    guard currentItemIndex >= 0 && currentItemIndex < queue.count else { return }
    let currentItem = queue[currentItemIndex]
    queue.removeAll()
    queue.append(currentItem)
    currentItemIndex = 0
  }

  func purgeQueue() {
    queue.removeAll()
    currentItemIndex = -1
    didFinishPlayingQueue = true
  }

  func advanceToNextItem() {
    guard !queue.isEmpty, self.currentItemIndex < self.queue.count - 1 else { return }
    currentItemIndex += 1
    playCurrentItem()
  }
  
  func advanceToPrevItem() {
    guard currentItemIndex > 0 else { return }
    currentItemIndex = currentItemIndex - 1
    playCurrentItem()
  }

  func advanceToItem(at index: Int) {
    guard index >= 0 && index < queue.count else { return }
    currentItemIndex = index
    playCurrentItem()
  }

  private func playCurrentItem() {
    let currentItem = queue[currentItemIndex]
    
    let session = AVAudioSession.sharedInstance()
    do {
      try session.setActive(true)
    } catch {
      print(error.localizedDescription)
    }
    
    let asset = AVURLAsset(url: currentItem.url, options: ["AVURLAssetHTTPHeaderFieldsKey": currentItem.headers])
    let item = AVPlayerItem(asset: asset)
    
    var meta: [AVMutableMetadataItem] = []
    
    let title = AVMutableMetadataItem()
    title.identifier = .commonIdentifierTitle
    title.value = (currentItem.title ?? "YouTube video") as NSString
    meta.append(title)
    
    if let thumbnail = currentItem.thumbnailData {
      let artwork = AVMutableMetadataItem()
      artwork.identifier = .commonIdentifierArtwork
      artwork.value = thumbnail as NSData
      artwork.dataType = kCMMetadataBaseDataType_JPEG as String
      meta.append(artwork)
    }
    
    item.externalMetadata = meta
    
    player.replaceCurrentItem(with: item)
    player.play()
    
    NotificationCenter.default.post(name: NSNotification.Name("ShouldUpdateVideoDetails"), object: self, userInfo: ["VideoDetails": currentItem])
  }
}
