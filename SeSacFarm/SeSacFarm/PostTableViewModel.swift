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
        SesacNetwork.shared.getPosts { result in
            switch result {
            case .success(let resultPosts):
                self.posts.onNext(resultPosts)
            case .failure(let error):
                print(error)
            }
        }
    }
}
