import Foundation
import CoreGraphics

// MARK: - Модели данных

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

struct PhotoResult: Decodable {
    let id: String
    let createdAt: String?
    let width: Int
    let height: Int
    let description: String?
    let likedByUser: Bool
    let urls: UrlsResult
}

struct UrlsResult: Decodable {
    let thumb: String
    let full: String
}

// MARK: - ImagesListService

final class ImagesListService {
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private(set) var photos: [Photo] = []
    
    private var lastLoadedPage: Int?
    private var currentTask: URLSessionTask?
    private let urlSession = URLSession.shared
    private let dateFormatter = ISO8601DateFormatter()
    
    private init() {}
    
    func fetchPhotosNextPage() {
        print("DEBUG 1: fetchPhotosNextPage вызван")
        assert(Thread.isMainThread)
        guard currentTask == nil else {
            print("DEBUG 2: запрос уже идёт")
            return
        }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        guard let request = makePhotosRequest(page: nextPage) else {
            print("DEBUG 3: makePhotosRequest вернул nil (скорее всего, нет токена)")
            return
        }
        
        print("DEBUG 4: отправляем запрос на \(request.url?.absoluteString ?? "")")
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }
            self.currentTask = nil
            
            switch result {
            case .success(let photoResults):
                print("DEBUG 5: успешно получено фотографий — \(photoResults.count)")
                let newPhotos = photoResults.map { result in
                    Photo(
                        id: result.id,
                        size: CGSize(width: result.width, height: result.height),
                        createdAt: result.createdAt.flatMap { self.dateFormatter.date(from: $0) },
                        welcomeDescription: result.description,
                        thumbImageURL: result.urls.thumb,
                        largeImageURL: result.urls.full,
                        isLiked: result.likedByUser
                    )
                }
                
                let uniqueNewPhotos = newPhotos.filter { newPhoto in
                    !self.photos.contains(where: { $0.id == newPhoto.id })
                }
                
                self.photos.append(contentsOf: uniqueNewPhotos)
                self.lastLoadedPage = nextPage
                
                NotificationCenter.default.post(
                    name: ImagesListService.didChangeNotification,
                    object: self,
                    userInfo: ["photos": self.photos]
                )
                
            case .failure(let error):
                print("DEBUG 6: ошибка загрузки — \(error.localizedDescription)")
            }
        }
        
        currentTask = task
        task.resume()
    }
    func cleanPhotos() {
        photos = []
        lastLoadedPage = nil
        currentTask?.cancel()
        currentTask = nil
    }
    // MARK: - Приватные методы

    private func makePhotosRequest(page: Int) -> URLRequest? {
        guard let token = OAuth2TokenStorage.shared.token else {
            print("DEBUG: OAuth2TokenStorage.shared.token == NIL!")
            return nil
        }
        print("DEBUG: Токен успешно прочитан из Keychain: \(token.prefix(6))...")
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.unsplash.com"
        components.path = "/photos"
        components.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "10")
        ]
        
        guard let url = components.url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}

// MARK: - Сетевой запрос для смены лайка
extension ImagesListService {
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard let request = makeLikeRequest(photoId: photoId, isLike: isLike) else {
            assertionFailure("Failed to create like URLRequest")
            return
        }
        
        let task = urlSession.data(for: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    let photo = self.photos[index]
                    let newPhoto = Photo(
                        id: photo.id,
                        size: photo.size,
                        createdAt: photo.createdAt,
                        welcomeDescription: photo.welcomeDescription,
                        thumbImageURL: photo.thumbImageURL,
                        largeImageURL: photo.largeImageURL,
                        isLiked: !photo.isLiked
                    )
                    self.photos = self.photos.withReplaced(itemAt: index, newValue: newPhoto)
                }
                completion(.success(()))
                
            case .failure(let error):
                print("[ImagesListService]: Error changing like - \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    private func makeLikeRequest(photoId: String, isLike: Bool) -> URLRequest? {
        guard let token = OAuth2TokenStorage.shared.token else {
            assertionFailure("Missing OAuth2 token")
            return nil
        }
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.unsplash.com"
        components.path = "/photos/\(photoId)/like"

        guard let url = components.url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
// MARK: - Расширение для безопасной замены элемента по индексу
extension Array {
    func withReplaced(itemAt index: Int, newValue: Element) -> [Element] {
        var copy = self
        copy[index] = newValue
        return copy
    }
}
