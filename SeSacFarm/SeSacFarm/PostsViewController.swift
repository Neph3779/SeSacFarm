//
//  PostTableViewController.swift
//  SeSacFarm
//
//  Created by 천수현 on 2022/01/06.
//

import UIKit
import RxSwift

final class PostsViewController: UIViewController {
    private var postsViewModel = PostsViewModel()
    private var disposeBag = DisposeBag()
    private let postCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let postAddButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setNavigationItems()
        setCollectionView()
        setPostAddButton()
        bind()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        postsViewModel.reloadPosts()
    }

    private func setNavigationItems() {
        navigationItem.setHidesBackButton(true, animated: true)
        navigationItem.title = "새싹농장"
        navigationItem.backButtonTitle = ""
    }

    private func setCollectionView() {
        postCollectionView.backgroundColor = .systemGray6
        postCollectionView.register(PostCollectionViewCell.self,
                                    forCellWithReuseIdentifier: PostCollectionViewCell.reuseIdentifier)
        postCollectionView.delegate = self
        view.addSubview(postCollectionView)
        postCollectionView.snp.makeConstraints { collectionView in
            collectionView.leading.trailing.bottom.equalToSuperview()
            collectionView.top.equalTo(view.safeAreaLayoutGuide)
        }

        guard let layout = postCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        layout.estimatedItemSize = CGSize(width: postCollectionView.frame.width, height: 10)
    }

    private func setPostAddButton() {
        postAddButton.backgroundColor = .systemGreen
        postAddButton.tintColor = .white
        postAddButton.clipsToBounds = true
        postAddButton.setImage(UIImage(systemName: "plus"), for: .normal)
        postAddButton.layer.cornerRadius = 25
        view.addSubview(postAddButton)
        postAddButton.snp.makeConstraints { button in
            button.trailing.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            button.width.height.equalTo(50)
        }
    }

    private func bind() {
        postsViewModel.posts.bind(
            to: postCollectionView.rx.items(
                cellIdentifier: PostCollectionViewCell.reuseIdentifier,
                cellType: PostCollectionViewCell.self)
        ) { _, model, cell in
            cell.setValues(nickname: model.user.userName, description: model.text,
                           date: model.createdDate, replyCount: model.comments.count)
        }.disposed(by: disposeBag)

        postCollectionView.rx.modelSelected(Post.self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { post in
                self.navigationController?.navigationBar.backIndicatorImage = UIImage(systemName: "arrow.backward")
                self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(systemName: "arrow.backward")
                self.navigationController?
                    .pushViewController(PostDetailViewController(post: post), animated: true)
            })
            .disposed(by: disposeBag)

        postAddButton.rx.tap
            .subscribe(onNext: {
                // TODO: 얘네 두개 뭐가 다른건지 공부, backButton만 고치면 왜 안되는지 공부
                self.navigationController?.navigationBar.backIndicatorImage = UIImage(systemName: "xmark")
                self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(systemName: "xmark")
                self.navigationController?.pushViewController(PostWriteViewController(), animated: true)
            })
            .disposed(by: disposeBag)
    }
}

extension PostsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: postCollectionView.frame.width, height: 10)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
    }
}
