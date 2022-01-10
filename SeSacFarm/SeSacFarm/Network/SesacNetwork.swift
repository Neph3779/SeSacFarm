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
    private(set) var token: String?
    private(set) var id: Int?
    var defaultComponent: URLComponents {
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

    func register(userName: String, email: String, password: String, completion: @escaping (Result<RegisterLoginResult, SesacNetworkError>) -> Void) {
        guard let url = makeRegisterURLComponents().url else {
            return completion(.failure(.urlConvertFailed))
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = "username=\(userName)&email=\(email)&password=\(password)"
            .data(using: .utf8, allowLossyConversion: false)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        session.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse,
                  error == nil else {
                      return completion(.failure(.unknownError))
                  }

            guard (200...299).contains(httpResponse.statusCode) else {
                return completion(.failure(.invalidResponse(statusCode: httpResponse.statusCode)))
            }

            guard let data = data else {
                return completion(.failure(.noAccess))
            }

            do {
                let result = try JSONDecoder().decode(RegisterLoginResult.self, from: data)
                self.token = result.jwt
                self.id = result.user.id
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
            guard let httpResponse = response as? HTTPURLResponse,
                  error == nil else {
                      return completion(.failure(.unknownError))
                  }

            guard (200...299).contains(httpResponse.statusCode) else {
                return completion(.failure(.invalidResponse(statusCode: httpResponse.statusCode)))
            }

            guard let data = data else {
                return completion(.failure(.noAccess))
            }

            do {
                let result = try JSONDecoder().decode(RegisterLoginResult.self, from: data)
                self.token = result.jwt
                self.id = result.user.id
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

    func updatePost(postId: Int, text: String, completion: @escaping (Result<Void, SesacNetworkError>) -> Void) {
        guard let url = makeUpdateDeletePostURLComponents(postId: postId).url else {
            return completion(.failure(.urlConvertFailed))
        }
        guard let token = token else {
            return completion(.failure(.tokenExpired))
        }
        var request = makeRequest(method: "PUT", url: url, token: token)
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

    func updateComment(commentId: Int, postId: Int, text: String, completion: @escaping (Result<Void, SesacNetworkError>) -> Void) {
        guard let url = makeUpdateDeleteCommentURLComponents(commentId: commentId).url else {
            return completion(.failure(.urlConvertFailed))
        }
        guard let token = token else {
            return completion(.failure(.tokenExpired))
        }
        var request = makeRequest(method: "PUT", url: url, token: token)
        request.httpBody = "comment=\(text)&post=\(postId.description)"
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

    func deletePost(postId: Int, completion: @escaping (Result<Void, SesacNetworkError>) -> Void) {
        guard let url = makeUpdateDeletePostURLComponents(postId: postId).url else {
            return completion(.failure(.urlConvertFailed))
        }
        guard let token = token else {
            return completion(.failure(.tokenExpired))
        }
        let request = makeRequest(method: "DELETE", url: url, token: token)

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

    func deleteComment(commentId: Int, completion: @escaping (Result<Void, SesacNetworkError>) -> Void) {
        guard let url = makeUpdateDeleteCommentURLComponents(commentId: commentId).url else {
            return completion(.failure(.urlConvertFailed))
        }
        guard let token = token else {
            return completion(.failure(.tokenExpired))
        }
        let request = makeRequest(method: "DELETE", url: url, token: token)

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

