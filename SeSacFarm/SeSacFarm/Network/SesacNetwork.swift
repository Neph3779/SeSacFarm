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
    private var token: String?

    private var defaultComponent: URLComponents {
        var components = URLComponents()
        components.scheme = SesacAPI.scheme
        components.host = SesacAPI.host
        return components
    }

    static let shared = SesacNetwork()

    init(session: URLSession = .shared) {
        self.session = session
    }

    func setToken(token: String) {
        self.token = token
    }

    func register(userName: String, email: String, password: String) throws -> Observable<RegisterLoginResult> {
        guard let url = makeRegisterURLComponents().url else {
            throw SesacNetworkError.urlConvertFailed
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = "username=\(userName)&email=\(email)&password=\(password)"
            .data(using: .utf8, allowLossyConversion: false)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        return session.rx.response(request: request)
            .map { result -> Data in
                switch result.response.statusCode {
                case 200:
                    return result.data
                case 401:
                    self.token = nil
                    throw SesacNetworkError.tokenExpired
                default:
                    throw SesacNetworkError.invalidResponse(response: result.response)
                }
            }.decode(type: RegisterLoginResult.self, decoder: JSONDecoder())
    }

    func login(identifier: String, password: String) throws -> Observable<RegisterLoginResult> {
        guard let url = makeLoginURLComponents().url else {
            throw SesacNetworkError.urlConvertFailed
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = "identifier=\(identifier)&password=\(password)"
            .data(using: .utf8, allowLossyConversion: false)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        return session.rx.response(request: request)
            .map { result -> Data in
                switch result.response.statusCode {
                case 200:
                    return result.data
                case 401:
                    self.token = nil
                    throw SesacNetworkError.tokenExpired
                default:
                    throw SesacNetworkError.invalidResponse(response: result.response)
                }
            }.decode(type: RegisterLoginResult.self, decoder: JSONDecoder())
    }

    func getPosts() throws -> Observable<[Post]> {
        guard let url = makePostURLComponents().url else {
            throw SesacNetworkError.urlConvertFailed
        }
        guard let token = token else {
            throw SesacNetworkError.tokenExpired
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        return session.rx.response(request: request)
            .map { result -> Data in
                switch result.response.statusCode {
                case 200:
                    return result.data
                case 401:
                    self.token = nil
                    throw SesacNetworkError.tokenExpired
                default:
                    throw SesacNetworkError.invalidResponse(response: result.response)
                }
            }.decode(type: [Post].self, decoder: JSONDecoder())
    }
}

private extension SesacNetwork {
    enum SesacAPI {
        static let scheme = "http"
        static let host = "test.monocoding.com:1231"
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
}
