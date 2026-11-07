import Foundation

// MARK: - Models
struct ProfileImage: Codable {
    let small: String
    let medium: String
    let large: String
    
    private enum CodingKeys: String, CodingKey {
        case small
        case medium
        case large
    }
}

struct UserResult: Codable {
    let profileImage: ProfileImage
}
// MARK: - ProfileImageService
final class ProfileImageService {
    
    // MARK: - Static Properties
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    static let shared = ProfileImageService()
    private init() {}
    
    private(set) var avatarURL: String?
    private var task: URLSessionTask?
    
    // MARK: - Public Methods
    func fetchProfileImageURL(username: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        
        guard let token = OAuth2TokenStorage.shared.token else {
            print("[ProfileImageService.fetchProfileImageURL]: AuthError — Отсутствует токен авторизации в хранилище")
            completion(.failure(NSError(domain: "ProfileImageService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Authorization token missing"])))
            return
        }
        
        guard let request = makeProfileImageRequest(username: username, token: token) else {
            print("[ProfileImageService.makeProfileImageRequest]: RequestError — Не удалось создать URLRequest для пользователя \(username)")
            completion(.failure(URLError(.badURL)))
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in

            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let result):
                    self.avatarURL = result.profileImage.medium
                    completion(.success(result.profileImage.small))
                    
                    NotificationCenter.default
                        .post(
                            name: ProfileImageService.didChangeNotification,
                            object: self,
                            userInfo: ["URL": self.avatarURL ?? ""]
                        )
                    
                case .failure(let error):
                    print("[ProfileImageService.fetchProfileImageURL]: NetworkError — \(error.localizedDescription)")
                    completion(.failure(error))
                }
                
                self.task = nil
            }
        }
        
        self.task = task
        task.resume()
    }
        // MARK: - Private Methods
        private func makeProfileImageRequest(username: String, token: String) -> URLRequest? {
            guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
                return nil
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            return request
        }
    }
