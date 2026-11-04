import UIKit

final class SplashViewController: UIViewController {
    
    // MARK: - Properties
    private let storage = OAuth2TokenStorage.shared
//    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private var isFirstLaunch = true
    private let profileService = ProfileService.shared
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "splash_screen_logo")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard isFirstLaunch else { return }
        isFirstLaunch = false
        
        checkAuthStatus()
        
//        if storage.token != nil {
//            switchToTabBarController()
//        } else {
//            presentAuthViewController()
//        }
    }
    // MARK: - Private Methods
    private func setupView() {
        view.backgroundColor = UIColor(named: "YP Black (iOS)")
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0)
        ])
    }
    
    private func checkAuthStatus() {
        if storage.token != nil {
            switchToTabBarController ()
        } else {
            presentAuthViewController()
        }
    }
    
    private func presentAuthViewController() {
           guard let authViewController = UIStoryboard(name: "Main", bundle: .main)
               .instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
               assertionFailure("Failed to instantiate AuthViewController")
               return
           }
           
           authViewController.delegate = self
           authViewController.modalPresentationStyle = .fullScreen
           present(authViewController, animated: true, completion: nil)
       }
    

    
    private func switchToTabBarController() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate else {
            assertionFailure("Не удалось найти SceneDelegate для смены экрана")
            return
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        sceneDelegate.window?.rootViewController = tabBarController
    }
    
    private func fetchProfile(token: String) {
         UIBlockingProgressHUD.show()
         profileService.fetchProfile(token) { [weak self] result in
             UIBlockingProgressHUD.dismiss()

             guard let self = self else { return }

             switch result {
             case let .success(profile):
                 ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in }
                 self.switchToTabBarController()

             case let .failure(error):
                 print(error)
                 break
             }
         }
     }
}


extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {

        vc.dismiss(animated: false) { [weak self] in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                guard let token = self.storage.token else { return }
                self.fetchProfile(token: token)
            }
        }
    }
}
