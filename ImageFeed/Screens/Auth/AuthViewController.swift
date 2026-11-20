import UIKit
import ProgressHUD
import OSLog

// MARK: - AuthViewControllerDelegate
protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}


final class AuthViewController: UIViewController {
    
    // MARK: - Private Properties
    private let showWebViewSegueIdentifier = "ShowWebView"
    private let logger = Logger (category: "Auth")
    private let oauth2Service = OAuth2Service.shared
    
    // MARK: - Public Properties
    weak var delegate: AuthViewControllerDelegate?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else {
                assertionFailure("Failed to prepare for \(showWebViewSegueIdentifier)")
                return
            }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    // MARK: - Setup UI
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "ypBlack")
    }
}

// MARK: - WebViewViewControllerDelegate
extension AuthViewController: WebViewViewControllerDelegate {
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: false)
        UIBlockingProgressHUD.show()
        logger.debug("Начинаем обмен кода на токен")
        
        OAuth2Service.shared.fetchOAuthToken(code) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self else {
                let staticLogger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.imagefeed", category: "Auth")
                staticLogger.warning("[AuthViewController.webViewViewController]: LifecycleError — AuthViewController был уничтожен в памяти")
                return
            }
            
            self.logger.debug("Получен результат сетевого запроса: \(String(describing: result))")
            
            switch result {
            case .success(let token):
                self.logger.info("Токен успешно получен")
                OAuth2TokenStorage.shared.token = token
                
                self.logger.debug("Вызываем метод делегата didAuthenticate")
                self.delegate?.didAuthenticate(self)
                
            case .failure(let error):
                self.logger.error("[OAuth2Service.fetchOAuthToken]: AuthError — Сетевая ошибка авторизации: \(error.localizedDescription)")
                self.showAuthErrorAlert()
                
            }
        }
    }
    
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}

// MARK: - Alerts
extension AuthViewController {
    func showAuthErrorAlert() {
        let alertController = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "Ок", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
// MARK: - Logger Extension
extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.imagefeed"
    init(category: String) {
        self.init(subsystem: Self.subsystem, category: category)
    }
}
