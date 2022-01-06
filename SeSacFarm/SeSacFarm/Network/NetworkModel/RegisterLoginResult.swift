//
//  RegisterResult.swift
//  SeSacFarm
//
//  Created by 천수현 on 2022/01/06.
//

import Foundation

struct RegisterLoginResult: Codable {
    let jwt: String
    let user: User
}
