//
//  SwitchTableViewCell.swift
//  Vance
//
//  Created by Egor Molchanov on 19.03.2024.
//  Copyright © 2024 Egor and the fucked up. All rights reserved.
//

import UIKit

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
    `switch`.onTintColor = UIColor.accent
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
