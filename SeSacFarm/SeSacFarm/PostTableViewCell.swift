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
    private let descriptionTextView = UITextView()
    private let dateLabel = UILabel()
    private let divisionLine = UIView(frame: .zero)
    private let replyImageView = UIImageView()
    private let replyLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setNicknameLabel()
        setDescriptionTextView()
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

    func setValues(nickname: String, description: String, date: Date, replyCount: Int) {
        
    }

    private func setNicknameLabel() {
        nicknameLabel.text = "닉네임"
        nicknameLabel.backgroundColor = .lightGray
        nicknameLabel.layer.cornerRadius = 5
        contentView.addSubview(nicknameLabel)
        nicknameLabel.snp.makeConstraints { label in
            label.leading.top.equalTo(contentView).inset(10)
        }
    }

    private func setDescriptionTextView() {
        descriptionTextView.text = "이건 아주 긴 내용이라 한 줄이 넘어갈 예정이에요 이런식으로 긴 텍스트를 쓰면 많이 넘어갈 수 있지 않을까요?"
        contentView.addSubview(descriptionTextView)
        descriptionTextView.snp.makeConstraints { textView in
            textView.leading.trailing.equalTo(contentView).inset(10)
            textView.top.equalTo(nicknameLabel.snp.bottom).offset(10)
        }
    }

    private func setDateLabel() {
        dateLabel.text = "12/32"
        contentView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { label in
            label.leading.equalTo(contentView).inset(10)
            label.top.equalTo(descriptionTextView.snp.bottom).offset(20)
        }
    }

    private func setDivisionLine() {
        divisionLine.backgroundColor = .lightGray
        contentView.addSubview(divisionLine)
        divisionLine.snp.makeConstraints { line in
            line.leading.trailing.equalTo(contentView)
            line.top.equalTo(dateLabel.snp.bottom).offset(10)
        }
    }

    private func setReplyImageView() {
        replyImageView.image = UIImage(systemName: "message")
        contentView.addSubview(replyImageView)
        replyImageView.snp.makeConstraints { imageView in
            imageView.leading.bottom.equalTo(contentView).inset(10)
            imageView.top.equalTo(divisionLine.snp.bottom).offset(10)
            imageView.height.equalTo(30)
        }
    }

    private func setReplyLabel() {
        replyLabel.text = "댓글쓰기"
        contentView.addSubview(replyLabel)
        replyLabel.snp.makeConstraints { label in
            label.leading.equalTo(replyImageView.snp.trailing).offset(10)
            label.top.equalTo(divisionLine.snp.bottom).offset(10)
            label.trailing.bottom.equalTo(contentView).inset(10)
            label.height.equalTo(30)
        }
    }
}
