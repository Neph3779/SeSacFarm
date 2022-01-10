//
//  CommentModificationViewController.swift
//  SeSacFarm
//
//  Created by 천수현 on 2022/01/10.
//

import UIKit
import RxSwift
import RxCocoa

final class CommentModificationViewController: UIViewController {
    private let commentModificationViewModel: CommentModificationViewModel
    private let disposeBag = DisposeBag()
    private let commentTextView = UITextView()

    init(comment: DetailComment) {
        commentModificationViewModel = CommentModificationViewModel(comment: comment)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        commentModificationViewModel = CommentModificationViewModel(
            comment: DetailComment(id: 0, user: User(id: 0, userName: ""), comment: "", post: DetailCommentPost(id: 0))
        )
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "댓글 수정"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "완료", image: nil, primaryAction: nil, menu: nil)
        setPostTextView()
        bind()
    }

    private func setPostTextView() {
        commentTextView.isEditable = true
        commentTextView.font = UIFont.systemFont(ofSize: 20)
        commentTextView.layer.borderColor = UIColor.black.cgColor
        commentTextView.layer.borderWidth = 1
        view.addSubview(commentTextView)
        commentTextView.snp.makeConstraints { textView in
            textView.leading.trailing.top.equalTo(view.safeAreaLayoutGuide).inset(20)
            textView.height.equalTo(view.snp.height).multipliedBy(0.4)
        }
    }

    private func bind() {
        navigationItem.rightBarButtonItem?.rx.tap
            .subscribe(onNext: {
                SesacNetwork.shared
                    .updateComment(commentId: self.commentModificationViewModel.comment.id,
                                   postId: self.commentModificationViewModel.comment.post.id,
                                   text: self.commentTextView.text!,
                                   completion: self.uploadUpdateCompletion(_:))
            })
            .disposed(by: disposeBag)

        commentModificationViewModel.text
            .bind(to: commentTextView.rx.text)
            .disposed(by: disposeBag)
    }

    private func uploadUpdateCompletion(_ result: Result<Void, SesacNetworkError>) {
        switch result {
        case .success:
            DispatchQueue.main.async { self.navigationController?.popViewController(animated: true) }
        case .failure(let error):
            print(error)
        }
    }
}
