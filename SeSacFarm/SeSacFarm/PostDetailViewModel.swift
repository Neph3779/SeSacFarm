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

    init(post: Post) {
        self.post.onNext(post)
    }
}
