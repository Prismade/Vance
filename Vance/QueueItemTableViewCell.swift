//
//  QueueItemTableViewCell.swift
//  Vance
//
//  Created by Egor Molchanov on 28.08.2023.
//  Copyright © 2023 Egor and the fucked up. All rights reserved.
//

import UIKit

final class QueueItemTableViewCell: UITableViewCell {
    lazy var thumbnailImage: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 8.0
        view.clipsToBounds = true
        return view
    }()
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 14.0)
        return label
    }()
    lazy var channelNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 12.0)
        label.textColor = .secondaryLabel
        return label
    }()
    lazy var videoMetaLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 12.0)
        label.textColor = .tertiaryLabel
        return label
    }()
    lazy var container: UIStackView = {
        let view = UIStackView(arrangedSubviews: [titleLabel, channelNameLabel, videoMetaLabel])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = 6.0
        return view
    }()

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(thumbnailImage)
        NSLayoutConstraint.activate([
            thumbnailImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
            thumbnailImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.0),
            thumbnailImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.0),
            thumbnailImage.widthAnchor.constraint(equalToConstant: 144.0),
            thumbnailImage.heightAnchor.constraint(equalToConstant: 80.0)
        ])

        contentView.addSubview(container)
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: thumbnailImage.trailingAnchor, constant: 16.0),
            container.topAnchor.constraint(equalTo: thumbnailImage.topAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0)
        ])
    }
}
