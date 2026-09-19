//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Daria on 12.06.2026.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    // MARK: - Constants
    
    static let imageName = "profileImage"
    static let name = "Екатерина Новикова"
    static let nickname = "@ekaterina_nov"
    static let descriptionText = "Hello, world!"
    static let exitButton = "Exit"
    
    // MARK: - UI Elements
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage (named: ProfileViewController.imageName)
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 35
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel ()
        label.text = ProfileViewController.name
        label.textColor = .ypWhite
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let nickNameLabel: UILabel = {
        let label2 = UILabel ()
        label2.text = ProfileViewController.nickname
        label2.textColor = .ypWhite
        label2.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        
        label2.translatesAutoresizingMaskIntoConstraints = false
        
        return label2
    }()
    
    private let descriptionLabel: UILabel = {
        let label3 = UILabel ()
        label3.text = ProfileViewController.descriptionText
        label3.textColor = .ypWhite
        label3.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        
        label3.translatesAutoresizingMaskIntoConstraints = false
        
        return label3
    } ()
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton()
        let image = UIImage (named: ProfileViewController.exitButton)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }
    
    // MARK: - Setup UI
    private func setupViews() {
        view.backgroundColor = .ypBlack
        
        view.addSubview(imageView)
        view.addSubview(nameLabel)
        view.addSubview(nickNameLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(logoutButton)
    }
    
    private func setupConstraints() {
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.heightAnchor.constraint(equalToConstant: 70),
            
            nameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            
            nickNameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            nickNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: nickNameLabel.bottomAnchor, constant: 8),
            
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            logoutButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
}
    


