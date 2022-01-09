//
//  PostDetailViewModel.swift
//  SeSacFarm
//
//  Created by 천수현 on 2022/01/07.
//

import Foundation
import RxSwift
import RxCocoa

final class PostDetailViewModel {
    var post = BehaviorSubject<Post>(value: Post(id: 0, text: "",
                                                 user: User(id: 0, userName: ""),
                                                 comments: [], createdDate: ""))
    var comments = BehaviorSubject<[DetailComment]>(value: [])

    init(post: Post) {
        self.post.onNext(post)
        SesacNetwork.shared.getCommentsFromPost(postId: post.id) { result in
            switch result {
            case .success(let comments):
                self.comments.onNext(comments)
            case .failure(let error):
                print(error) // TODO: 에러 처리
            }
        }
    }
}
