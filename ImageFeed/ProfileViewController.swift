//import UIKit
//import Kingfisher
//
//final class ProfileViewController: UIViewController {
//    
//// MARK: - Services
//    private let profileService = ProfileService.shared
//    private var profileImageServiceObserver: NSObjectProtocol?
//    
//    // MARK: - Constants
//    
//    static let exitButton = "Exit"
//    
//    @IBOutlet private var avatarImageView: UIImageView!
//    
//    // MARK: - UI Elements
//    
//    private let imageView: UIImageView = {
//        let imageView = UIImageView()
//        
//        imageView.contentMode = .scaleAspectFill
//        imageView.clipsToBounds = true
//        imageView.layer.cornerRadius = 35
//        
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        return imageView
//    }()
//    
//    private let nameLabel: UILabel = {
//        let label = UILabel ()
//        label.textColor = .ypWhite
//        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
//        
//        label.translatesAutoresizingMaskIntoConstraints = false
//        
//        return label
//    }()
//    
//    private let loginNameLabel: UILabel = {
//        let label2 = UILabel ()
//        label2.textColor = .ypWhite
//        label2.font = UIFont.systemFont(ofSize: 13, weight: .regular)
//        
//        label2.translatesAutoresizingMaskIntoConstraints = false
//        
//        return label2
//    }()
//    
//    private let descriptionLabel: UILabel = {
//        let label3 = UILabel ()
//        label3.textColor = .ypWhite
//        label3.font = UIFont.systemFont(ofSize: 13, weight: .regular)
//        
//        label3.translatesAutoresizingMaskIntoConstraints = false
//        
//        return label3
//    } ()
//    
//    private lazy var logoutButton: UIButton = {
//        let button = UIButton()
//        let image = UIImage (named: ProfileViewController.exitButton)
//        button.setImage(image, for: .normal)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
//        return button
//    }()
//
//    
//    // MARK: - Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupViews()
//        setupConstraints()
//   
//        profileImageServiceObserver = NotificationCenter.default    // 2
//            .addObserver(
//                forName: ProfileImageService.didChangeNotification, // 3
//                object: nil,                                        // 4
//                queue: .main                                        // 5
//            ) { [weak self] _ in
//                guard let self = self else { return }
//                self.updateAvatar()                                 // 6
//            }
//        updateAvatar()                                              // 7
//    }
//    
//    // MARK: - Logic
//    private func updateAvatar() {
//        guard
//            let profileImageURL = ProfileImageService.shared.avatarURL,
//            let imageUrl = URL(string: profileImageURL)
//        else { return }
//
//        print("imageUrl: \(imageUrl)")
//
//        let placeholderImage = UIImage(systemName: "person.circle.fill")?
//            .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
//            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 70, weight: .regular, scale: .large))
//
//        let processor = RoundCornerImageProcessor(cornerRadius: 35) // Радиус для круга
//        avatarImageView.kf.indicatorType = .activity
//        avatarImageView.kf.setImage(
//            with: imageUrl,
//            placeholder: placeholderImage,
//            options: [
//                .processor(processor),
//                .scaleFactor(UIScreen.main.scale), // Учитываем масштаб экрана
//                .cacheOriginalImage, // Кэшируем оригинал
//                .forceRefresh // Игнорируем кэш, чтобы обновить
//            ]) { result in
//
//                switch result {
//                    // Успешная загрузка
//                case .success(let value):
//                    // Картинка
//                    print(value.image)
//
//                    // Откуда картинка загружена:
//                    // - .none — из сети.
//                    // - .memory — из кэша оперативной памяти.
//                    // - .disk — из дискового кэша.
//                    print(value.cacheType)
//
//                    // Информация об источнике.
//                    print(value.source)
//
//                    // В случае ошибки
//                case .failure(let error):
//                    print(error)
//                }
//            }
//    }
//    
//    
//    private func updateProfileDetails(profile: Profile) {
//        nameLabel.text = profile.name.isEmpty
//            ? "Имя не указано"
//            : profile.name
//        
//        loginNameLabel.text = profile.loginName.isEmpty
//            ? "@неизвестный_пользователь"
//            : profile.loginName
//        
//        descriptionLabel.text = (profile.bio?.isEmpty ?? true)
//            ? "Профиль не заполнен"
//            : profile.bio
//    }
//    @objc private func didTapLogoutButton() {
//        // Логика выхода из аккаунта (будет дописана в следующих уроках)
//    }
//    // MARK: - Setup UI
//    private func setupViews() {
//        view.backgroundColor = .ypBlack
//        
//        view.addSubview(imageView)
//        view.addSubview(nameLabel)
//        view.addSubview(loginNameLabel)
//        view.addSubview(descriptionLabel)
//        view.addSubview(logoutButton)
//    }
//    
//    private func setupConstraints() {
//        
//        NSLayoutConstraint.activate([
//            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
//            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
//            imageView.widthAnchor.constraint(equalToConstant: 70),
//            imageView.heightAnchor.constraint(equalToConstant: 70),
//            
//            nameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
//            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
//            
//            loginNameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
//            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
//            
//            descriptionLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
//            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
//            
//            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
//            logoutButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
//            logoutButton.widthAnchor.constraint(equalToConstant: 44),
//            logoutButton.heightAnchor.constraint(equalToConstant: 44)
//        ])
//    }
//}


import UIKit
import Kingfisher

// MARK: - Constants

enum ConstantProfileView {
    enum ProfileView {
        static let namePlaceholder = "Имя не указано"
        static let nicknamePlaceholder = "@неизвестный_пользователь"
        static let descriptionPlaceholder = "Профиль не заполнен"
        static let logoutImage = "LogOut"
        
        static let backgroundColor = "YP Black (iOS)"
        static let whiteColor = "YP White (iOS)"
        static let grayColor = "YP Gray (iOS)"
    }
}

// MARK: - ProfileViewController

final class ProfileViewController: UIViewController {
    
    // MARK: - Private UI Properties
    
    private lazy var avatarImageView: UIImageView = {
        let profileImage = UIImage(systemName: "person.circle.fill")?
            .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 70, weight: .regular, scale: .large))
        let imageView = UIImageView(image: profileImage)
        imageView.contentMode = .scaleAspectFill
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
    
    private var profileImageServiceObserver: NSObjectProtocol?

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
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

    // MARK: - Actions
    
    @objc private func didTapLogoutButton() {
    }

    // MARK: - Private Methods
    
    private func setupUI() {
        view.backgroundColor = UIColor(named: ConstantProfileView.ProfileView.backgroundColor)
        
        // Добавляем сабвью на экран
        view.addSubview(avatarImageView)
        view.addSubview(nameLabel)
        view.addSubview(loginNameLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(logoutButton)
        
        let size: CGFloat = 70
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 56),
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            avatarImageView.widthAnchor.constraint(equalToConstant: size),
            avatarImageView.heightAnchor.constraint(equalToConstant: size),
            
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginNameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }

    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let imageUrl = URL(string: profileImageURL)
        else { return }

        let placeholderImage = UIImage(systemName: "person.circle.fill")?
            .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 70, weight: .regular, scale: .large))

        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        avatarImageView.kf.indicatorType = .activity
        avatarImageView.kf.setImage(
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
        
        updateAvatar()
    }
}
