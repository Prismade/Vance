//
//  QueueTableViewCell.swift
//  Vance
//
//  Created by Egor Molchanov on 04.05.2024.
//  Copyright © 2024 Egor and the fucked up. All rights reserved.
//

import UIKit

final class QueueTableViewCell: UITableViewCell {
  private lazy var thumbnailImageView: UIImageView = {
    let view = UIImageView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .systemFont(ofSize: 15.0)
    label.numberOfLines = 2
    return label
  }()
  private lazy var subtitleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .systemFont(ofSize: 12.0)
    label.numberOfLines = 1
    return label
  }()
  private lazy var infoLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .systemFont(ofSize: 12.0)
    label.numberOfLines = 1
    return label
  }()
  private lazy var stack: UIStackView = {
    let view = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, infoLabel])
    view.translatesAutoresizingMaskIntoConstraints = false
    view.axis = .vertical
    view.spacing = 8.0
    return view
  }()

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("Not implemented")
  }

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.addSubview(thumbnailImageView)
    NSLayoutConstraint.activate([
      thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
      thumbnailImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.0),
      thumbnailImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.0),
      thumbnailImageView.heightAnchor.constraint(equalToConstant: 80.0),
      thumbnailImageView.widthAnchor.constraint(equalTo: thumbnailImageView.heightAnchor, multiplier: 16.0 / 9.0)
    ])

    contentView.addSubview(stack)
    NSLayoutConstraint.activate([
      stack.leadingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor, constant: 8.0),
      stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.0),
      stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0),
      stack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8.0)
    ])
  }

  func update(withVideo video: Video) {
    titleLabel.text = video.info.title
    subtitleLabel.text = video.channel.name

    let df = DateFormatter()
    df.dateFormat = "YYYYMMdd"
    if let viewsCount = video.info.viewsCount, let timestamp = video.info.uploadDate, let date = df.date(from: timestamp) {
      let uploadDate = RelativeDateTimeFormatter().localizedString(for: date, relativeTo: Date())
      infoLabel.text = String(format: "%@ %@ • %@", viewsCount.formattedUsingAbbrevation, NSLocalizedString("views", comment: ""), uploadDate)
    }
  }
}
