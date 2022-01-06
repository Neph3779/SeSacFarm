//
//  PostTableViewController.swift
//  SeSacFarm
//
//  Created by 천수현 on 2022/01/06.
//

import UIKit
import RxSwift

final class PostTableViewController: UIViewController {
    private let postTableView = UITableView()
    private let postTableViewModel = PostTableViewModel()
    private var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    private func bindTableView() {
        postTableViewModel.posts.bind(
            to: postTableView.rx.items(
                cellIdentifier: PostTableViewCell.reuseIdentifier,
                cellType: PostTableViewCell.self)
        ) { row, model, cell in
            cell.setValues(nickname: model.id.description, description: model.text,
                           date: model.createdDate, replyCount: model.comments.count)
        }.disposed(by: disposeBag)
    }
}