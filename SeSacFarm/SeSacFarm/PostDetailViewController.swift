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
    private var postDetailViewModel = PostDetailViewModel(post: Post(id: 0, text: "",
                                                                     user: User(id: 0, userName: ""),
                                                                     comments: [], createdDate: ""))
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let replyView = UIView(frame: .zero)
    private let divisionLine = UIView(frame: .zero)
    private let replyBackgroudnView = UIView(frame: .zero)
    private let replyTextField = UITextField()

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
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)

        setTableView()
        setReplyView()
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

    private func setReplyView() {
        view.addSubview(replyView)
        replyView.backgroundColor = .systemBackground
        replyView.snp.makeConstraints { replyView in
            replyView.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        divisionLine.backgroundColor = .systemGray6
        replyView.addSubview(divisionLine)
        divisionLine.snp.makeConstraints { line in
            line.leading.top.trailing.equalToSuperview()
            line.height.equalTo(2)
        }

        replyBackgroudnView.backgroundColor = .systemGray6
        replyBackgroudnView.layer.cornerRadius = 10
        replyBackgroudnView.clipsToBounds = true
        replyView.addSubview(replyBackgroudnView)
        replyBackgroudnView.snp.makeConstraints { backgroudnView in
            backgroudnView.top.leading.trailing.equalTo(replyView).inset(10)
            backgroudnView.bottom.equalTo(replyView).inset(5)
        }

        replyTextField.delegate = self
        replyTextField.backgroundColor = .clear
        replyTextField.placeholder = "댓글을 입력해주세요"
        replyBackgroudnView.addSubview(replyTextField)
        replyTextField.snp.makeConstraints { textField in
            textField.edges.equalTo(replyBackgroudnView).inset(5)
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

    // FIXME: 가끔 view가 safearea 밑까지 내려가버림
    @objc func keyboardWillShow(_ notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            print(keyboardHeight, view.frame.origin.y)
            view.frame.origin.y -= keyboardHeight
        }
    }

    @objc func keyboardWillHide(_ notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            view.frame.origin.y += keyboardHeight
        }
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

extension PostDetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}
