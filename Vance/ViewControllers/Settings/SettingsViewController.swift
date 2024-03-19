//
//  SettingsViewController.swift
//  Vance
//
//  Created by Egor Molchanov on 31.12.2023.
//  Copyright © 2023 Egor and the fucked up. All rights reserved.
//

import UIKit

final class SettingsViewController: UITableViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    title = NSLocalizedString("Settings", comment: "")
    tableView.register(SwitchTableViewCell.self, forCellReuseIdentifier: String(describing: SwitchTableViewCell.self))
    tableView.allowsSelection = false
  }

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch section {
    case 0:
      return NSLocalizedString("Experiments", comment: "")
    default:
      return nil
    }
  }

  override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    switch section {
    case 0:
      return NSLocalizedString("(Requires restart) Enables use of queue on video screen", comment: "")
    case 1:
      return NSLocalizedString("(Requires restart) Enables use of custom non-system player on video screen", comment: "")
    default:
      return nil
    }
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let genericCell = tableView.dequeueReusableCell(withIdentifier: String(describing: SwitchTableViewCell.self), for: indexPath)
    guard let cell = genericCell as? SwitchTableViewCell else { return genericCell }
    switch indexPath.section {
    case 0: 
      cell.title = NSLocalizedString("Is queue feature enabled", comment: "")
      cell.isOn = Settings.isQueueEnabled
      cell.isSwitchEnabled = false
      cell.delegate = self
      cell.tag = 0
    case 1:
      cell.title = NSLocalizedString("Is custom player enabled", comment: "")
      cell.isOn = Settings.isCustomPlayerEnabled
      cell.isSwitchEnabled = false
      cell.delegate = self
      cell.tag = 1
    default:
      break
    }

    return cell
  }
}

extension SettingsViewController: SwitchTableViewCellDelegate {
  func switchTableViewCell(_ cell: SwitchTableViewCell, toggledSwitchTo isOn: Bool) {
    switch cell.tag {
    case 0:
      Settings.isQueueEnabled = isOn
    case 1:
      Settings.isCustomPlayerEnabled = isOn
    default:
      break
    }
  }
}
