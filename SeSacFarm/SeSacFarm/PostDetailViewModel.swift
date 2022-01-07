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
    var comments = BehaviorSubject<[Comment]>(value: [])

    init(postComments: [Comment]) {
        self.comments.onNext(postComments)
    }
}
