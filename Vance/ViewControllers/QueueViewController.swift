//
//  QueueViewController.swift
//  Vance
//
//  Created by Egor Molchanov on 28.08.2023.
//  Copyright © 2023 Egor and the fucked up. All rights reserved.
//

import UIKit
import AVFoundation
import Combine

final class QueueViewController: UITableViewController {
    weak var model: PlayerModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Queue".localized
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Clear".localized, style: .plain, target: self, action: #selector(handleClearButtonTap(_:)))
        navigationItem.leftBarButtonItem?.isEnabled = (model?.queue.count ?? 0) > 1
        tableView.rowHeight = 96.0
        tableView.register(QueueItemTableViewCell.self, forCellReuseIdentifier: "QueueItemTableViewCell")
    }

    @objc
    private func handleClearButtonTap(_ sender: UIBarButtonItem) {
        guard let queueSize = model?.queue.count, queueSize > 1 else { return }
        model?.clearQueue()
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        navigationItem.leftBarButtonItem?.isEnabled = false
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model?.queue.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QueueItemTableViewCell", for: indexPath)
        let itemCell = cell as? QueueItemTableViewCell

        if let model {
            let item = model.queue[indexPath.row]
            itemCell?.titleLabel.text = item.title
            itemCell?.channelNameLabel.text = item.author
            itemCell?.videoMetaLabel.text = "\(item.viewCount ?? "?") \("views".localized)"
            if let data = item.thumbnailData {
                itemCell?.thumbnailImage.image = UIImage(data: data)
            }
        }

        return cell
    }
}
