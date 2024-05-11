//
//  PlayerQueue.swift
//  Vance
//
//  Created by Egor Molchanov on 12.05.2024.
//  Copyright © 2024 Egor and the fucked up. All rights reserved.
//

import AVFoundation

protocol PlayerQueueDelegate: AnyObject {
  func playerQueueDidUpdate(videos: [Video], currentVideoIndex index: Int)
}

final class PlayerQueue {
  typealias QueueItem = (video: Video, item: AVPlayerItem)

  weak var player: AVQueuePlayer?
  weak var delegate: PlayerQueueDelegate?
  var history: [QueueItem] = []
  var queue: [QueueItem] = []

  init(player: AVQueuePlayer?) {
    self.player = player
    NotificationCenter.default.addObserver(self, selector: #selector(advanceToNextItem), name: AVPlayerItem.didPlayToEndTimeNotification, object: nil)
  }

  func updateAudioSessionActivityIfNeeded() {
    let session = AVAudioSession.sharedInstance()
    do {
      try session.setActive(true)
    } catch {
      print(error.localizedDescription)
    }
  }

  func createDataForViewController() -> (videos: [Video], index: Int) {
    let videos = history.map(\.video) + queue.map(\.video)
    let index = if let currentVideo = queue.first?.video {
      videos.firstIndex(of: currentVideo) ?? 0
    } else if !history.isEmpty {
      videos.count - 1
    } else {
      0
    }
    return (videos: videos, index: index)
  }

  func notifyDelegate() {
    let (videos, currentVideoIndex) = createDataForViewController()
    delegate?.playerQueueDidUpdate(videos: videos, currentVideoIndex: currentVideoIndex)
  }

  func open(video: Video) {
    guard let item = video.playerItem else { return }
    clear()
    queue.append((video, item))
    updateAudioSessionActivityIfNeeded()
    player?.insert(item, after: nil)
    player?.play()
    notifyDelegate()
    NotificationCenter.default.post(name: Notification.Name("ShouldUpdateVideoDetails"), object: self, userInfo: ["Video": video])
  }

  func append(video: Video) {
    guard let item = video.playerItem else { return }
    queue.append((video, item))
    player?.insert(item, after: player?.items().last)
    notifyDelegate()

    guard queue.count == 1 else { return }
    updateAudioSessionActivityIfNeeded()
    player?.play()
    NotificationCenter.default.post(name: Notification.Name("ShouldUpdateVideoDetails"), object: self, userInfo: ["Video": video])
  }

  func clear() {
    history.removeAll()
    queue.removeAll()
    player?.removeAllItems()
    notifyDelegate()
  }

  @objc
  func advanceToNextItem() {
    history.append(queue.removeFirst())
    notifyDelegate()
  }

  func forward() {
    guard queue.count > 1 else { return }
    advanceToNextItem()
    player?.advanceToNextItem()
    notifyDelegate()
    guard let video = queue.first else { return }
    NotificationCenter.default.post(name: Notification.Name("ShouldUpdateVideoDetails"), object: self, userInfo: ["Video": video.video])
  }

  func backward() {
    guard !history.isEmpty else { return }
    let currPair = queue.first
    let prevPair = history.removeLast()
    queue.insert(prevPair, at: 0)
    player?.insert(prevPair.item, after: currPair?.item)
    player?.advanceToNextItem()
    notifyDelegate()
    NotificationCenter.default.post(name: Notification.Name("ShouldUpdateVideoDetails"), object: self, userInfo: ["Video": prevPair.video])
    guard let currPair else { return }
    player?.insert(currPair.item, after: prevPair.item)
  }
}
