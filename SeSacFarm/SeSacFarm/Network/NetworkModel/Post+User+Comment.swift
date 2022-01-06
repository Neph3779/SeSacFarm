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
    let comments: [Comment]
    let createdDate: Date

    enum CodingKeys: String, CodingKey {
        case id, text, comments
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
    let userId: Int
    enum CodingKeys: String, CodingKey {
        case userId = "user"
    }
}