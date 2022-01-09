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
    private let disposeBag = DisposeBag()
    private let postTextView = UITextView()

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
        navigationItem.rightBarButtonItem?.rx.tap
            .subscribe(onNext: {
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
}
