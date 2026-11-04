import Foundation

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Int
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private let urlSession = URLSession.shared
    private let dataStorage = OAuth2TokenStorage.shared
    
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private(set) var authToken: String? {
        get {
            return dataStorage.token
        }
        set {
            dataStorage.token = newValue
        }
    }
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    private init() {}
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard lastCode != code else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        task?.cancel()
        lastCode = code
        guard
            let request = makeOAuthTokenRequest(with: code)
        else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        let task =  self.object(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                guard let self = self else { return }

                switch result {
                case .success(let body):
                    let authToken = body.accessToken
                    self.authToken = authToken 
                    completion(.success(authToken))

                    self.task = nil
                    self.lastCode = nil

                case .failure(let error):
                    print("[fetchOAuthToken]: Ошибка запроса: \(error.localizedDescription)")
                    completion(.failure(error)) // ошибка

                    self.task = nil
                    self.lastCode = nil
                }
            }
        }
            self.task = task
            task.resume()
    }

    
    private func makeOAuthTokenRequest(with code: String) -> URLRequest? {
        guard let url = URL(string: "https://unsplash.com/oauth/token")
        else {
            assertionFailure("Failed to create URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        var bodyComponents = URLComponents()
        bodyComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        request.httpBody = bodyComponents.query?.data(using: .utf8)
        return request
    }
}
extension OAuth2Service {
    private func object(for request: URLRequest, completion: @escaping (Result<OAuthTokenResponseBody, Error>) -> Void) -> URLSessionTask {
//        let decoder = JSONDecoder()
        return urlSession.data(for: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    let body = try self.decoder.decode(OAuthTokenResponseBody.self, from: data)
                    completion(.success(body))
                }
                catch {
                    completion(.failure(NetworkError.decodingError(error)))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}



//final class OAuth2Service {
//    private let urlSession = URLSession.shared              // 1
//    private var task: URLSessionTask?                       // 2
//    private var lastCode: String?
// 3
//    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
//        assert(Thread.isMainThread)                         // 4
//        if task != nil {                                    // 5
//            if lastCode != code {                           // 6
//                task?.cancel()                              // 7
//            } else {
//                completion(.failure(AuthServiceError.invalidRequest))
//                return                                      // 8
//            }
//        } else {
//            if lastCode == code {                           // 9
//                completion(.failure(AuthServiceError.invalidRequest))
//                return
//            }
//        }
//        lastCode = code                                     // 10
//        guard
//            let request = makeOAuthTokenRequest(code: code)           // 11
//        else {
//            completion(.failure(AuthServiceError.invalidRequest))
//            return
//        }
//        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
//            DispatchQueue.main.async {                      // 12
//                // TODO: разбора ответа, из 10 спринта      // 13
//                self?.task = nil                            // 14
//                self?.lastCode = nil                        // 15
//            }
//        }
//        self.task = task                                    // 16
//        task.resume()                                       // 17
//    }
//
//    private func makeOAuthTokenRequest(code: String) -> URLRequest? {  // 18
//        guard
//            var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token")
//        else {
//            assertionFailure("Failed to create URL")
//            return nil
//        }
//
//        urlComponents.queryItems = [
//            URLQueryItem(name: "client_id", value: Constants.accessKey),
//            URLQueryItem(name: "client_secret", value: Constants.secretKey),
//            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
//            URLQueryItem(name: "code", value: code),
//            URLQueryItem(name: "grant_type", value: "authorization_code"),
//        ]
//
//        guard let authTokenUrl = urlComponents.url else {
//            return nil
//        }
//
//        var request = URLRequest(url: authTokenUrl)
//        request.httpMethod = "POST"
//        return request
//    }
//}
