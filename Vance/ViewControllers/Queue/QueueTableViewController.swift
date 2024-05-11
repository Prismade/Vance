//
//  QueueTableViewController.swift
//  Vance
//
//  Created by Egor Molchanov on 24.04.2024.
//  Copyright © 2024 Egor and the fucked up. All rights reserved.
//

import UIKit

final class QueueTableViewController: UITableViewController {
  weak var model: PlayerModel?
  private var videos: [Video] = []
  private var currentVideoIndex: Int = 0

  private lazy var addButton: UIButton = {
    var configuration = UIButton.Configuration.filled()
    configuration.title = NSLocalizedString("add", comment: "")
    let button = UIButton(configuration: configuration)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(handleAddButtonTap(_:)), for: .touchUpInside)
    return button
  }()
  private lazy var debugButton: UIButton = {
    var configuration = UIButton.Configuration.filled()
    configuration.title = NSLocalizedString("debug", comment: "")
    let button = UIButton(configuration: configuration)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(handleDebugButtonTap(_:)), for: .touchUpInside)
    return button
  }()
  private lazy var buttonsStack: UIStackView = {
    var arrangedSubviews = [addButton]
    if CommandLine.arguments.contains("-DDEBUG") {
      arrangedSubviews.insert(debugButton, at: 0)
    }
    let view = UIStackView(arrangedSubviews: arrangedSubviews)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.axis = .vertical
    view.spacing = 8.0
    return view
  }()

  override func loadView() {
    super.loadView()
    let item = UIBarButtonItem(
      title: NSLocalizedString("clear", comment: ""),
      style: .plain,
      target: self,
      action: #selector(handleClearButtonTap(_:)))
    navigationItem.leftBarButtonItem = item
    tableView.addSubview(buttonsStack)
    NSLayoutConstraint.activate([
      buttonsStack.leadingAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.leadingAnchor, constant: 16.0),
      buttonsStack.bottomAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.bottomAnchor, constant: -8.0),
      buttonsStack.trailingAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.trailingAnchor, constant: -16.0)
    ])
    tableView.rowHeight = 96.0
    tableView.register(QueueTableViewCell.self, forCellReuseIdentifier: String(describing: QueueTableViewCell.self))
  }

  override func viewDidLayoutSubviews() {
    tableView.contentInset = UIEdgeInsets(
      top: 0.0,
      left: 0.0,
      bottom: buttonsStack.bounds.size.height + 8.0 + view.safeAreaInsets.bottom,
      right: 0.0)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    guard let (videos, index) = model?.queueViewControllerData() else { return }
    updateTableView(withVideos: videos, currentVideoIndex: index)
  }

  private func updateTableView(withVideos videos: [Video], currentVideoIndex index: Int) {
    self.videos = videos
    self.currentVideoIndex = index
    tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    if videos.isEmpty {
      navigationItem.leftBarButtonItem?.isEnabled = false
    } else {
      navigationItem.leftBarButtonItem?.isEnabled = true
      tableView.selectRow(at: IndexPath(row: currentVideoIndex, section: 0), animated: true, scrollPosition: .middle)
    }
  }

  @objc
  private func handleAddButtonTap(_ sender: UIButton) {
    let alertController = UIAlertController(
      title: NSLocalizedString("add-video-title", comment: ""),
      message: NSLocalizedString("add-video-message", comment: ""),
      preferredStyle: .alert)
    alertController.addTextField { textField in
      textField.clearButtonMode = .whileEditing
      textField.keyboardType = .URL
      textField.placeholder = "https://youtu.be/..."
    }
    alertController.addAction(
      UIAlertAction(
        title: NSLocalizedString("add", comment: ""),
        style: .default,
        handler: { [weak self] _ in
          guard
            let self,
            let urlText = alertController.textFields?.first?.text,
            !urlText.isEmpty
          else {
            return
          }
          Task {
            await self.model?.addVideoToQueue(from: urlText)
          }
        }))
    alertController.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel))
    alertController.view.tintColor = UIColor(named: "AccentColor")
    present(alertController, animated: true)
  }

  @objc
  private func handleDebugButtonTap(_ sender: UIButton) {
    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    alertController.addAction(
      UIAlertAction(
        title: NSLocalizedString("add-test-video", comment: ""),
        style: .default,
        handler: { [weak self] _ in
          guard let self else { return }
          let testVideo = Video.sample
          Task {
            await self.model?.addVideoToQueue(testVideo)
          }
        }))
    alertController.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel))
    alertController.view.tintColor = UIColor(named: "AccentColor")
    present(alertController, animated: true)
  }

  @objc
  private func handleClearButtonTap(_ sender: UIBarButtonItem) {
    model?.clear()
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return videos.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let genericCell = tableView.dequeueReusableCell(withIdentifier: String(describing: QueueTableViewCell.self), for: indexPath)
    guard let cell = genericCell as? QueueTableViewCell else { return genericCell }
    cell.update(withVideo: videos[indexPath.row])
    return cell
  }
}

extension QueueTableViewController: PlayerQueueDelegate {
  func playerQueueDidUpdate(videos: [Video], currentVideoIndex index: Int) {
    updateTableView(withVideos: videos, currentVideoIndex: index)
  }
}
