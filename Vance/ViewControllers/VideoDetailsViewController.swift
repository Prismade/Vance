//
//  VideoDetailsViewController.swift
//  Vance
//
//  Created by Egor Molchanov on 08.08.2023.
//  Copyright © 2023 Egor and the fucked up. All rights reserved.
//

import UIKit

final class VideoDetailsTableViewCell: UITableViewCell {
  private lazy var stack: UIStackView = {
    let view = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
    view.translatesAutoresizingMaskIntoConstraints = false
    view.axis = .vertical
    view.spacing = 8.0
    return view
  }()
  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.numberOfLines = 2
    label.font = .systemFont(ofSize: 17.0, weight: .heavy)
    label.textColor = .label
    return label
  }()
  private lazy var subtitleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.numberOfLines = 1
    label.font = .systemFont(ofSize: 11.0)
    label.textColor = .secondaryLabel
    return label
  }()

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError()
  }

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    contentView.addSubview(stack)
    NSLayoutConstraint.activate([
      stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
      stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20.0),
      stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0),
      stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20.0)
    ])
  }

  func configure(withTitle title: String?, subtitle: String?) {
    titleLabel.text = title
    subtitleLabel.text = subtitle
  }
}

final class ChannelTableViewCell: UITableViewCell {
  private lazy var avatarImageView: UIImageView = {
    let view = UIImageView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.layer.cornerRadius = 20.0
    return view
  }()
  private lazy var stack: UIStackView = {
    let view = UIStackView(arrangedSubviews: [titleLabel, followersCountLabel])
    view.translatesAutoresizingMaskIntoConstraints = false
    view.axis = .vertical
    return view
  }()
  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.numberOfLines = 1
    label.font = .systemFont(ofSize: 14.0)
    label.textColor = .label
    return label
  }()
  private lazy var followersCountLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.numberOfLines = 1
    label.font = .systemFont(ofSize: 11.0)
    label.textColor = .secondaryLabel
    return label
  }()

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError()
  }

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.addSubview(avatarImageView)
    NSLayoutConstraint.activate([
      avatarImageView.widthAnchor.constraint(equalToConstant: 40.0),
      avatarImageView.heightAnchor.constraint(equalToConstant: 40.0),
      avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
      avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.0),
      avatarImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.0)
    ])

    addSubview(stack)
    NSLayoutConstraint.activate([
      stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      stack.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 16.0),
      stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0),
    ])
  }

  func configure(title: String?, followers: String?) {
    titleLabel.text = title
    followersCountLabel.text = followers
  }
}

final class VideoDetailsViewController: UITableViewController {
  var video: Video?
  weak var model: PlayerModel?

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.separatorStyle = .none
    NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateVideoDetailsNotification(_:)), name: NSNotification.Name("ShouldUpdateVideoDetails"), object: nil)
    tableView.register(VideoDetailsTableViewCell.self, forCellReuseIdentifier: String(describing: VideoDetailsTableViewCell.self))
    tableView.register(ChannelTableViewCell.self, forCellReuseIdentifier: String(describing: ChannelTableViewCell.self))
  }

  @objc
  private func handleUpdateVideoDetailsNotification(_ notification: Notification) {
    video = notification.userInfo?["Video"] as? Video
    tableView.reloadData()
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 2
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch indexPath.row {
    case 0:
      let genericCell = tableView.dequeueReusableCell(withIdentifier: String(describing: VideoDetailsTableViewCell.self), for: indexPath)
      guard let cell = genericCell as? VideoDetailsTableViewCell else { return genericCell }
      if let video {
        var subtitle: String?
        let df = DateFormatter()
        df.dateFormat = "YYYYMMdd"
        if let viewsCount = video.info.viewsCount, let timestamp = video.info.uploadDate, let date = df.date(from: timestamp) {
          let uploadDate = RelativeDateTimeFormatter().localizedString(for: date, relativeTo: Date())

          subtitle = String(format: "%@ %@ • %@", viewsCount.formattedUsingAbbrevation, NSLocalizedString("views", comment: ""), uploadDate)
        }

        cell.configure(withTitle: video.info.title, subtitle: subtitle)
      } else {
        cell.configure(withTitle: nil, subtitle: nil)
      }
      return cell
    case 1:
      let genericCell = tableView.dequeueReusableCell(withIdentifier: String(describing: ChannelTableViewCell.self), for: indexPath)
      guard let cell = genericCell as? ChannelTableViewCell else { return genericCell }
      if let video {
        cell.configure(title: video.channel.name, followers: video.channel.followersCount?.formattedUsingAbbrevation)
      } else {
        cell.configure(title: nil, followers: nil)
      }
      return cell
    default:
      return UITableViewCell()
    }
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
}
