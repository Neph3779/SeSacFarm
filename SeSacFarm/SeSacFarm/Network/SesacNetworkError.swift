//
//  SesacNetworkError.swift
//  SeSacFarm
//
//  Created by 천수현 on 2022/01/06.
//

import Foundation

enum SesacNetworkError: LocalizedError, Equatable {
    case invalidResponse(statusCode: Int)
    case noAccess
    case urlConvertFailed
    case tokenExpired
    case unknownError
    case jsonConvertingFailed
    case noData

    var errorDescription: String? {
        switch self {
        case .invalidResponse(statusCode: let statusCode):
            return "잘못된 접근 (에러코드: \(statusCode.description))"
        case .noAccess:
            return "접근권한 없음"
        case .urlConvertFailed:
            return "url 변환 실패"
        case .tokenExpired:
            return "로그인 시간 만료"
        case .unknownError:
            return "알 수 없는 오류"
        case .jsonConvertingFailed:
            return "json 파일 변환 실패"
        case .noData:
            return "data 수신 실패"
        }
    }
}
