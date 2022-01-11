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

    static let `default` = Post(id: 0, text: "게시글", user: User(id: 0, userName: "익명"),
                                comments: [], createdDate: "") // layout이 깨지는 것을 방지하기 위해 반드시 label을 위한 default값이 필요

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
