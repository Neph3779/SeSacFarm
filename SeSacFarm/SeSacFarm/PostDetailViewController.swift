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
    private let tableView = UITableView()
    private var postDetailViewModel: PostDetailViewModel

    init(comments: [Comment]) {
        self.postDetailViewModel = PostDetailViewModel(postComments: comments)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.postDetailViewModel = PostDetailViewModel(postComments: [])
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
        view.addSubview(tableView)
        tableView.snp.makeConstraints { table in
            table.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }

    private func bindTableView() {
        postDetailViewModel.comments.bind(to: tableView.rx.items(
            cellIdentifier: "tableViewCell",
            cellType: UITableViewCell.self)
        ) { _, model, cell in
            var content = cell.defaultContentConfiguration()
            content.text = model.text
            cell.contentConfiguration = content
        }.disposed(by: disposeBag)
    }
}

extension PostDetailViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        UIView()
//    }
}
