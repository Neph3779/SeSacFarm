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
        guard let url = makePostURLComponents().url else {
            return completion(.failure(.urlConvertFailed))
        }
        guard let token = token else {
            return completion(.failure(.tokenExpired))
        }

        let request = makeGETRequest(url: url, token: token)

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

    func getCommentsFromPost(postId: Int, completion: @escaping (Result<[DetailComment], SesacNetworkError>) -> Void) {
        guard let url = makeCommentsURLCompoenents(postId: postId).url else {
            return completion(.failure(.urlConvertFailed))
        }
        guard let token = token else {
            return completion(.failure(.tokenExpired))
        }

        let request = makeGETRequest(url: url, token: token)

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

    func makePasswordChangeURLComponents() -> URLComponents {
        var urlComponents = defaultComponent
        urlComponents.path = "/custom/change-password"
        return urlComponents
    }

    func makePostURLComponents() -> URLComponents {
        var urlComponents = defaultComponent
        urlComponents.path = "/posts"
        return urlComponents
    }

    func makeCommentsURLCompoenents(postId: Int) -> URLComponents {
        var urlComponents = defaultComponent
        urlComponents.path = "/comments"
        urlComponents.queryItems = [URLQueryItem(name: "post", value: postId.description)]
        return urlComponents
    }

    func makeGETRequest(url: URL, token: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        return request
    }
}
