import UIKit
import Kingfisher

enum ConstantProfileView {
    enum ProfileView {
        static let namePlaceholder = "Имя не указано"
        static let nicknamePlaceholder = "@неизвестный_пользователь"
        static let descriptionPlaceholder = "Профиль не заполнен"
        static let logoutImage = "Exit"
        
        static let backgroundColor = "YP Black"
        static let whiteColor = "YP White"
        static let grayColor = "YP Gray"
    }
}

final class ProfileViewController: UIViewController {
    
    // MARK: - Services
    private let profileService = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    
    // MARK: - UI Elements
    
    private let imageView: UIImageView = {
        let profileImage = UIImage(systemName: "person.circle.fill")?
            .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 70, weight: .regular, scale: .large))
        let imageView = UIImageView(image: profileImage)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 35
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = ConstantProfileView.ProfileView.namePlaceholder
        label.textColor = UIColor(named: ConstantProfileView.ProfileView.whiteColor) ?? .white
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var loginNameLabel: UILabel = {
        let label = UILabel()
        label.text = ConstantProfileView.ProfileView.nicknamePlaceholder
        label.textColor = UIColor(named: ConstantProfileView.ProfileView.grayColor) ?? .gray
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = ConstantProfileView.ProfileView.descriptionPlaceholder
        label.textColor = UIColor(named: ConstantProfileView.ProfileView.whiteColor) ?? .white
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var logoutButton: UIButton = {
        let image = UIImage(named: ConstantProfileView.ProfileView.logoutImage) ?? UIImage()
        let button = UIButton.systemButton(
            with: image,
            target: self,
            action: #selector(didTapLogoutButton)
        )
        button.tintColor = .red
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        
        if let profile = ProfileService.shared.profile {
            updateProfileDetails(profile: profile)
        }
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        
        updateAvatar()
    }
    
    // MARK: - Logic
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let imageUrl = URL(string: profileImageURL)
        else { return }
        
        let placeholderImage = UIImage(systemName: "person.circle.fill")?
            .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 70, weight: .regular, scale: .large))
        
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(
            with: imageUrl,
            placeholder: placeholderImage,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage,
                .forceRefresh
            ])
    }
    
    
    private func updateProfileDetails(profile: Profile) {
        nameLabel.text = profile.name.isEmpty
        ? ConstantProfileView.ProfileView.namePlaceholder
        : profile.name
        
        loginNameLabel.text = profile.loginName.isEmpty
        ? ConstantProfileView.ProfileView.nicknamePlaceholder
        : profile.loginName
        
        descriptionLabel.text = (profile.bio?.isEmpty ?? true)
        ? ConstantProfileView.ProfileView.descriptionPlaceholder
        : profile.bio
    }
    
    // MARK: - Actions
    @objc private func didTapLogoutButton() {
        // Логика выхода из аккаунта (будет дописана в следующих уроках)
    }
    // MARK: - Setup UI
    private func setupConstraints() {
        
        view.backgroundColor = UIColor(named: ConstantProfileView.ProfileView.backgroundColor)
        
        view.addSubview(imageView)
        view.addSubview(nameLabel)
        view.addSubview(loginNameLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(logoutButton)
        
        let size: CGFloat = 70
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 56),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            imageView.widthAnchor.constraint(equalToConstant: size),
            imageView.heightAnchor.constraint(equalToConstant: size),
            
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginNameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            
            logoutButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
}


