//
//  QueueTableViewController.swift
//  Vance
//
//  Created by Egor Molchanov on 24.04.2024.
//  Copyright © 2024 Egor and the fucked up. All rights reserved.
//

import UIKit

final class QueueTableViewCell: UITableViewCell {

}

final class QueueTableViewController: UITableViewController {
  private lazy var addButton: UIButton = {
    var configuration = UIButton.Configuration.filled()
    configuration.title = NSLocalizedString("Add", comment: "")
    let button = UIButton(configuration: configuration)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(handleAddButtonTap(_:)), for: .touchUpInside)
    return button
  }()

  override func loadView() {
    super.loadView()
    let item = UIBarButtonItem(
      image: UIImage(systemName: "xmark.circle.fill"),
      style: .plain,
      target: self,
      action: #selector(handleCloseButtonTap(_:)))
    item.tintColor = .opaqueSeparator
    navigationItem.rightBarButtonItem = item
    tableView.addSubview(addButton)
    NSLayoutConstraint.activate([
      addButton.leadingAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.leadingAnchor, constant: 16.0),
      addButton.bottomAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.bottomAnchor, constant: -8.0),
      addButton.trailingAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.trailingAnchor, constant: -16.0)
    ])
    tableView.register(QueueTableViewCell.self, forCellReuseIdentifier: String(describing: QueueTableViewCell.self))
  }

  @objc
  private func handleCloseButtonTap(_ sender: UIBarButtonItem) {
    dismiss(animated: true)
  }

  @objc
  private func handleAddButtonTap(_ sender: UIButton) {

  }
}
