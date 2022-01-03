//
//  SignUpViewController.swift
//  SeSacFarm
//
//  Created by 천수현 on 2022/01/03.
//

import UIKit
import SnapKit

final class SignUpViewController: UIViewController {
    private let signUpStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 5
        return stackView
    }()
    private let emailTextField = UITextField()
    private let nicknameTextField = UITextField()
    private let passwordTextField = UITextField()
    private let passwordCheckTextField = UITextField()
    private let startButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setNavigationBar()
        setSignUpStackView()
        setTextFields()
        setStartButton()
    }

    private func setNavigationBar() {
        navigationItem.title = "새싹농장 가입하기"
        navigationController?.navigationBar.tintColor = .black
        // TODO: back button 바꾸면서 트러블 슈팅 있었음 정리 필요
    }

    private func setSignUpStackView() {
        view.addSubview(signUpStackView)
        signUpStackView.snp.makeConstraints { stackView in
            stackView.top.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }

    private func setTextFields() {
        view.addSubview(signUpStackView)
        [emailTextField, nicknameTextField, passwordTextField, passwordCheckTextField].forEach { textField in
            signUpStackView.addArrangedSubview(textField)
            textField.borderStyle = .roundedRect
        }

        emailTextField.placeholder = Text.emailPlaceholder
        nicknameTextField.placeholder = Text.nicknamePlaceholder
        passwordTextField.placeholder = Text.passwordPlaceholder
        passwordCheckTextField.placeholder = Text.passwordCheckPlaceholder
    }

    private func setStartButton() { // TODO: 버튼 눌렀을때 fade? 되는거 공부해보기
        startButton.backgroundColor = .systemGreen
        startButton.setTitle("시작하기", for: .normal)
        startButton.setTitleColor(.white, for: .normal)
        signUpStackView.addArrangedSubview(startButton)
    }
}

extension SignUpViewController {
    fileprivate enum Text {
        static let emailPlaceholder = "이메일 주소"
        static let nicknamePlaceholder = "닉네임"
        static let passwordPlaceholder = "비밀번호"
        static let passwordCheckPlaceholder = "비밀번호 확인"
    }
}
