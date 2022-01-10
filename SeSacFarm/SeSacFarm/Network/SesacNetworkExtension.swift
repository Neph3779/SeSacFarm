//
//  SesacNetworkExtension.swift
//  SeSacFarm
//
//  Created by 천수현 on 2022/01/10.
//

import Foundation

extension SesacNetwork {
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

    func makeUpdateDeletePostURLComponents(postId: Int) -> URLComponents {
        var urlComponents = defaultComponent
        urlComponents.path = "/posts/\(postId.description)"
        return urlComponents
    }

    func makeUpdateDeleteCommentURLComponents(commentId: Int) -> URLComponents {
        var urlComponents = defaultComponent
        urlComponents.path = "/comments/\(commentId.description)"
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
