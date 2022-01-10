//
//  SesacNetwork.swift
//  SeSacFarm
//
//  Created by 천수현 on 2022/01/05.
//

import Foundation
import RxSwift
import RxCocoa

final class SesacNetwork {
    private let session: URLSession // Unit test 진행하게 될 때 대비 (의존성 문제 해결)
    var token: String?

    private var defaultComponent: URLComponents {
        var components = URLComponents()
        components.scheme = SesacAPI.scheme
        components.host = SesacAPI.host
        components.port = 1231
        return components
    }

    static let shared = SesacNetwork()

    init(session: URLSession = .shared) {
        self.session = session
    }

    func setToken(token: String) {
        self.token = token
    }

    func register(userName: String, email: String, password: String, completion: @escaping (Result<RegisterLoginResult, SesacNetworkError>) -> Void) {
        guard let url = makeRegisterURLComponents().url else {
            completion(.failure(.urlConvertFailed))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = "username=\(userName)&email=\(email)&password=\(password)"
            .data(using: .utf8, allowLossyConversion: false)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        session.dataTask(with: request) { data, response, error in
            guard error == nil else {
                return completion(.failure(.unknownError))
            }

            guard let httpResponse = response as? HTTPURLResponse else { return }

            guard (200...299).contains(httpResponse.statusCode) else {
                return completion(.failure(.invalidResponse(statusCode: httpResponse.statusCode)))
            }

            guard let data = data else {
                return completion(.failure(.noAccess))
            }

            do {
                let result = try JSONDecoder().decode(RegisterLoginResult.self, from: data)
                self.token = result.jwt
                completion(.success(result))
            } catch {
                completion(.failure(.jsonConvertingFailed))
            }
        }.resume()
    }

    func login(identifier: String, password: String, completion: @escaping (Result<RegisterLoginResult, SesacNetworkError>) -> Void) {
        guard let url = makeLoginURLComponents().url else {
            return completion(.failure(.urlConvertFailed))
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = "identifier=\(identifier)&password=\(password)"
            .data(using: .utf8, allowLossyConversion: false)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        session.dataTask(with: request) { data, response, error in
            guard error == nil else {
                return completion(.failure(.unknownError))
            }

            guard let httpResponse = response as? HTTPURLResponse else { return }

            guard (200...299).contains(httpResponse.statusCode) else {
                return completion(.failure(.invalidResponse(statusCode: httpResponse.statusCode)))
            }

            guard let data = data else {
                return completion(.failure(.noAccess))
            }

            do {
                let result = try JSONDecoder().decode(RegisterLoginResult.self, from: data)
                self.token = result.jwt
                completion(.success(result))
            } catch {
                completion(.failure(.jsonConvertingFailed))
            }
        }.resume()
    }

    func getPosts(completion: @escaping (Result<[Post], SesacNetworkError>) -> Void) {
        guard let url = makeGetPostURLComponents().url else {
            return completion(.failure(.urlConvertFailed))
        }
        guard let token = token else {
            return completion(.failure(.tokenExpired))
        }

        let request = makeRequest(method: "GET", url: url, token: token)

        session.dataTask(with: request) { data, response, error in
            guard error == nil, let httpResponse = response as? HTTPURLResponse else {
                return completion(.failure(.unknownError))
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                if httpResponse.statusCode == 401 {
                    return completion(.failure(.tokenExpired))
                }
                return completion(.failure(.invalidResponse(statusCode: httpResponse.statusCode)))
            }

            guard let data = data else {
                return completion(.failure(.noAccess))
            }

            do {
                let result = try JSONDecoder().decode([Post].self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(.jsonConvertingFailed))
            }
        }.resume()
    }

    func getPost(postId: Int, completion: @escaping (Result<Post, SesacNetworkError>) -> Void) {
        guard let url = makeGetPostURLComponents(postId: postId).url else {
            return completion(.failure(.urlConvertFailed))
        }
        guard let token = token else {
            return completion(.failure(.tokenExpired))
        }

        let request = makeRequest(method: "GET", url: url, token: token)

        session.dataTask(with: request) { data, response, error in
            guard error == nil, let httpResponse = response as? HTTPURLResponse else {
                return completion(.failure(.unknownError))
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                if httpResponse.statusCode == 401 {
                    return completion(.failure(.tokenExpired))
                }
                return completion(.failure(.invalidResponse(statusCode: httpResponse.statusCode)))
            }

            guard let data = data else {
                return completion(.failure(.noAccess))
            }

            do {
                let result = try JSONDecoder().decode(Post.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(.jsonConvertingFailed))
            }
        }.resume()
    }

    func getCommentsFromPost(postId: Int, completion: @escaping (Result<[DetailComment], SesacNetworkError>) -> Void) {
        guard let url = makeGetCommentsURLCompoenents(postId: postId).url else {
            return completion(.failure(.urlConvertFailed))
        }
        guard let token = token else {
            return completion(.failure(.tokenExpired))
        }

        let request = makeRequest(method: "GET", url: url, token: token)

        session.dataTask(with: request) { data, response, error in
            guard error == nil, let httpResponse = response as? HTTPURLResponse else {
                return completion(.failure(.unknownError))
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                if httpResponse.statusCode == 401 {
                    return completion(.failure(.tokenExpired))
                }
                return completion(.failure(.invalidResponse(statusCode: httpResponse.statusCode)))
            }

            guard let data = data else {
                return completion(.failure(.noAccess))
            }

            do {
                let result = try JSONDecoder().decode([DetailComment].self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(.jsonConvertingFailed))
            }
        }.resume()
    }

    func uploadPost(text: String, completion: @escaping (Result<Void, SesacNetworkError>) -> Void) {
        guard let url = makeUploadPostURLComponents().url else {
            return completion(.failure(.urlConvertFailed))
        }
        guard let token = token else {
            return completion(.failure(.tokenExpired))
        }
        var request = makeRequest(method: "POST", url: url, token: token)
        request.httpBody = "text=\(text)"
            .data(using: .utf8, allowLossyConversion: false)

        session.dataTask(with: request) { _, response, error in
            guard error == nil, let httpResponse = response as? HTTPURLResponse else {
                return completion(.failure(.unknownError))
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                if httpResponse.statusCode == 401 {
                    return completion(.failure(.tokenExpired))
                }
                return completion(.failure(.invalidResponse(statusCode: httpResponse.statusCode)))
            }

            completion(.success(()))
        }.resume()
    }

    func uploadComment(postId: Int, comment: String, completion: @escaping (Result<Void, SesacNetworkError>) -> Void) {
        guard let url = makeUploadCommentURLComponents().url else {
            return completion(.failure(.urlConvertFailed))
        }
        guard let token = token else {
            return completion(.failure(.tokenExpired))
        }

        var request = makeRequest(method: "POST", url: url, token: token)
        request.httpBody = "comment=\(comment)&post=\(postId.description)"
            .data(using: .utf8, allowLossyConversion: false)

        session.dataTask(with: request) { _, response, error in
            guard error == nil, let httpResponse = response as? HTTPURLResponse else {
                return completion(.failure(.unknownError))
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                if httpResponse.statusCode == 401 {
                    return completion(.failure(.tokenExpired))
                }
                return completion(.failure(.invalidResponse(statusCode: httpResponse.statusCode)))
            }

            completion(.success(()))
        }.resume()
    }
}

private extension SesacNetwork {
    enum SesacAPI {
        static let scheme = "http"
        static let host = "test.monocoding.com"
    }

    func makeRegisterURLComponents() -> URLComponents {
        var urlComponents = defaultComponent
        urlComponents.path = "/auth/local/register"
        return urlComponents
    }

    func makeLoginURLComponents() -> URLComponents {
        var urlComponents = defaultComponent
        urlComponents.path = "/auth/local"
        return urlComponents
    }

    func makeGetPostURLComponents(postId: Int? = nil) -> URLComponents {
        var urlComponents = defaultComponent
        if let postId = postId {
            urlComponents.path = "/posts/\(postId)"
        } else {
            urlComponents.path = "/posts"
            urlComponents.queryItems = [URLQueryItem(name: "_sort", value: "created_at:desc")]
        }
        return urlComponents
    }

    func makeGetCommentsURLCompoenents(postId: Int) -> URLComponents {
        var urlComponents = defaultComponent
        urlComponents.path = "/comments"
        urlComponents.queryItems = [URLQueryItem(name: "post", value: postId.description)]
        return urlComponents
    }

    func makeUploadPostURLComponents() -> URLComponents {
        var urlComponents = defaultComponent
        urlComponents.path = "/posts"
        return urlComponents
    }

    func makeUploadCommentURLComponents() -> URLComponents {
        var urlComponents = defaultComponent
        urlComponents.path = "/comments"
        return urlComponents
    }

    func makeRequest(method: String, url: URL, token: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        return request
    }
}
