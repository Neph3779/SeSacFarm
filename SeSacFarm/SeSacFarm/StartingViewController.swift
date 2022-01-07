//
//  ViewController.swift
//  SeSacFarm
//
//  Created by 천수현 on 2022/01/03.
//

import UIKit
import SnapKit

final class StartingViewController: UIViewController {
    private let introductionStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 10
        return stackView
    }()
    private let logoImageView = UIImageView(image: UIImage(named: "logo_ssac_clear"))
    private let introductionTitleLabel = UILabel()
    private let introductionDetailLabel = UILabel()
    private let startButton = UIButton()
    private let userLoginStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 10
        return stackView
    }()
    private let alreadyUserLabel = UILabel()
    private let loginButton = UIButton(type: .roundedRect)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.backIndicatorImage = UIImage(systemName: "arrow.backward")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(systemName: "arrow.backward")
        navigationItem.backButtonTitle = ""

        setIntroductionStackView()
        setUserLoginStackView()
        setStartButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }

    private func setIntroductionStackView() {
        logoImageView.contentMode = .scaleAspectFit
        introductionTitleLabel.text = Text.introductionTitle
        introductionTitleLabel.font = UIFont.boldSystemFont(ofSize: 24)

        introductionDetailLabel.text = Text.introductionDetail
        introductionDetailLabel.font = UIFont.systemFont(ofSize: 14)
        introductionDetailLabel.numberOfLines = 0
        introductionDetailLabel.textAlignment = .center

        view.addSubview(introductionStackView)
        [logoImageView, introductionTitleLabel, introductionDetailLabel].forEach {
            introductionStackView.addArrangedSubview($0)
        }

        introductionStackView.snp.makeConstraints { stackView in
            stackView.centerY.equalTo(view.snp.centerY).multipliedBy(0.8)
            stackView.centerX.equalTo(view)
            stackView.width.equalTo(view).multipliedBy(0.8)
        }
        introductionStackView.setContentHuggingPriority(.required, for: .vertical)
    }

    private func setUserLoginStackView() {
        alreadyUserLabel.text = Text.checkAlreadyUser
        alreadyUserLabel.textColor = .lightGray
        loginButton.setTitle(Text.login, for: .normal)
        loginButton.setTitleColor(.systemGreen, for: .normal)
        loginButton.addTarget(self, action: #selector(moveToLoginView), for: .touchUpInside)
        view.addSubview(userLoginStackView)
        [alreadyUserLabel, loginButton].forEach {
            userLoginStackView.addArrangedSubview($0)
        }
        userLoginStackView.snp.makeConstraints { stackView in
            stackView.centerX.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

    private func setStartButton() {
        startButton.backgroundColor = .systemGreen
        startButton.setTitle("시작하기", for: .normal)
        startButton.setTitleColor(.white, for: .normal)
        startButton.addTarget(self, action: #selector(moveToSignUpView), for: .touchUpInside)
        view.addSubview(startButton)
        startButton.snp.makeConstraints { button in
            button.centerX.equalTo(view)
            button.width.equalTo(view).multipliedBy(0.8)
            button.bottom.equalTo(userLoginStackView.snp.top).offset(-10)
        }
    }

    @objc private func moveToSignUpView() {
        navigationController?.pushViewController(SignUpViewController(mode: .signUp), animated: true)
    }

    @objc private func moveToLoginView() {
        navigationController?.pushViewController(SignUpViewController(mode: .login), animated: true)
    }
}

extension StartingViewController {
    fileprivate enum Text {
        static let introductionTitle = "당신 근처의 새싹농장"
        static let introductionDetail = "iOS 지식부터 바람의 나라까지\n지금 SeSAC에서 함께해보세요!"
        static let checkAlreadyUser = "이미 계정이 있나요?"
        static let login = "로그인"
    }
}
