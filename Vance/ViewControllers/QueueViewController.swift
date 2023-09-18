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
  private lazy var addButton: UIButton = {
    var configuration = UIButton.Configuration.filled()
    configuration.baseBackgroundColor = .accent
    configuration.baseForegroundColor = .white
    configuration.title = NSLocalizedString("Add", comment: "")
    let button = UIButton(configuration: configuration)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(handleAddButtonTap(_:)), for: .touchUpInside)
    return button
  }()

  override func loadView() {
    super.loadView()
    view.addSubview(addButton)
    NSLayoutConstraint.activate([
      addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0),
      addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0),
      addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
    ])
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = NSLocalizedString("Queue", comment: "")
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Clear", comment: ""), style: .plain, target: self, action: #selector(handleClearButtonTap(_:)))
    navigationItem.leftBarButtonItem?.isEnabled = (model?.queue.count ?? 0) > 1
    tableView.rowHeight = 96.0
    tableView.register(QueueItemTableViewCell.self, forCellReuseIdentifier: "QueueItemTableViewCell")
  }

  override func viewDidLayoutSubviews() {
    tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: addButton.frame.size.height + 16.0, right: 0.0)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    setCurrentVideoSelection()
  }

  private func setCurrentVideoSelection() {
    guard let row = model?.currentItemIndex else { return }
    tableView.selectRow(at: IndexPath(row: row, section: 0), animated: true, scrollPosition: .none)
  }

  @objc
  private func handleClearButtonTap(_ sender: UIBarButtonItem) {
    guard let queueSize = model?.queue.count, queueSize > 1 else { return }
    model?.clearQueue()
    tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    navigationItem.leftBarButtonItem?.isEnabled = false
    setCurrentVideoSelection()
  }

  @objc
  func handleAddButtonTap(_ sender: UIButton) {
    let alertController = UIAlertController(
      title: NSLocalizedString("Add video to queue", comment: ""),
      message: NSLocalizedString("Paste a link to a YouTube video here and hit the add button", comment: ""),
      preferredStyle: .alert)
    alertController.addTextField { textField in
      textField.clearButtonMode = .whileEditing
      textField.keyboardType = .URL
      textField.placeholder = "https://youtu.be/..."
    }
    alertController.addAction(
      UIAlertAction(
        title: NSLocalizedString("Add", comment: ""),
        style: .default,
        handler: { _ in
          guard let urlText = alertController.textFields?.first?.text, !urlText.isEmpty else { return }
          self.model?.addVideoToQueue(fromURL: urlText)
          self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
          self.navigationItem.leftBarButtonItem?.isEnabled = (self.model?.queue.count ?? 0) > 1
          self.setCurrentVideoSelection()
        }))
    alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
    alertController.view.tintColor = UIColor(named: "AccentColor")
    present(alertController, animated: true)
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
      itemCell?.videoMetaLabel.text = "\(item.viewCount ?? "?") \(NSLocalizedString("Views", comment: ""))"
      if let data = item.thumbnailData {
        itemCell?.activityIndicator.stopAnimating()
        itemCell?.thumbnailImage.image = UIImage(data: data)
      } else {
        Task { [weak self] in
          await item.downloadThumbnail()
          guard let data = item.thumbnailData, let cellToUpdate = self?.tableView.cellForRow(at: indexPath) as? QueueItemTableViewCell else { return }
          await MainActor.run {
            cellToUpdate.activityIndicator.stopAnimating()
            cellToUpdate.thumbnailImage.image = UIImage(data: data)
          }
        }
      }
    }

    return cell
  }

  // MARK: - Table view delegate

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let index = indexPath.row
    guard let currentItemIndex = model?.currentItemIndex, index != currentItemIndex else { return }
    model?.advanceToItem(at: index)
  }
}
