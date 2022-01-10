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
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(backgroundTap))
        view.addGestureRecognizer(tapGestureRecognizer)
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

        replyTextField.backgroundColor = .clear
        replyTextField.placeholder = "댓글을 입력해주세요"
        replyBackgroudnView.addSubview(replyTextField)
        replyTextField.snp.makeConstraints { textField in
            textField.edges.equalTo(replyBackgroudnView).inset(5)
        }
    }

    private func bindTableView() {
        postDetailViewModel.comments
            .observe(on: MainScheduler.instance)
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

        replyTextField.rx.controlEvent(.editingDidEndOnExit)
            .subscribe { _ in
                self.postDetailViewModel.returnKeyTapped.onNext(())
                self.postDetailViewModel.replyText.onNext(self.replyTextField.text!)
                self.replyTextField.text?.removeAll()
            }
            .disposed(by: disposeBag)
    }

    @objc func keyboardWillShow(_ notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            let bottomSafeAreaHeight = view.frame.height
            - (view.safeAreaLayoutGuide.layoutFrame.origin.y
            + view.safeAreaLayoutGuide.layoutFrame.height)

            replyView.snp.remakeConstraints { replyView in
                replyView.leading.trailing.equalTo(view.safeAreaLayoutGuide)
                replyView.bottom.equalTo(view.safeAreaLayoutGuide).inset(keyboardHeight - bottomSafeAreaHeight)
            }
        }
    }

    @objc func keyboardWillHide(_ notification: NSNotification) {
        replyView.snp.remakeConstraints { replyView in
            replyView.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

    @objc func backgroundTap(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}

extension PostDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView
                .dequeueReusableHeaderFooterView(withIdentifier: PostDetailHeaderView.reuseIdentifier)
                as? PostDetailHeaderView else {
                    return UIView()
                }
        postDetailViewModel.post
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { post in
            headerView.setValues(userName: post.user.userName, date: post.createdDate,
                                 description: post.text, replyCount: post.comments.count)
        }).disposed(by: disposeBag)

        return headerView
    }
}

// TODO: 댓글 서버에 올리고 view refresh 해주기
// TODO: 로그인 실패시 뷰 전환 안하고 토스트만 띄워주기
// TODO: 이것저것 시도하다 token 만료된 경우 navigation의 rootView로 보내기 + 토스트 띄우기 (로그인 시작화면)
// TODO: 유저 id 보관하기, 수정 시도시 내가 안쓴건 수정 메뉴 안띄우기
// TODO: 글 작성해서 서버에 올리고 refresh 해주기
// TODO: 페이지네이션 구현하기
