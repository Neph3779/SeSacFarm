//
//  PostTableViewModel.swift
//  SeSacFarm
//
//  Created by 천수현 on 2022/01/06.
//

import Foundation
import RxSwift
import RxCocoa

final class PostTableViewModel {
    var posts = PublishSubject<[Post]>()

    init() {
        do {
            _ = try SesacNetwork.shared.getPosts()
                .bind(to: posts)
        } catch SesacNetworkError.tokenExpired {

        } catch SesacNetworkError.invalidResponse(let response) {
            print(response)
        } catch {

        }
    }
}
