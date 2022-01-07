//
//  PostTableViewCell.swift
//  SeSacFarm
//
//  Created by 천수현 on 2022/01/04.
//

import UIKit

final class PostTableViewCell: UITableViewCell {
    static let reuseIdentifier = "postTableViewCell"
    private let nicknameLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let dateLabel = UILabel()
    private let divisionLine = UIView(frame: .zero)
    private let replyImageView = UIImageView()
    private let replyLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setNicknameLabel()
        setDescriptionLabel()
        setDateLabel()
        setDivisionLine()
        setReplyImageView()
        setReplyLabel()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setValues(nickname: String, description: String, date: String, replyCount: Int) {
        nicknameLabel.text = nickname
        descriptionLabel.text = description
        print(description)
        dateLabel.text = date
        replyLabel.text = replyCount.description
    }

    private func setNicknameLabel() {
        nicknameLabel.backgroundColor = .systemGray6
        nicknameLabel.textColor = .gray
        nicknameLabel.layer.cornerRadius = 10
        nicknameLabel.clipsToBounds = true
        contentView.addSubview(nicknameLabel)
        nicknameLabel.snp.makeConstraints { label in
            label.leading.top.equalTo(contentView).inset(10)
        }
    }

    private func setDescriptionLabel() {
        descriptionLabel.numberOfLines = 0
        contentView.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { label in
            label.leading.trailing.equalTo(contentView).inset(10)
            label.top.equalTo(nicknameLabel.snp.bottom).offset(10)
        }
    }

    private func setDateLabel() {
        contentView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { label in
            label.leading.equalTo(contentView).inset(10)
            label.top.equalTo(descriptionLabel.snp.bottom).offset(20)
        }
    }

    private func setDivisionLine() {
        divisionLine.backgroundColor = .systemGray6
        contentView.addSubview(divisionLine)
        divisionLine.snp.makeConstraints { line in
            line.leading.trailing.equalTo(contentView)
            line.top.equalTo(dateLabel.snp.bottom).offset(10)
            line.height.equalTo(1)
        }
    }

    private func setReplyImageView() {
        replyImageView.image = UIImage(systemName: "message")
        replyImageView.tintColor = .gray
        contentView.addSubview(replyImageView)
        replyImageView.snp.makeConstraints { imageView in
            imageView.leading.bottom.equalTo(contentView).inset(10)
            imageView.top.equalTo(divisionLine.snp.bottom).offset(10)
        }
    }

    private func setReplyLabel() {
        replyLabel.text = "댓글쓰기"
        contentView.addSubview(replyLabel)
        replyLabel.snp.makeConstraints { label in
            label.leading.equalTo(replyImageView.snp.trailing).offset(10)
            label.top.equalTo(divisionLine.snp.bottom).offset(10)
            label.trailing.bottom.equalTo(contentView).inset(10)
        }
        replyImageView.snp.makeConstraints { imageView in
            imageView.width.height.equalTo(replyLabel.snp.height)
        }
    }
}
