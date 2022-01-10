//
//  CommentModificationViewModel.swift
//  SeSacFarm
//
//  Created by 천수현 on 2022/01/10.
//

import Foundation
import RxSwift
import RxCocoa

final class CommentModificationViewModel {
    let comment: DetailComment
    let text = BehaviorSubject<String>(value: "")
    let finishButtonTapped = PublishSubject<Void>()
    let disposeBag = DisposeBag()

    init(comment: DetailComment) {
        self.comment = comment
        text.onNext(comment.comment)
    }
}
