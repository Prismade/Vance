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
    var player: AVQueuePlayer
    var queue: [VideoDetails] = []
    var currentItemIndex: Int = -1

    private var subscriptions: Set<AnyCancellable> = []

    init() {
        self.player = AVQueuePlayer(items: [])
        self.player.audiovisualBackgroundPlaybackPolicy = .continuesIfPossible
        self.player.automaticallyWaitsToMinimizeStalling = true
        self.player.publisher(for: \.currentItem).sink { currentItem in
            guard currentItem == nil, !self.queue.isEmpty else { return }
            self.currentItemIndex += 1
            guard self.currentItemIndex < self.queue.count else { return }
            self.playCurrentItem()
        }.store(in: &subscriptions)
    }

    func addVideoToQueue(fromURL url: String) {
        guard let ytdl = YoutubeDL() else { return }

        do {
            guard let info = try ytdl.extractInfo(from: url) else { return }
            queue.append(info)
            guard queue.count == 1 else { return }
            advanceToNextItem()
        } catch let error {
            print(#file, #line, error.localizedDescription)
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
        queue.removeAll()
        currentItemIndex = -1
    }

    func advanceToNextItem() {
        guard !queue.isEmpty, self.currentItemIndex < self.queue.count - 1 else { return }
        self.currentItemIndex += 1
        playCurrentItem()
    }

    func advanceToPrevItem() {
        guard currentItemIndex > 0 else { return }
        self.currentItemIndex = currentItemIndex - 1
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
    }
}
