//
//  PostWriteViewController.swift
//  SeSacFarm
//
//  Created by 천수현 on 2022/01/05.
//

import UIKit
import RxSwift
import RxCocoa

final class PostWriteViewController: UIViewController {
    private let postWriteViewModel = PostWriteViewModel()
    private let disposeBag = DisposeBag()
    private let postTextView = UITextView()

    init(post: Post? = nil) {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "새싹농장 글쓰기"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "완료", image: nil, primaryAction: nil, menu: nil)
        setPostTextView()
        bind()
    }

    private func setPostTextView() {
        postTextView.isEditable = true
        postTextView.font = UIFont.systemFont(ofSize: 20)
        view.addSubview(postTextView)
        postTextView.snp.makeConstraints { textView in
            textView.edges.equalToSuperview()
        }
    }

    private func bind() {
        Observable.combineLatest(postWriteViewModel.text, navigationItem.rightBarButtonItem!.rx.tap)
            .subscribe(onNext: { text, _ in
                SesacNetwork.shared.uploadPost(text: text) { result in
                    switch result {
                    case .success:
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                        }
                    case .failure(let error):
                        print(error) // TODO: 토스트로 에러 메세지 띄워주기
                    }
                }
            })
            .disposed(by: disposeBag)

        postTextView.rx.text.orEmpty
            .bind(to: postWriteViewModel.text)
            .disposed(by: disposeBag)
    }
}
