import UIKit

final class SplashViewController: UIViewController {
    
    // MARK: - Properties
    private let storage = OAuth2TokenStorage()
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private var isFirstLaunch = true
    private let profileService = ProfileService.shared
    
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard isFirstLaunch else { return }
        isFirstLaunch = false
        
        if storage.token != nil {
            switchToTabBarController()
        } else {
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    // MARK: - Private Methods
    private func checkAuthStatus() {
        if storage.token != nil {
            switchToTabBarController ()
        } else {
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    
    private func switchToTabBarController() {
        guard let window = view.window else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
    
    private func fetchProfile(token: String) {
         UIBlockingProgressHUD.show()
         profileService.fetchProfile(token) { [weak self] result in
             UIBlockingProgressHUD.dismiss()

             guard let self = self else { return }

             switch result {
             case .success:
                self.switchToTabBarController()

             case let .failure (error):
                 print(error)
                 // TODO [Sprint 11] Покажите ошибку получения профиля
                 break
             }
         }
     }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers.first as? AuthViewController
            else {
                assertionFailure("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")
                return
            }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
              
               guard let token = storage.token else {
                   return
               }
               
               fetchProfile(token: token)
           }
 }
