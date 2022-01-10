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
    private var postDetailViewModel: PostDetailViewModel
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let replyView = UIView(frame: .zero)
    private let divisionLine = UIView(frame: .zero)
    private let replyBackgroudnView = UIView(frame: .zero)
    private let replyTextField = UITextField()
    private let cellAccessoryView: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        return button
    }()

    init(post: Post) {
        self.postDetailViewModel = PostDetailViewModel(post: post)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.postDetailViewModel = PostDetailViewModel(post: Post.default)
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setNavigationBar()
        setTableView()
        setReplyView()
        setNotifications()
        bind()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        postDetailViewModel.reloadPost()
        postDetailViewModel.reloadComments()
    }

    private func setNavigationBar() {
        navigationItem.backButtonTitle = ""
        if postDetailViewModel.checkMyPost == true {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis"),
                                                                style: .plain, target: self,
                                                                action: #selector(postEditButtonTapped))
        }
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

    private func setNotifications() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(backgroundTap))
        view.addGestureRecognizer(tapGestureRecognizer)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func bind() {
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

                if SesacNetwork.shared.id == model.user.id {
                    let button = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
                    button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
                    button.tintColor = .black
                    button.rx.tap.subscribe(onNext: {
                        self.commentEditButtonTapped(comment: model)
                    }).disposed(by: self.disposeBag)
                    cell.accessoryView = button
                } else {
                    cell.accessoryView = nil
                }
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

    private func commentEditButtonTapped(comment: DetailComment) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let editAction = UIAlertAction(title: "수정", style: .default) { _ in
            self.navigationController?.pushViewController(CommentModificationViewController(comment: comment), animated: true)
        }
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { _ in
            SesacNetwork.shared.deleteComment(commentId: comment.id) { result in
                switch result {
                case .success:
                    self.postDetailViewModel.reloadComments()
                case .failure(let error):
                    print(error)
                }
            }
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)

        [editAction, deleteAction, cancelAction].forEach { actionSheet.addAction($0) }
        present(actionSheet, animated: true, completion: nil)
    }

    @objc func postEditButtonTapped() {
        // FIXME: 이 방법 외에 observable의 현재 값을 가져오는 마땅한 방법을 모르겠습니다.
        var post: Post = Post.default
        do {
            post = try self.postDetailViewModel.post.value()
        } catch { }

        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let editAction = UIAlertAction(title: "수정", style: .default) { _ in
            self.navigationController?.pushViewController(PostWriteViewController(post: post), animated: true)
        }
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { _ in
            SesacNetwork.shared.deletePost(postId: post.id) { result in
                switch result {
                case .success:
                    DispatchQueue.main.async { self.navigationController?.popViewController(animated: true) }
                case .failure(let error):
                    print(error)
                }
            }
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)

        [editAction, deleteAction, cancelAction].forEach { actionSheet.addAction($0) }
        present(actionSheet, animated: true, completion: nil)
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
                as? PostDetailHeaderView else { return UIView() }

        postDetailViewModel.post
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { post in
                headerView.setValues(userName: post.user.userName, date: post.createdDate,
                                     description: post.text, replyCount: post.comments.count)
            }).disposed(by: disposeBag)

        return headerView
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        200
    }
}

// TODO: 이것저것 시도하다 token 만료된 경우 navigation의 rootView로 보내기 + 토스트 띄우기 (로그인 시작화면)
