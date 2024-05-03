//
//  QueueTableViewController.swift
//  Vance
//
//  Created by Egor Molchanov on 24.04.2024.
//  Copyright © 2024 Egor and the fucked up. All rights reserved.
//

import UIKit

final class QueueTableViewController: UITableViewController {
  private lazy var addButton: UIButton = {
    var configuration = UIButton.Configuration.filled()
    configuration.title = NSLocalizedString("Add", comment: "")
    let button = UIButton(configuration: configuration)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(handleAddButtonTap(_:)), for: .touchUpInside)
    return button
  }()
  private lazy var debugButton: UIButton = {
    var configuration = UIButton.Configuration.filled()
    configuration.title = NSLocalizedString("Debug", comment: "")
    let button = UIButton(configuration: configuration)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(handleAddButtonTap(_:)), for: .touchUpInside)
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
      title: NSLocalizedString("Clear", comment: ""),
      style: .plain,
      target: self,
      action: #selector(handleClearButtonTap(_:)))
    item.tintColor = .opaqueSeparator
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

  @objc
  private func handleAddButtonTap(_ sender: UIButton) {

  }

  @objc
  private func handleDebugButtonTap(_ sender: UIButton) {
    
  }

  @objc
  private func handleClearButtonTap(_ sender: UIBarButtonItem) {

  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 0
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: QueueTableViewCell.self), for: indexPath)
    return cell
  }
}
