//
//  PostWriteViewController.swift
//  SeSacFarm
//
//  Created by 천수현 on 2022/01/05.
//

import UIKit

final class PostWriteViewController: UIViewController {
    private let postTextView = UITextView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setPostTextView()
    }

    private func setPostTextView() {
        postTextView.isEditable = true
        view.addSubview(postTextView)
        postTextView.snp.makeConstraints { textView in
            textView.edges.equalToSuperview()
        }
    }
}
