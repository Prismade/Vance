//
//  VideoDetailsViewController.swift
//  Vance
//
//  Created by Egor Molchanov on 08.08.2023.
//  Copyright © 2023 Egor and the fucked up. All rights reserved.
//

import UIKit

final class VideoDetailsViewController: UIViewController {
  weak var model: PlayerModel?
  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.numberOfLines = 0
    label.font = .systemFont(ofSize: 17.0, weight: .heavy)
    label.textColor = .label
    return label
  }()
  private lazy var viewsLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.numberOfLines = 0
    label.font = .systemFont(ofSize: 11.0)
    label.textColor = .secondaryLabel
    return label
  }()
  private lazy var channelLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.numberOfLines = 0
    label.font = .systemFont(ofSize: 14.0)
    label.textColor = .label
    return label
  }()
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  override func loadView() {
    view = UIView()
    view.backgroundColor = .clear
    
    view.addSubview(titleLabel)
    NSLayoutConstraint.activate([
      titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0),
      titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 8.0),
      titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0)
    ])
    
    view.addSubview(viewsLabel)
    NSLayoutConstraint.activate([
      viewsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0),
      viewsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8.0),
      viewsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0)
    ])
    
    view.addSubview(channelLabel)
    NSLayoutConstraint.activate([
      channelLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0),
      channelLabel.topAnchor.constraint(equalTo: viewsLabel.bottomAnchor, constant: 8.0),
      channelLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0),
      channelLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8.0)
    ])
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateVideoDetailsNotification(_:)), name: NSNotification.Name("ShouldUpdateVideoDetails"), object: nil)
  }
  
  func update(details: VideoDetails) {
    titleLabel.text = details.title
    titleLabel.isHidden = details.title == nil
    
    viewsLabel.text = "\(details.viewCount ?? "") \(NSLocalizedString("Views", comment: ""))"
    viewsLabel.isHidden = details.viewCount == nil
    
    channelLabel.text = "👤 \(details.author ?? "")"
    channelLabel.isHidden = details.author == nil
  }
  
  @objc
  private func handleUpdateVideoDetailsNotification(_ notification: Notification) {
    guard let details = notification.userInfo?["VideoDetails"] as? VideoDetails else { return }
    update(details: details)
  }
}
