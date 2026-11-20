import Foundation
import WebKit
import UIKit
import Kingfisher

final class ProfileLogoutService {
    
    // MARK: - Static Properties
    static let shared = ProfileLogoutService()
    
    // MARK: - Initializers
    private init() {}
    
    // MARK: - Public Methods
    func logout() {
        cleanToken()
        cleanCookies()
        cleanServicesData()
        switchToSplashViewController()
    }
    
    // MARK: - Private Methods
    private func cleanToken() {
        OAuth2TokenStorage.shared.token = nil
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func cleanServicesData() {
        ProfileService.shared.cleanProfile()
        ProfileImageService.shared.cleanAvatar()
        ImagesListService.shared.cleanPhotos()
        ImageCache.default.clearMemoryCache()
        ImageCache.default.clearDiskCache()
    }
    
    private func switchToSplashViewController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        window.rootViewController = SplashViewController()
        window.makeKeyAndVisible()
    }
}

