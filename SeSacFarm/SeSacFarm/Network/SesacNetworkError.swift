//
//  SesacNetworkError.swift
//  SeSacFarm
//
//  Created by 천수현 on 2022/01/06.
//

import Foundation

enum SesacNetworkError: Error {
    case invalidResponse(statusCode: Int)
    case noAccess
    case urlConvertFailed
    case tokenExpired
    case unknownError
    case jsonConvertingFailed
}
