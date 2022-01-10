//
//  PostDetailHeaderView.swift
//  SeSacFarm
//
//  Created by 천수현 on 2022/01/07.
//

import UIKit

final class PostDetailHeaderView: UITableViewHeaderFooterView {
    static let reuseIdentifier = "postDetailHeaderView"
    private let profileImageView = UIImageView(image: UIImage(systemName: "person"))
    private let userNameLabel = UILabel()
    private let dateLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let replyImageView = UIImageView()
    private let replyLabel = UILabel()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setProfileImageView()
        setUserNameLabel()
        setDateLabel()
        setDescriptionLabel()
        setReplyImageView()
        setReplyLabel()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func setValues(userName: String, date: String, description: String, replyCount: Int) {
        userNameLabel.text = userName
        dateLabel.text = date.convertToDate()
        descriptionLabel.text = description
        replyLabel.text = replyCount.description
        layoutSubviews()
    }

    private func setProfileImageView() {
        profileImageView.tintColor = .gray
        contentView.addSubview(profileImageView)
        profileImageView.snp.makeConstraints { imageView in
            imageView.leading.top.equalTo(contentView).inset(10)
        }
    }

    private func setUserNameLabel() {
        userNameLabel.text = "userName"
        contentView.addSubview(userNameLabel)
        userNameLabel.snp.makeConstraints { label in
            label.leading.equalTo(profileImageView.snp.trailing).offset(10)
            label.top.equalTo(contentView).inset(10)
        }
    }

    private func setDateLabel() {
        dateLabel.text = "dateLabel"
        dateLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        contentView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { label in
            label.leading.equalTo(profileImageView.snp.trailing).offset(10)
            label.top.equalTo(userNameLabel.snp.bottom)
        }
        profileImageView.snp.makeConstraints { imageView in
            imageView.bottom.equalTo(dateLabel.snp.bottom)
            imageView.width.equalTo(profileImageView.snp.height)
        }
    }

    private func setDescriptionLabel() {
        descriptionLabel.text = "description"
        descriptionLabel.numberOfLines = 0
        contentView.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { label in
            label.leading.trailing.equalTo(contentView).inset(20)
            label.top.equalTo(dateLabel.snp.bottom).offset(30)
        }
    }

    private func setReplyImageView() {
        replyImageView.image = UIImage(systemName: "message")
        replyImageView.tintColor = .gray
        contentView.addSubview(replyImageView)
        replyImageView.snp.makeConstraints { imageView in
            imageView.leading.bottom.equalTo(contentView).inset(10)
            imageView.top.equalTo(descriptionLabel.snp.bottom).offset(30)
        }
    }

    private func setReplyLabel() {
        replyLabel.text = "reply"
        contentView.addSubview(replyLabel)
        replyLabel.snp.makeConstraints { label in
            label.leading.equalTo(replyImageView.snp.trailing).offset(10)
            label.top.equalTo(descriptionLabel.snp.bottom).offset(30)
            label.trailing.bottom.equalTo(contentView).inset(10)
        }
        replyImageView.snp.makeConstraints { imageView in
            imageView.width.height.equalTo(replyLabel.snp.height)
        }
    }
}
