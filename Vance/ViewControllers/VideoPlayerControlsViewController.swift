//
//  VideoPlayerControlsViewController.swift
//  Vance
//
//  Created by Egor Molchanov on 08.08.2023.
//  Copyright © 2023 Egor and the fucked up. All rights reserved.
//

import UIKit
import AVFoundation

final class VideoPlayerControlsViewController: UIViewController {
    weak var model: PlayerModel?

    private lazy var previousButton: UIButton = {
        var configuration = UIButton.Configuration.gray()
        configuration.image = UIImage(systemName: "backward.end.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .small))
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handlePrevButtonTap(_:)), for: .touchUpInside)
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 40.0)
        ])
        return button
    }()
    private lazy var nextButton: UIButton = {
        var configuration = UIButton.Configuration.gray()
        configuration.image = UIImage(systemName: "forward.end.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .small))
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleNextButtonTap(_:)), for: .touchUpInside)
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 40.0)
        ])
        return button
    }()
    private lazy var queueButton: UIButton = {
        var configuration = UIButton.Configuration.gray()
        configuration.title = "Queue".localized
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handlePlaylistButtonTap(_:)), for: .touchUpInside)
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
    private lazy var contentStack: UIStackView = {
        let view = UIStackView(arrangedSubviews: [previousButton, nextButton, queueButton, addButton])
        view.spacing = 8.0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func loadView() {
        view = UIView()
        view.backgroundColor = .clear

        view.addSubview(contentStack)
        NSLayoutConstraint.activate([
            contentStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0),
            contentStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 8.0),
            contentStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0),
            contentStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 8.0)
        ])

        NSLayoutConstraint.activate([
            previousButton.widthAnchor.constraint(equalTo: addButton.widthAnchor, multiplier: 1.0)
        ])
    }

    @objc
    private func handlePrevButtonTap(_ sender: UIButton) {
        model?.advanceToPrevItem()
    }

    @objc
    private func handleNextButtonTap(_ sender: UIButton) {
        model?.advanceToNextItem()
    }

    @objc
    func handlePlaylistButtonTap(_ sender: UIButton) {
        let queueViewController = QueueViewController(style: .plain)
        queueViewController.model = model
        let navigationController = UINavigationController(rootViewController: queueViewController)
        navigationController.modalPresentationStyle = .pageSheet
        if let presentationController = navigationController.sheetPresentationController {
            presentationController.detents = [.medium(), .large()]
            presentationController.prefersGrabberVisible = true
        }
        present(navigationController, animated: true)
    }

    @objc func handleAddButtonTap(_ sender: UIButton) {
        let alertController = UIAlertController(
            title: "Add video to queue".localized,
            message: "Paste a link to a YouTube video here and hit the add button".localized,
            preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.clearButtonMode = .whileEditing
            textField.keyboardType = .URL
            textField.placeholder = "https://youtu.be/..."
        }
        alertController.addAction(
            UIAlertAction(
                title: "Add".localized,
                style: .default,
                handler: { _ in
                    guard let urlText = alertController.textFields!.first!.text else { return }
                    self.model?.addVideoToQueue(fromURL: urlText)
                }))
        alertController.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel))
        alertController.view.tintColor = UIColor(named: "AccentColor")
        present(alertController, animated: true)
    }
}
