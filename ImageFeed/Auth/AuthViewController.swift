import UIKit
import ProgressHUD
import OSLog

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}


final class AuthViewController: UIViewController {
    private let showWebViewSegueIdentifier = "ShowWebView"
    private let logger = Logger (category: "Auth")
    weak var delegate: AuthViewControllerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
    }
    
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
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button") // 1
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button") // 2
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil) // 3
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "ypBlack") // 4
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true)
        UIBlockingProgressHUD.show()
        logger.debug("Начинаем обмен кода на токен")
        
        OAuth2Service.shared.fetchOAuthToken(code: code) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self else {
                let staticLogger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.imagefeed", category: "Auth")
                staticLogger.warning("AuthViewController был уничтожен в памяти")
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
                self.logger.error("Сетевая ошибка авторизации: \(error.localizedDescription)")
                
            }
        }
    }
    
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}
extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.imagefeed"
    init(category: String) {
        self.init(subsystem: Self.subsystem, category: category)
    }
}
