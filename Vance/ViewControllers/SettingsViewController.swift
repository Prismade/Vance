//
//  SettingsViewController.swift
//  Vance
//
//  Created by Egor Molchanov on 31.12.2023.
//  Copyright © 2023 Egor and the fucked up. All rights reserved.
//

import UIKit

struct Settings {
  static var isQueueEnabled: Bool {
    get {
      UserDefaults.standard.bool(forKey: "IsQueueEnabled")
    }
    set {
      UserDefaults.standard.set(newValue, forKey: "IsQueueEnabled")
    }
  }
  static var isCustomPlayerEnabled: Bool {
    get {
      UserDefaults.standard.bool(forKey: "IsCustomPlayerEnabled")
    }
    set {
      UserDefaults.standard.setValue(newValue, forKey: "IsCustomPlayerEnabled")
    }
  }
}

protocol SwitchTableViewCellDelegate: AnyObject {
  func switchTableViewCell(_ cell: SwitchTableViewCell, toggledSwitchTo isOn: Bool)
}

final class SwitchTableViewCell: UITableViewCell {
  weak var delegate: SwitchTableViewCellDelegate?

  var title: String? {
    didSet {
      titleLabel.text = title
    }
  }
  var isOn: Bool = false {
    didSet { 
      `switch`.isOn = isOn
    }
  }
  var isSwitchEnabled: Bool = true {
    didSet {
      `switch`.isEnabled = isSwitchEnabled
    }
  }

  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.numberOfLines = 1
    return label
  }()
  private lazy var `switch`: UISwitch = {
    let control = UISwitch()
    control.translatesAutoresizingMaskIntoConstraints = false
    return control
  }()

  @available(*, unavailable)
  required init?(coder: NSCoder) { fatalError() }

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    contentView.addSubview(titleLabel)
    contentView.addSubview(`switch`)

    NSLayoutConstraint.activate([
      titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
      titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.0),
      titleLabel.trailingAnchor.constraint(greaterThanOrEqualTo: `switch`.leadingAnchor, constant: -8.0),
      titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.0),
      `switch`.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      `switch`.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0)
    ])

    `switch`.addTarget(self, action: #selector(handleChangeOfValue), for: .touchUpInside)
    `switch`.onTintColor = UIColor(named: "AccentColor")
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    delegate = nil
  }

  @objc
  func handleChangeOfValue(_ sender: UISwitch) {
    delegate?.switchTableViewCell(self, toggledSwitchTo: sender.isOn)
  }
}

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
