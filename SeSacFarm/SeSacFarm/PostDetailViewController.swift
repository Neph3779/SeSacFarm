//
//  PostDetailViewController.swift
//  SeSacFarm
//
//  Created by 천수현 on 2022/01/07.
//

import UIKit
import RxSwift
import RxCocoa

final class PostDetailViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private var postDetailViewModel = PostDetailViewModel(
        post: Post(id: 0, text: "",
                   user: User(id: 0, userName: ""),
                   comments: [], createdDate: ""))

    init(post: Post) {
        super.init(nibName: nil, bundle: nil)
        self.postDetailViewModel = PostDetailViewModel(post: post)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setTableView()
        bindTableView()
    }

    private func setTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "tableViewCell")
        tableView.register(PostDetailHeaderView.self, forHeaderFooterViewReuseIdentifier: PostDetailHeaderView.reuseIdentifier)
        tableView.delegate = self
        tableView.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.snp.makeConstraints { table in
            table.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }

    private func bindTableView() {
        postDetailViewModel.comments
            .bind(to: tableView.rx.items(
                cellIdentifier: "tableViewCell",
                cellType: UITableViewCell.self)
            ) { _, model, cell in
                var content = cell.defaultContentConfiguration()
                content.text = model.user.userName
                content.secondaryText = model.comment
                cell.contentConfiguration = content
            }
            .disposed(by: disposeBag)
    }
}

extension PostDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView
                .dequeueReusableHeaderFooterView(withIdentifier: PostDetailHeaderView.reuseIdentifier)
                as? PostDetailHeaderView else {
                    return UIView()
                }
        postDetailViewModel.post.subscribe(onNext: { post in
            headerView.setValues(userName: post.user.userName, date: post.createdDate,
                                 description: post.text, replyCount: post.comments.count)
        }).disposed(by: disposeBag)

        return headerView
    }
}
