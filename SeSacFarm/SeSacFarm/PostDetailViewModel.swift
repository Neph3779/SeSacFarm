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
    let disposeBag = DisposeBag()
    var postId = 0
    var post = BehaviorSubject<Post>(value: Post(id: 0, text: "text",
                                                 user: User(id: 0, userName: "userName"),
                                                 comments: [], createdDate: "1/1"))
    var comments = BehaviorSubject<[DetailComment]>(value: [])
    var returnKeyTapped = PublishSubject<Void>()
    var replyText = PublishSubject<String>()

    init(post: Post) {
        postId = post.id
        reloadPost()
        reloadComments()

        Observable.zip(replyText, returnKeyTapped)
            .subscribe(onNext: { comment, _ in
                self.uploadComment(comment: comment)
            })
            .disposed(by: disposeBag)
    }

    func uploadComment(comment: String) {
        SesacNetwork.shared.uploadComment(postId: postId, comment: comment) { result in
            switch result {
            case .success:
                self.reloadPost()
                self.reloadComments()
            case .failure(let error):
                print(error)
            }
        }
    }

    func reloadPost() {
        SesacNetwork.shared.getPost(postId: postId) { result in
            switch result {
            case .success(let post):
                self.post.onNext(post)
            case .failure(let error):
                print(error)
            }
        }
    }

    func reloadComments() {
        SesacNetwork.shared.getCommentsFromPost(postId: postId) { result in
            switch result {
            case .success(let comments):
                self.comments.onNext(comments)
            case .failure(let error):
                print(error) // TODO: 에러 처리
            }
        }
    }
}
