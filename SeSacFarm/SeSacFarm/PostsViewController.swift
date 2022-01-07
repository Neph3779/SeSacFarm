//
//  PostTableViewController.swift
//  SeSacFarm
//
//  Created by 천수현 on 2022/01/06.
//

import UIKit
import RxSwift

final class PostsViewController: UIViewController {
    private let postCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let postsViewModel = PostsViewModel()
    private var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.setHidesBackButton(true, animated: true)
        navigationItem.title = "새싹농장"
        setCollectionView()
        bindTableView()
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
    }

    private func bindTableView() {
        postsViewModel.posts.bind(
            to: postCollectionView.rx.items(
                cellIdentifier: PostCollectionViewCell.reuseIdentifier,
                cellType: PostCollectionViewCell.self)
        ) { _, model, cell in
            cell.setValues(nickname: model.user.userName, description: model.text,
                           date: model.createdDate, replyCount: model.comments.count, comments: model.comments)
        }.disposed(by: disposeBag)

        postCollectionView.rx.modelSelected(Post.self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { post in
                self.navigationController?
                    .pushViewController(PostDetailViewController(post: post), animated: true)
            })
            .disposed(by: disposeBag)
    }
}

extension PostsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: postCollectionView.frame.width, height: 150)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
    }
}
