//
//  VideoPlayerControlsViewController.swift
//  Vance
//
//  Created by Egor Molchanov on 08.08.2023.
//  Copyright © 2023 Egor and the fucked up. All rights reserved.
//

import UIKit
import AVFoundation

protocol VideoPlayerControlsDelegate: AnyObject {
    func addTapped(urlString: String?)
}

class VideoPlayerControlsViewController: UIViewController {
    weak var player: AVQueuePlayer?
    weak var delegate: VideoPlayerControlsDelegate?

    private lazy var previousButton: UIButton = {
        var configuration = UIButton.Configuration.gray()
        configuration.image = UIImage(systemName: "backward.end.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .small))
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handlePrevButtonTap(_:)), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    private lazy var nextButton: UIButton = {
        var configuration = UIButton.Configuration.gray()
        configuration.image = UIImage(systemName: "forward.end.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .small))
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleNextButtonTap(_:)), for: .touchUpInside)
        return button
    }()
    private lazy var addButton: UIButton = {
        var configuration = UIButton.Configuration.gray()
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "plus.app"), for: .normal)
        button.addTarget(self, action: #selector(handleAddButtonTap(_:)), for: .touchUpInside)
        return button
    }()

    override func loadView() {
        view = UIView()
        view.backgroundColor = .clear

        view.addSubview(previousButton)
        NSLayoutConstraint.activate([
            previousButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0),
            previousButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 8.0),
            previousButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8.0)
        ])

        view.addSubview(nextButton)
        NSLayoutConstraint.activate([
            nextButton.leadingAnchor.constraint(equalTo: previousButton.trailingAnchor, constant: 8.0),
            nextButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 8.0),
            nextButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8.0)
        ])

        view.addSubview(addButton)
        NSLayoutConstraint.activate([
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0),
            addButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 8.0),
            addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8.0)
        ])
    }

    @objc
    private func handlePrevButtonTap(_ sender: UIButton) {}

    @objc
    private func handleNextButtonTap(_ sender: UIButton) {
        player?.advanceToNextItem()
    }

    @objc func handleAddButtonTap(_ sender: UIButton) {
        let alertController = UIAlertController(
            title: "Add video to queue".localized,
            message: "Paste a link to a YouTube video here and hit the open button".localized,
            preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.clearButtonMode = .whileEditing
            textField.keyboardType = .URL
        }
        alertController.addAction(
            UIAlertAction(
                title: "Open".localized,
                style: .default,
                handler: { _ in
                    self.delegate?.addTapped(urlString: alertController.textFields!.first!.text)
                }))
        alertController.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel))
        alertController.view.tintColor = UIColor(named: "AccentColor")
        present(alertController, animated: true)
    }
}
