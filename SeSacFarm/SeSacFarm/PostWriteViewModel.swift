//
//  PostWriteViewModel.swift
//  SeSacFarm
//
//  Created by 천수현 on 2022/01/10.
//

import Foundation
import RxSwift
import RxCocoa

final class PostWriteViewModel {
    let post: Post?
    let text = BehaviorSubject<String>(value: "")
    let finishButtonTapped = PublishSubject<Void>()
    let disposeBag = DisposeBag()

    init(post: Post? = nil) {
        if let post = post {
            self.post = post
            text.onNext(post.text)
        } else {
            self.post = nil
        }
    }
}
