import Foundation

// MARK: - NetworkError
enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidRequest
    case decodingError(Error)
}

// MARK: - URLSession Data Tasks
extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        
        let task = dataTask(with: request) { data, response, error in
            
            print("===== URLSession callback =====")
            
            if let response = response as? HTTPURLResponse {
                print("STATUS =", response.statusCode)
            }
            
            if let data = data,
               let body = String(data: data, encoding: .utf8) {
                print("BODY =", body)
            }
            
            if let error = error {
                print("[URLSession.data]: NetworkError — urlRequestError: \(error.localizedDescription)")
            }
            
            if let data = data,
               let response = response as? HTTPURLResponse {
                
                if 200..<300 ~= response.statusCode {
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                    print("[URLSession.data]: HTTPError — statusCode: \(response.statusCode)")
                                       fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(response.statusCode)))
                }
                
            } else if let error = error {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
            } else {
                print("[URLSession.data]: NetworkError — Данные и ответ от сервера отсутствуют")
                               fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
            }
        }
        
        return task
    }
}

// MARK: - URLSession Decoding Tasks
extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let task = data(for: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Полученные данные: \(jsonString)")
                }
                do {
                    let decodedObject = try decoder.decode(T.self, from: data)
                    completion(.success(decodedObject))
                } catch {
                    if let decodingError = error as? DecodingError {
                        print("[URLSession.objectTask]: DecodingError — \(error.localizedDescription), Данные: \(String(data: data, encoding: .utf8) ?? "")")
                    } else {
                        print("[URLSession.objectTask]: DecodingError — \(error.localizedDescription), Данные: \(String(data: data, encoding: .utf8) ?? "")")
                           completion(.failure(error))
                    }
                    completion(.failure(error))
                }
                
            case .failure(let error):
                print("[URLSession.objectTask]: NetworkError — Ошибка запроса: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        
        return task
    }
}
