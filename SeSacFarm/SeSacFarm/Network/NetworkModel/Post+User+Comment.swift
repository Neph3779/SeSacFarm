//
//  Post.swift
//  SeSacFarm
//
//  Created by 천수현 on 2022/01/05.
//

import Foundation

struct Post: Codable {
    let id: Int
    let text: String
    let user: User
    let comments: [Comment]
    let createdDate: String

    static let `default` = Post(id: 0, text: "text", user: User(id: 0, userName: "userName"),
                                comments: [], createdDate: "")

    enum CodingKeys: String, CodingKey {
        case id, text, user, comments
        case createdDate = "created_at"
    }
}

struct User: Codable {
    let id: Int
    let userName: String
    enum CodingKeys: String, CodingKey {
        case id
        case userName = "username"
    }
}

struct Comment: Codable {
}

struct DetailComment: Codable {
    let id: Int
    let user: User
    let comment: String
    let post: DetailCommentPost
}

struct DetailCommentPost: Codable {
    let id: Int
}
